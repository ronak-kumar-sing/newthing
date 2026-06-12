import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import '../../core/design/anchor_theme.dart';
import '../../core/widgets/slice_widgets.dart';
import '../../data/local/database.dart';
import '../../data/remote/whatsapp_bridge_api.dart';
import '../../providers/api_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/whatsapp_bridge_provider.dart';
import '../../providers/task_provider.dart';
import 'whatsapp_notification_service.dart';

const _uuid = Uuid();

/// WhatsApp Digest — matches Stitch design "WhatsApp Digest"
/// AI-summarized group chat highlights via Baileys.
class WhatsappDigestScreen extends ConsumerStatefulWidget {
  const WhatsappDigestScreen({super.key});

  @override
  ConsumerState<WhatsappDigestScreen> createState() => _WhatsappDigestScreenState();
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
      backgroundColor: AnchorTheme.background,
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
                                  color: AnchorTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Auto-summarized from your groups',
                                style: GoogleFonts.inter(fontSize: 12, color: AnchorTheme.textMuted),
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
                                      child: CircularProgressIndicator(strokeWidth: 2, color: AnchorTheme.accent),
                                    )
                                  : PrimaryButton(
                                      'Generate',
                                      _generateDigest,
                                      height: 38,
                                      icon: Icons.auto_awesome,
                                    )
                              : const SizedBox.shrink(),
                          loading: () => const SizedBox.shrink(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.settings_outlined, size: 20, color: Colors.white.withOpacity(0.50)),
                          onPressed: () => context.push('/settings'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Connection status banner
                    _ConnectionBanner(onConnect: _startBridgeAndConnect),
                  ],
                ),
              ),
            ).animate().fade().slideY(begin: -0.1),

            // ── Tab Bar ──
            Container(
              margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              decoration: BoxDecoration(
                color: AnchorTheme.cardBg,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AnchorTheme.cardBorder),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Today'),
                  Tab(text: 'History'),
                  Tab(text: 'Groups'),
                ],
                indicator: BoxDecoration(
                  color: AnchorTheme.accent,
                  borderRadius: BorderRadius.circular(7),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: AnchorTheme.background,
                unselectedLabelColor: AnchorTheme.textSecondary,
                labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700),
                unselectedLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500),
                dividerColor: Colors.transparent,
              ),
            ).animate(delay: 100.ms).fade(),

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
            ).animate(delay: 200.ms).fade().slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }

  Future<void> _startBridgeAndConnect() async {
    if (kIsWeb || !Platform.isAndroid) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Notification reading is only supported on Android devices.', style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
        backgroundColor: AnchorTheme.statusRed,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    final granted = await NotificationListenerService.requestPermission();
    if (granted) {
      final dao = ref.read(whatsappDaoProvider);
      await WhatsappNotificationService.init(dao);
    }
    ref.invalidate(waStatusProvider);
  }

  Future<void> _generateDigest() async {
    final dao = ref.read(whatsappDaoProvider);
    final trackedGroups = await dao.getTrackedGroups();

    if (trackedGroups.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Select groups to track in the Groups tab first.', style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
          backgroundColor: AnchorTheme.textSecondary,
          behavior: SnackBarBehavior.floating,
        ));
      }
      return;
    }

    setState(() => _generatingDigest = true);

    final gemini = ref.read(geminiApiProvider);

    for (final group in trackedGroups) {
      final since = group.lastDigestAt;
      final messages = await WhatsappNotificationService.getMessages(group.name, since: since);

      if (messages.isEmpty) continue;

      final formatted = messages.map((m) => '[${m['senderName']}]: ${m['text']}').join('\n');
      final summary = await gemini.summarizeWhatsappMessages(formatted);
      if (summary == null) continue;

      final digestId = _uuid.v4();
      await dao.insertDigest(WhatsappDigestsCompanion(
        id: Value(digestId),
        groupName: Value(group.name),
        groupJid: Value(group.jid),
        rawMessages: Value(formatted),
        summary: Value(summary),
        digestDate: Value(DateTime.now()),
      ));

      await dao.updateGroupLastDigest(group.jid, DateTime.now());
      await WhatsappNotificationService.clearMessagesForGroup(group.name);

      final syncService = ref.read(syncServiceProvider);
      syncService.backupDigest(digestId);
    }

    setState(() => _generatingDigest = false);
    ref.invalidate(todayDigestsProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Digest generated ✓', style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
        backgroundColor: AnchorTheme.statusGreen,
        behavior: SnackBarBehavior.floating,
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
      priority: const Value(2),
      createdAt: Value(DateTime.now()),
    ));
    ref.invalidate(activeTasksProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Added to Task Center', style: GoogleFonts.inter(fontSize: 13, color: AnchorTheme.background)),
        backgroundColor: AnchorTheme.accent,
        behavior: SnackBarBehavior.floating,
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
            color: AnchorTheme.statusGreen,
            label: 'WhatsApp notification reading active',
          );
        }
        return _StatusRow(
          icon: Icons.notifications_off_outlined,
          color: AnchorTheme.textMuted,
          label: 'WhatsApp notification access required',
          trailing: GestureDetector(
            onTap: onConnect,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Grant Access',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox(height: 32, child: Center(child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AnchorTheme.accent)))),
      error: (_, __) => _StatusRow(
        icon: Icons.error_outline,
        color: AnchorTheme.statusRed,
        label: 'Bridge unavailable',
        trailing: TextButton(
          onPressed: onConnect,
          child: Text('Retry', style: GoogleFonts.inter(fontSize: 12, color: AnchorTheme.accent)),
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
  const _StatusRow({required this.icon, required this.color, required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ),
          if (trailing != null) trailing!,
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
          ? const _EmptyState(
              icon: Icons.chat_bubble_outline,
              title: 'No digests today',
              subtitle: 'Connect WhatsApp, select groups, and tap Generate',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20).copyWith(bottom: 100),
              itemCount: digests.length,
              itemBuilder: (context, i) => _DigestCard(
                digest: digests[i],
                onAddToTasks: onAddToTasks,
              ).animate(delay: (i * 100).ms).fade().slideX(begin: 0.1),
            ),
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AnchorTheme.accent)),
      error: (_, __) => const Center(child: Text('Error loading digests')),
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
          ? const _EmptyState(
              icon: Icons.history,
              title: 'No history yet',
              subtitle: 'Past digests will appear here',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20).copyWith(bottom: 100),
              itemCount: digests.length,
              itemBuilder: (context, i) => _DigestCard(
                digest: digests[i],
                onAddToTasks: (_) {},
              ).animate(delay: (i * 100).ms).fade().slideX(begin: 0.1),
            ),
      loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AnchorTheme.accent)),
      error: (_, __) => const Center(child: Text('Error loading history')),
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
      return const _EmptyState(
        icon: Icons.groups_outlined,
        title: 'Connect WhatsApp first',
        subtitle: 'Once connected, your groups will appear here',
      );
    }

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

    final trackedJids = {for (final g in localGroups) if (g.isTracked) g.jid};

    return ListView.builder(
      padding: const EdgeInsets.all(20).copyWith(bottom: 100),
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
            color: AnchorTheme.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isTracked ? AnchorTheme.accent.withOpacity(0.4) : AnchorTheme.cardBorder,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.groups, size: 18, color: Color(0xFF25D366)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AnchorTheme.textPrimary)),
                    Text('$participants members', style: GoogleFonts.inter(fontSize: 11, color: AnchorTheme.textMuted)),
                  ],
                ),
              ),
              Switch(
                value: isTracked,
                onChanged: (val) {
                  ref.read(whatsappDaoProvider).setGroupTracked(jid, tracked: val);
                  ref.invalidate(allLocalGroupsProvider);
                },
                activeColor: AnchorTheme.accent,
                activeTrackColor: AnchorTheme.accent.withOpacity(0.3),
                inactiveTrackColor: AnchorTheme.cardInset,
                inactiveThumbColor: AnchorTheme.textMuted,
              ),
            ],
          ),
        ).animate(delay: (i * 50).ms).fade().slideX(begin: -0.1);
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
    final lines = digest.summary.split('\n').where((l) => l.trim().isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: CleanCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF25D366).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.message, size: 18, color: Color(0xFF25D366)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(digest.groupName, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AnchorTheme.textPrimary)),
                      Text(_formatDate(digest.digestDate), style: GoogleFonts.inter(fontSize: 11, color: AnchorTheme.textMuted)),
                    ],
                  ),
                ),
                if (digest.todoistTaskId != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AnchorTheme.statusBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AnchorTheme.statusBlue.withOpacity(0.3)),
                    ),
                    child: Text('Synced', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: AnchorTheme.statusBlue)),
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
                        color: isAction ? AnchorTheme.statusRed : AnchorTheme.textMuted,
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
                              color: AnchorTheme.textPrimary,
                              fontWeight: isAction ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                          if (isAction) ...[
                            const SizedBox(height: 6),
                            GestureDetector(
                              onTap: () => onAddToTasks(line.replaceFirst(RegExp(r'^[-••]\s*(ACTION REQUIRED:\s*)?', caseSensitive: false), '')),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AnchorTheme.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AnchorTheme.accent.withOpacity(0.3)),
                                ),
                                child: Text('→ Add to Tasks', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AnchorTheme.accent)),
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

  const _EmptyState({required this.icon, required this.title, required this.subtitle});

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
              color: AnchorTheme.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AnchorTheme.cardBorder),
            ),
            child: Icon(icon, size: 28, color: AnchorTheme.textMuted),
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: AnchorTheme.textPrimary)),
          const SizedBox(height: 6),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: AnchorTheme.textMuted), textAlign: TextAlign.center),
        ],
      ),
    ).animate().fade();
  }
}
