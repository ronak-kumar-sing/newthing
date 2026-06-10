import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/constants/app_colors.dart';
import '../../core/widgets/slice_widgets.dart';
import '../../data/local/database.dart';
import '../../data/remote/whatsapp_bridge_api.dart';
import '../../providers/api_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/whatsapp_bridge_provider.dart';
import '../../providers/task_provider.dart';

const _uuid = Uuid();

/// WhatsApp Digest — AI-summarized group chat highlights via Baileys.
class WhatsappDigestScreen extends ConsumerStatefulWidget {
  const WhatsappDigestScreen({super.key});

  @override
  ConsumerState<WhatsappDigestScreen> createState() =>
      _WhatsappDigestScreenState();
}

class _WhatsappDigestScreenState extends ConsumerState<WhatsappDigestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _generatingDigest = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final bridgeAsync = ref.watch(waStatusProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: CleanCard(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WhatsApp Digest',
                                style: GoogleFonts.inter(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.5,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              Text(
                                'Auto-summarized from your groups',
                                style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        // Generate button
                        bridgeAsync.when(
                          data: (status) => status == WAStatus.connected
                              ? _generatingDigest
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary),
                                    )
                                  : PrimaryButton(
                                      'Generate',
                                      _generateDigest,
                                      height: 38,
                                      icon: Icons.auto_awesome,
                                    )
                              : const SizedBox.shrink(),
                          loading: () => const SizedBox.shrink(),
                          error: (_, _s) => const SizedBox.shrink(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Connection status banner
                    _ConnectionBanner(
                        onConnect: _startBridgeAndConnect),
                  ],
                ),
              ),
            ),

            // ── Tab Bar ──
            Container(
              margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Today'),
                  Tab(text: 'History'),
                  Tab(text: 'Groups'),
                ],
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(7),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600),
                unselectedLabelStyle:
                    GoogleFonts.inter(fontSize: 13),
                dividerColor: Colors.transparent,
              ),
            ),

            // ── Tab Views ──
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _TodayTab(onAddToTasks: _addToTasks),
                  const _HistoryTab(),
                  const _GroupsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startBridgeAndConnect() async {
    final bridge = ref.read(whatsappBridgeApiProvider);
    final started = await bridge.startBridge();
    if (!started && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Could not start WhatsApp bridge. Is Node.js installed?',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
    }
    ref.invalidate(waStatusProvider);
  }

  Future<void> _generateDigest() async {
    // Get tracked groups from DB
    final dao = ref.read(whatsappDaoProvider);
    final trackedGroups = await dao.getTrackedGroups();

    if (trackedGroups.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Select groups to track in the Groups tab first.',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
          backgroundColor: AppColors.textSecondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ));
      }
      return;
    }

    setState(() => _generatingDigest = true);

    final bridge = ref.read(whatsappBridgeApiProvider);
    final gemini = ref.read(geminiApiProvider);

    for (final group in trackedGroups) {
      // Get messages since last digest
      final since = group.lastDigestAt;
      List<WAMessage> messages;
      if (since != null) {
        messages = await bridge.getMessagesSince(group.jid, since);
      } else {
        messages = await bridge.getMessages(group.jid);
      }

      if (messages.isEmpty) continue;

      // Format messages for Gemini
      final formatted = messages
          .map((m) => '[${m.senderName}]: ${m.text}')
          .join('\n');

      final summary = await gemini.summarizeWhatsappMessages(formatted);
      if (summary == null) continue;

      // Save to DB
      final digestId = _uuid.v4();
      await dao.insertDigest(WhatsappDigestsCompanion(
        id: Value(digestId),
        groupName: Value(group.name),
        groupJid: Value(group.jid),
        rawMessages: Value(formatted),
        summary: Value(summary),
        digestDate: Value(DateTime.now()),
      ));

      // Update group's last digest time
      await dao.updateGroupLastDigest(group.jid, DateTime.now());

      // Optionally sync to Todoist
      final syncService = ref.read(syncServiceProvider);
      syncService.backupDigest(digestId);
    }

    setState(() => _generatingDigest = false);
    ref.invalidate(todayDigestsProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Digest generated ✓',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Future<void> _addToTasks(String actionText) async {
    final taskDao = ref.read(taskDaoProvider);
    await taskDao.upsertTask(TasksCompanion(
      id: Value(_uuid.v4()),
      title: Value(actionText),
      label: const Value('WhatsApp'),
      source: const Value('local'),
      isCompleted: const Value(false),
      priority: const Value(2), // Medium priority
      createdAt: Value(DateTime.now()),
    ));
    ref.invalidate(activeTasksProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Added to Task Center',
            style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// ─── Connection Banner ─────────────────────────────────────────

class _ConnectionBanner extends ConsumerWidget {
  final VoidCallback onConnect;
  const _ConnectionBanner({required this.onConnect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(waStatusProvider);
    return statusAsync.when(
      data: (status) {
        if (status == WAStatus.connected) {
          return _StatusRow(
            icon: Icons.check_circle,
            color: AppColors.success,
            label: 'WhatsApp connected',
            trailing: TextButton(
              onPressed: () => ref.read(whatsappBridgeApiProvider).disconnect(),
              child: Text('Disconnect',
                  style:
                      GoogleFonts.inter(fontSize: 12, color: AppColors.error)),
            ),
          );
        }
        if (status == WAStatus.qrPending) {
          return _QrCodeDialog(ref: ref);
        }
        // Disconnected
        return _StatusRow(
          icon: Icons.wifi_off,
          color: AppColors.textMuted,
          label: 'Not connected',
          trailing: GestureDetector(
            onTap: onConnect,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.qr_code_scanner,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text('Connect WhatsApp',
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        height: 32,
        child: Center(
            child: SizedBox(
                width: 16,
                height: 16,
                child:
                    CircularProgressIndicator(strokeWidth: 2))),
      ),
      error: (_, _s) => _StatusRow(
        icon: Icons.error_outline,
        color: AppColors.error,
        label: 'Bridge unavailable',
        trailing: TextButton(
          onPressed: onConnect,
          child: Text('Retry',
              style: GoogleFonts.inter(fontSize: 12, color: AppColors.primary)),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final Widget? trailing;
  const _StatusRow(
      {required this.icon,
      required this.color,
      required this.label,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _QrCodeDialog extends ConsumerWidget {
  final WidgetRef ref;
  const _QrCodeDialog({required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrAsync = ref.watch(waQrCodeProvider);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_scanner,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Scan with WhatsApp to connect',
                    style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          qrAsync.when(
            data: (qr) => qr != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(
                      Uri.parse(qr).data!.contentAsBytes(),
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  )
                : const SizedBox(
                    width: 200,
                    height: 200,
                    child: Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary)),
                  ),
            loading: () => const SizedBox(
                width: 200,
                height: 200,
                child: Center(
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary))),
            error: (_, _s) => const Text('Error loading QR code'),
          ),
          const SizedBox(height: 8),
          Text(
            'WhatsApp → Linked Devices → Link a Device',
            style: GoogleFonts.inter(
                fontSize: 11, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Today Tab ─────────────────────────────────────────────────

class _TodayTab extends ConsumerWidget {
  final ValueChanged<String> onAddToTasks;
  const _TodayTab({required this.onAddToTasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final digestsAsync = ref.watch(todayDigestsProvider);

    return digestsAsync.when(
      data: (digests) => digests.isEmpty
          ? _EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'No digests today',
              subtitle: 'Connect WhatsApp, select groups, and tap Generate',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: digests.length,
              itemBuilder: (context, i) => _DigestCard(
                digest: digests[i],
                onAddToTasks: onAddToTasks,
              ),
            ),
      loading: () => const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary)),
      error: (_, _s) =>
          const Center(child: Text('Error loading digests')),
    );
  }
}

// ─── History Tab ───────────────────────────────────────────────

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final digestsAsync = ref.watch(recentDigestsProvider);

    return digestsAsync.when(
      data: (digests) => digests.isEmpty
          ? _EmptyState(
              icon: Icons.history,
              title: 'No history yet',
              subtitle: 'Past digests will appear here',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: digests.length,
              itemBuilder: (context, i) => _DigestCard(
                digest: digests[i],
                onAddToTasks: (_) {},
              ),
            ),
      loading: () => const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppColors.primary)),
      error: (_, _s) =>
          const Center(child: Text('Error loading history')),
    );
  }
}

// ─── Groups Tab ────────────────────────────────────────────────

class _GroupsTab extends ConsumerWidget {
  const _GroupsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waStatus = ref.watch(waStatusProvider).valueOrNull;
    final waGroups = ref.watch(waGroupsProvider).valueOrNull ?? [];
    final localGroups = ref.watch(allLocalGroupsProvider).valueOrNull ?? [];

    if (waStatus != WAStatus.connected) {
      return _EmptyState(
        icon: Icons.groups_outlined,
        title: 'Connect WhatsApp first',
        subtitle: 'Once connected, your groups will appear here',
      );
    }

    // Sync remote groups to local DB
    if (waGroups.isNotEmpty) {
      final dao = ref.read(whatsappDaoProvider);
      for (final g in waGroups) {
        dao.upsertGroup(WhatsappGroupsCompanion(
          jid: Value(g.jid),
          name: Value(g.name),
          participantCount: Value(g.participantCount),
        ));
      }
    }

    final trackedJids = {
      for (final g in localGroups)
        if (g.isTracked) g.jid
    };

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: waGroups.isEmpty ? localGroups.length : waGroups.length,
      itemBuilder: (context, i) {
        final String jid;
        final String name;
        final int participants;

        if (waGroups.isNotEmpty) {
          jid = waGroups[i].jid;
          name = waGroups[i].name;
          participants = waGroups[i].participantCount;
        } else {
          jid = localGroups[i].jid;
          name = localGroups[i].name;
          participants = localGroups[i].participantCount;
        }

        final isTracked = trackedJids.contains(jid);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isTracked
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.groups, size: 18,
                    color: Color(0xFF25D366)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    Text('$participants members',
                        style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.textMuted)),
                  ],
                ),
              ),
              Switch(
                value: isTracked,
                onChanged: (val) {
                  ref
                      .read(whatsappDaoProvider)
                      .setGroupTracked(jid, tracked: val);
                  ref.invalidate(allLocalGroupsProvider);
                },
                activeThumbColor: AppColors.primary,
                activeTrackColor: AppColors.primary.withValues(alpha: 0.4),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Digest Card ───────────────────────────────────────────────

class _DigestCard extends StatelessWidget {
  final WhatsappDigest digest;
  final ValueChanged<String> onAddToTasks;

  const _DigestCard({required this.digest, required this.onAddToTasks});

  @override
  Widget build(BuildContext context) {
    final lines = digest.summary
        .split('\n')
        .where((l) => l.trim().isNotEmpty)
        .toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.message, size: 18,
                    color: Color(0xFF25D366)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(digest.groupName,
                        style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                    Text(
                      _formatDate(digest.digestDate),
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              // Todoist synced badge
              if (digest.todoistTaskId != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.info.withValues(alpha: 0.3)),
                  ),
                  child: Text('Synced',
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.info)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ...lines.map((line) {
            final isAction = line.toUpperCase().contains('ACTION');
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAction
                          ? AppColors.error
                          : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          line.replaceFirst(RegExp(r'^[-•]\s*'), ''),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            height: 1.5,
                            color: AppColors.textPrimary,
                            fontWeight: isAction
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        if (isAction) ...[
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => onAddToTasks(
                                line.replaceFirst(
                                    RegExp(r'^[-••]\s*(ACTION REQUIRED:\s*)?', caseSensitive: false),
                                    '')),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Text('→ Add to Tasks',
                                  style: GoogleFonts.inter(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(dt.year, dt.month, dt.day);

    if (date == today) return 'Today';
    if (date == yesterday) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// ─── Empty State ───────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(icon, size: 28, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Text(title,
              style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textMuted),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
