import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:drift/drift.dart' show Value;
import '../../core/constants/app_colors.dart';
import '../../core/widgets/slice_widgets.dart';
import '../../data/local/database.dart';
import '../../providers/api_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/task_provider.dart';

const _uuid = Uuid();

/// AI Coach — live Gemini responses with persistent chat history.
class AiCoachScreen extends ConsumerStatefulWidget {
  const AiCoachScreen({super.key});

  @override
  ConsumerState<AiCoachScreen> createState() => _AiCoachScreenState();
}

class _AiCoachScreenState extends ConsumerState<AiCoachScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _isSyncing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _ensureWelcomeMessage();
  }

  Future<void> _ensureWelcomeMessage() async {
    final sessionId = ref.read(chatSessionProvider);
    final dao = ref.read(chatDaoProvider);
    final messages = await dao.getSessionMessages(sessionId);
    if (messages.isEmpty) {
      await dao.insertMessage(ChatMessagesCompanion(
        id: Value(_uuid.v4()),
        content: const Value(
          "I'm your AI Coach. I have context on your tasks, your countdown, your progress, and your screen time. Ask me anything — 'Am I on track?', 'What should I prioritize?', or 'Help me plan my exam.'",
        ),
        isUser: const Value(false),
        timestamp: Value(DateTime.now()),
        sessionId: Value(sessionId),
      ));
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _messageController.clear();
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final sessionId = ref.read(chatSessionProvider);
    final dao = ref.read(chatDaoProvider);

    // Save user message
    await dao.insertMessage(ChatMessagesCompanion(
      id: Value(_uuid.v4()),
      content: Value(text),
      isUser: const Value(true),
      timestamp: Value(DateTime.now()),
      sessionId: Value(sessionId),
    ));

    _scrollToBottom();

    // Build context for Gemini
    final geminiApi = ref.read(geminiApiProvider);
    final daysRemaining = await ref.read(settingsDaoProvider).getDaysRemaining();
    final settings = await ref.read(settingsDaoProvider).getSettings();
    final activeTasks = ref.read(activeTasksProvider).valueOrNull ?? [];
    final taskTitles = activeTasks.take(10).map((t) => t.title).toList();

    // Get recent messages for context
    final allMessages = await dao.getSessionMessages(sessionId);
    final recentHistory = allMessages
        .where((m) => m.isUser)
        .take(5)
        .map((m) => {'role': m.isUser ? 'user' : 'coach', 'content': m.content})
        .toList();

    String? response;
    try {
      response = await geminiApi.generateCoachResponse(
        question: text,
        daysRemaining: daysRemaining ?? 0,
        independenceLabel: settings.independenceLabel,
        activeTasks: taskTitles,
        weeklyProgress: {},
        screenTimeSummary: null,
        chatHistory: recentHistory,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Gemini API error. Check your API key in Settings.';
        _isLoading = false;
      });
      return;
    }

    // Save AI response
    await dao.insertMessage(ChatMessagesCompanion(
      id: Value(_uuid.v4()),
      content: Value(response ??
          'I had trouble generating a response. Please check your Gemini API key in Settings.'),
      isUser: const Value(false),
      timestamp: Value(DateTime.now()),
      sessionId: Value(sessionId),
    ));

    setState(() => _isLoading = false);
    _scrollToBottom();
  }

  Future<void> _syncToTodoist() async {
    setState(() => _isSyncing = true);
    final sessionId = ref.read(chatSessionProvider);
    final syncService = ref.read(syncServiceProvider);
    final ok = await syncService.backupChatSession(sessionId);
    setState(() => _isSyncing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          ok ? 'Chat backed up to Todoist ✓' : 'Sync failed — check API key',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
        ),
        backgroundColor: ok ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void _startNewSession() {
    final newSession = 'session_${DateTime.now().millisecondsSinceEpoch}';
    ref.read(chatSessionProvider.notifier).state = newSession;
    Future.delayed(const Duration(milliseconds: 100), _ensureWelcomeMessage);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider);
    final geminiConfigured = ref.watch(geminiApiProvider).isConfigured;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: CleanCard(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    // AI avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Coach',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: geminiConfigured
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                geminiConfigured
                                    ? '${ref.read(geminiApiProvider).currentModel}'
                                    : 'No API key — add in Settings',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: geminiConfigured
                                      ? AppColors.textMuted
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Quick prompts
                    _QuickPromptChip(
                        label: 'Am I on track?',
                        onTap: () {
                          _messageController.text =
                              'Am I on track this week?';
                          _sendMessage();
                        }),
                    const SizedBox(width: 8),
                    _QuickPromptChip(
                        label: 'Prioritize today',
                        onTap: () {
                          _messageController.text =
                              'What should I prioritize today?';
                          _sendMessage();
                        }),
                    const SizedBox(width: 8),
                    // New session button
                    IconButton(
                      onPressed: _startNewSession,
                      icon: const Icon(Icons.add_comment_outlined,
                          size: 20, color: AppColors.textMuted),
                      tooltip: 'New conversation',
                    ),
                    // Sync button
                    _isSyncing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary),
                          )
                        : IconButton(
                            onPressed: _syncToTodoist,
                            icon: const Icon(Icons.cloud_upload_outlined,
                                size: 20, color: AppColors.textMuted),
                            tooltip: 'Backup to Todoist',
                          ),
                  ],
                ),
              ),
            ),

            // ── Error banner ──
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        size: 16, color: AppColors.error),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: GoogleFonts.inter(
                            fontSize: 13, color: AppColors.error),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 14),
                      onPressed: () => setState(() => _errorMessage = null),
                      color: AppColors.error,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

            // ── Chat messages ──
            Expanded(
              child: messagesAsync.when(
                data: (messages) => messages.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        itemCount: messages.length + (_isLoading ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == messages.length) {
                            return const _TypingIndicator();
                          }
                          return _ChatBubble(message: messages[index]);
                        },
                      ),
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.primary),
                ),
                error: (_, _s) => const Center(
                    child: Text('Error loading messages')),
              ),
            ),

            // ── Input area ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowLight,
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: geminiConfigured
                              ? 'Ask your coach anything...'
                              : 'Add your Gemini API key in Settings first',
                          hintStyle: GoogleFonts.inter(
                              fontSize: 14, color: AppColors.textMuted),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        maxLines: 3,
                        minLines: 1,
                        enabled: geminiConfigured && !_isLoading,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: geminiConfigured ? _sendMessage : null,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: geminiConfigured
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.send_rounded,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// ─── Chat Bubble ───────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!message.isUser) ...[
              Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(right: 8, bottom: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_awesome,
                    color: Colors.white, size: 14),
              ),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? AppColors.primary
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      message.content,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: message.isUser
                            ? Colors.white
                            : AppColors.textPrimary,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${message.timestamp.hour.toString().padLeft(2, '0')}:'
                      '${message.timestamp.minute.toString().padLeft(2, '0')}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: message.isUser
                            ? Colors.white.withValues(alpha: 0.6)
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Typing Indicator ─────────────────────────────────────────

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();
    _anim = Tween(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 14),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AnimatedBuilder(
                animation: _anim,
                builder: (_, _c) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [0, 1, 2].map((i) {
                    final delay = i * 0.3;
                    final opacity = (((_controller.value + delay) % 1.0 < 0.5)
                            ? _controller.value
                            : 1 - _controller.value)
                        .clamp(0.3, 1.0);
                    return Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.textMuted.withValues(alpha: opacity),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ─── Quick Prompt Chip ─────────────────────────────────────────

class _QuickPromptChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickPromptChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
