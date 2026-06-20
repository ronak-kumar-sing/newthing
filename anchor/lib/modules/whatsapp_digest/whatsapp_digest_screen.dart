import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/design/anchor_theme.dart';
import '../../core/widgets/slice_widgets.dart';
import '../../data/local/database.dart';
import '../../data/remote/gemini_api.dart';
import '../../data/remote/whatsapp_bridge_api.dart';
import '../../providers/api_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/whatsapp_bridge_provider.dart';
import '../../providers/task_provider.dart';
import '../../core/responsive/responsive_content_layout.dart';
import 'whatsapp_message_source.dart';
import 'whatsapp_notification_service.dart';

const _uuid = Uuid();

/// WhatsApp Digest — AI-summarized group chat highlights.
class WhatsappDigestScreen extends ConsumerStatefulWidget {
  const WhatsappDigestScreen({super.key});

  @override
  ConsumerState<WhatsappDigestScreen> createState() => _WhatsappDigestScreenState();
}

class _WhatsappDigestScreenState extends ConsumerState<WhatsappDigestScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _generatingDigest = false;
  String? _lastError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final bridgeAsync = ref.watch(waStatusProvider);
    final settingsAsync = ref.watch(settingsProvider);

    final enabled = settingsAsync.valueOrNull?.whatsappDigestEnabled ?? true;

    final mobileBody = Scaffold(
      backgroundColor: AnchorTheme.background,
      body: SafeArea(
        child: _buildBody(context, ref, enabled, bridgeAsync),
      ),
    );

    return ResponsiveContentLayout(
      mobileBody: mobileBody,
      desktopBody: _buildBody(context, ref, enabled, bridgeAsync),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
    AsyncValue<WAStatus> bridgeAsync,
  ) {
    return Column(
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
                    if (enabled)
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
                        error: (_, _) => const SizedBox.shrink(),
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
                _ConnectionBanner(
                  onConnect: _startBridgeAndConnect,
                  onShowQr: _showQrCode,
                ),
                if (_lastError != null) ...[
                  const SizedBox(height: 10),
                  _ErrorPill(message: _lastError!, onDismiss: () => setState(() => _lastError = null)),
                ],
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
              _TodayTab(onAddToTasks: _addToTasks, enabled: enabled),
              const _HistoryTab(),
              const _GroupsTab(),
            ],
          ),
        ).animate(delay: 200.ms).fade().slideY(begin: 0.1),
      ],
    );
  }

  Future<void> _startBridgeAndConnect() async {
    setState(() => _lastError = null);

    if (kIsWeb) {
      setState(() => _lastError = 'WhatsApp Digest is not available on the web.');
      return;
    }

    if (Platform.isAndroid) {
      final granted = await WhatsappNotificationService.requestPermission();
      if (granted) {
        final dao = ref.read(whatsappDaoProvider);
        await WhatsappNotificationService.init(dao);
      }
      ref.invalidate(waStatusProvider);
      return;
    }

    // Desktop: start the Baileys bridge sidecar.
    final bridge = ref.read(whatsappBridgeProvider);
    try {
      final started = await bridge.startBridge();
      if (!started) {
        setState(() => _lastError = 'Could not start WhatsApp bridge. Is Node.js installed and the bridge directory present?');
      }
    } catch (e) {
      setState(() => _lastError = 'Bridge error: $e');
    }

    ref.invalidate(waStatusProvider);
    ref.invalidate(waQrCodeProvider);
    ref.invalidate(waGroupsProvider);
  }

  Future<void> _showQrCode() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: AnchorTheme.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const _QrCodeSheet(),
    );
  }

  Future<void> _generateDigest() async {
    final dao = ref.read(whatsappDaoProvider);
    final trackedGroups = await dao.getTrackedGroups();

    if (trackedGroups.isEmpty) {
      if (mounted) {
        _showSnackBar('Select groups to track in the Groups tab first.', AnchorTheme.textSecondary);
      }
      return;
    }

    setState(() {
      _generatingDigest = true;
      _lastError = null;
    });

    final gemini = ref.read(geminiApiProvider);
    final source = _currentSource();

    try {
      for (final group in trackedGroups) {
        final since = group.lastDigestAt;
        final messages = await source.fetchMessages(
          groupName: group.name,
          groupJid: group.jid,
          since: since,
        );

        if (messages.isEmpty) continue;

        final formatted = messages.map((m) => '[${m.senderName}]: ${m.text}').join('\n');
        final summary = await _summarizeWithRetry(gemini, formatted);
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
        await source.markProcessed(messages);

        final syncService = ref.read(syncServiceProvider);
        unawaited(syncService.backupDigest(digestId));
      }

      // Keep the raw-message table from growing unbounded.
      await dao.cleanupOldRawMessages(days: 7);

      ref.invalidate(todayDigestsProvider);
      ref.invalidate(recentDigestsProvider);
      ref.invalidate(unprocessedMessageCountsProvider);

      if (mounted) {
        _showSnackBar('Digest generated ✓', AnchorTheme.statusGreen);
      }
    } catch (e, st) {
      debugPrint('[WA Digest] Generation failed: $e\n$st');
      if (mounted) {
        setState(() => _lastError = 'Failed to generate digest: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _generatingDigest = false);
      }
    }
  }

  WhatsappMessageSource _currentSource() {
    if (kIsWeb) {
      throw UnsupportedError('WhatsApp Digest is not available on the web.');
    }
    if (Platform.isAndroid) {
      return NotificationMessageSource(ref.read(whatsappDaoProvider));
    }
    return BridgeMessageSource(ref.read(whatsappBridgeProvider));
  }

  Future<String?> _summarizeWithRetry(GeminiApi gemini, String formatted) async {
    final first = await gemini.summarizeWhatsappMessages(formatted);
    if (first != null && first.isNotEmpty) return first;
    // One immediate retry for transient Gemini failures.
    await Future.delayed(const Duration(seconds: 1));
    return gemini.summarizeWhatsappMessages(formatted);
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
    ref.read(syncServiceProvider).syncTasks().then((_) {
      ref.invalidate(activeTasksProvider);
    });
    if (mounted) {
      _showSnackBar('Added to Task Center', AnchorTheme.accent, textColor: AnchorTheme.background);
    }
  }

  void _showSnackBar(String message, Color background, {Color? textColor}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.inter(fontSize: 13, color: textColor ?? Colors.white)),
      backgroundColor: background,
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// ─── Error Pill ────────────────────────────────────────────────

class _ErrorPill extends StatelessWidget {
  final String message;
  final VoidCallback onDismiss;

  const _ErrorPill({required this.message, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AnchorTheme.statusRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AnchorTheme.statusRed.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 15, color: AnchorTheme.statusRed),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AnchorTheme.statusRed),
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close, size: 15, color: AnchorTheme.statusRed),
          ),
        ],
      ),
    );
  }
}

// ─── QR Code Sheet ─────────────────────────────────────────────

class _QrCodeSheet extends ConsumerWidget {
  const _QrCodeSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrAsync = ref.watch(waQrCodeProvider);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AnchorTheme.cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Scan with WhatsApp',
              style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AnchorTheme.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Open WhatsApp → Linked Devices → Link a Device',
              style: GoogleFonts.inter(fontSize: 13, color: AnchorTheme.textMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            qrAsync.when(
              data: (qr) {
                if (qr == null || qr.isEmpty) {
                  return Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      color: AnchorTheme.cardInset,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Waiting for QR code...',
                        style: GoogleFonts.inter(fontSize: 13, color: AnchorTheme.textMuted),
                      ),
                    ),
                  );
                }
                try {
                  final base64Data = qr.contains(',') ? qr.split(',')[1] : qr;
                  final bytes = base64Decode(base64Data);
                  return Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(bytes, fit: BoxFit.contain),
                    ),
                  );
                } catch (e) {
                  return Text('Could not load QR code', style: GoogleFonts.inter(color: AnchorTheme.statusRed));
                }
              },
              loading: () => const SizedBox(
                width: 240,
                height: 240,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AnchorTheme.accent)),
              ),
              error: (e, _) => Text('Error: $e', style: GoogleFonts.inter(color: AnchorTheme.statusRed)),
            ),
            const SizedBox(height: 24),
            PrimaryButton('Close', () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}

// ─── Connection Banner ─────────────────────────────────────────

class _ConnectionBanner extends ConsumerWidget {
  final VoidCallback onConnect;
  final VoidCallback onShowQr;

  const _ConnectionBanner({required this.onConnect, required this.onShowQr});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(waStatusProvider);
    final isDesktop = !kIsWeb && !Platform.isAndroid && !Platform.isIOS;

    return statusAsync.when(
      data: (status) {
        if (status == WAStatus.connected) {
          return _StatusRow(
            icon: Icons.check_circle,
            color: AnchorTheme.statusGreen,
            label: isDesktop
                ? 'WhatsApp bridge connected'
                : 'WhatsApp notification reading active',
          );
        }

        if (status == WAStatus.qrPending) {
          return _StatusRow(
            icon: Icons.qr_code,
            color: AnchorTheme.accent,
            label: 'Scan QR code to connect',
            trailing: GestureDetector(
              onTap: onShowQr,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: AnchorTheme.accent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Show QR',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AnchorTheme.background),
                ),
              ),
            ),
          );
        }

        return _StatusRow(
          icon: isDesktop ? Icons.desktop_windows_outlined : Icons.notifications_off_outlined,
          color: AnchorTheme.textMuted,
          label: isDesktop
              ? 'WhatsApp bridge not connected'
              : 'WhatsApp notification access required',
          trailing: GestureDetector(
            onTap: onConnect,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF25D366),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isDesktop ? 'Start Bridge' : 'Grant Access',
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
  final bool enabled;

  const _TodayTab({required this.onAddToTasks, required this.enabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final digestsAsync = ref.watch(todayDigestsProvider);

    return digestsAsync.when(
      data: (digests) => digests.isEmpty
          ? _EmptyState(
              icon: Icons.chat_bubble_outline,
              title: enabled ? 'No digests today' : 'WhatsApp Digest disabled',
              subtitle: enabled
                  ? 'Connect WhatsApp, select groups, and tap Generate'
                  : 'Enable WhatsApp Digest in Settings to get started',
            )
          : RefreshIndicator(
              color: AnchorTheme.accent,
              backgroundColor: AnchorTheme.cardBg,
              onRefresh: () async {
                ref.invalidate(todayDigestsProvider);
                ref.invalidate(unprocessedMessageCountsProvider);
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(20).copyWith(bottom: 100),
                itemCount: digests.length,
                itemBuilder: (context, i) => _DigestCard(
                  digest: digests[i],
                  onAddToTasks: onAddToTasks,
                ).animate(delay: (i * 100).ms).fade().slideX(begin: 0.1),
              ),
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
          : RefreshIndicator(
              color: AnchorTheme.accent,
              backgroundColor: AnchorTheme.cardBg,
              onRefresh: () async => ref.invalidate(recentDigestsProvider),
              child: ListView.builder(
                padding: const EdgeInsets.all(20).copyWith(bottom: 100),
                itemCount: digests.length,
                itemBuilder: (context, i) => _DigestCard(
                  digest: digests[i],
                  onAddToTasks: (_) {},
                ).animate(delay: (i * 100).ms).fade().slideX(begin: 0.1),
              ),
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
                  ref.invalidate(trackedGroupsProvider);
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

/// Utility to fire async tasks without awaiting them in a void context.
void unawaited(Future<void> future) {}
