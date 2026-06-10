import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/env_config.dart';
import '../../core/widgets/slice_widgets.dart';
import '../../data/local/database.dart';
import '../../providers/api_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';

/// Available Gemini models.
const _kGeminiModels = [
  ('gemini-2.0-flash', 'Gemini 2.0 Flash', 'Fast · Free tier'),
  ('gemini-2.5-flash', 'Gemini 2.5 Flash', 'Latest · Best value'),
  ('gemini-2.5-pro', 'Gemini 2.5 Pro', 'Most powerful'),
];

/// Settings screen — clean white professional configuration panel.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _todoistController = TextEditingController();
  final _geminiController = TextEditingController();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();

  DateTime? _independenceDate;
  String? _independenceLabel;
  int _distractionLimit = 120;
  String _selectedModel = 'gemini-2.0-flash';

  bool _isSaving = false;
  bool? _todoistStatus; // null=untested, true=ok, false=fail
  bool? _geminiStatus;
  bool _testingTodoist = false;
  bool _testingGemini = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await ref.read(settingsDaoProvider).getSettings();

    // Auto-load from .env if API keys are empty
    final hasTodoist = settings.todoistApiToken?.isNotEmpty == true;
    final hasGemini = settings.geminiApiKey?.isNotEmpty == true;
    if (!hasTodoist || !hasGemini) {
      await EnvConfig.load();
    }

    setState(() {
      _todoistController.text =
          settings.todoistApiToken?.isNotEmpty == true
              ? settings.todoistApiToken!
              : (EnvConfig.todoistApiToken ?? '');
      _geminiController.text =
          settings.geminiApiKey?.isNotEmpty == true
              ? settings.geminiApiKey!
              : (EnvConfig.geminiApiKey ?? '');
      _nameController.text = settings.userName ?? '';
      _cityController.text = settings.weatherCity ?? '';
      _independenceDate = settings.independenceDate;
      _independenceLabel = settings.independenceLabel;
      _distractionLimit = settings.distractionLimitMinutes;
      _selectedModel = settings.geminiModel;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    final dao = ref.read(settingsDaoProvider);
    await dao.updateSettings(AppSettingsCompanion(
      todoistApiToken: _todoistController.text.isNotEmpty
          ? Value(_todoistController.text)
          : const Value.absent(),
      geminiApiKey: _geminiController.text.isNotEmpty
          ? Value(_geminiController.text)
          : const Value.absent(),
      userName: _nameController.text.isNotEmpty
          ? Value(_nameController.text)
          : const Value.absent(),
      weatherCity: _cityController.text.isNotEmpty
          ? Value(_cityController.text)
          : const Value.absent(),
      independenceDate: _independenceDate != null
          ? Value(_independenceDate!)
          : const Value.absent(),
      independenceLabel: _independenceLabel != null
          ? Value(_independenceLabel!)
          : const Value.absent(),
      distractionLimitMinutes: Value(_distractionLimit),
      geminiModel: Value(_selectedModel),
    ));

    // Apply to live API clients
    ref.read(todoistApiProvider).setToken(_todoistController.text);
    ref.read(geminiApiProvider)
      ..setApiKey(_geminiController.text)
      ..setModel(_selectedModel);

    ref.invalidate(settingsProvider);
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Settings saved',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.white)),
          duration: const Duration(seconds: 2),
          backgroundColor: AppColors.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _testTodoist() async {
    if (_todoistController.text.isEmpty) return;
    setState(() => _testingTodoist = true);
    ref.read(todoistApiProvider).setToken(_todoistController.text);
    final ok = await ref.read(todoistApiProvider).testConnection();
    setState(() {
      _todoistStatus = ok;
      _testingTodoist = false;
    });
  }

  Future<void> _testGemini() async {
    if (_geminiController.text.isEmpty) return;
    setState(() => _testingGemini = true);
    ref.read(geminiApiProvider)
      ..setApiKey(_geminiController.text)
      ..setModel(_selectedModel);
    final ok = await ref.read(geminiApiProvider).testConnection();
    setState(() {
      _geminiStatus = ok;
      _testingGemini = false;
    });
  }

  Future<void> _loadFromEnv() async {
    await EnvConfig.load();
    setState(() {
      if (EnvConfig.todoistApiToken != null) {
        _todoistController.text = EnvConfig.todoistApiToken!;
      }
      if (EnvConfig.geminiApiKey != null) {
        _geminiController.text = EnvConfig.geminiApiKey!;
      }
      if (EnvConfig.userName != null) _nameController.text = EnvConfig.userName!;
      if (EnvConfig.weatherCity != null) {
        _cityController.text = EnvConfig.weatherCity!;
      }
      if (EnvConfig.independenceDate != null) {
        _independenceDate = EnvConfig.independenceDate;
      }
      if (EnvConfig.independenceLabel != null) {
        _independenceLabel = EnvConfig.independenceLabel;
      }
      _distractionLimit = EnvConfig.distractionLimitMinutes;
      _selectedModel = EnvConfig.geminiModel;
      // Reset test status after loading new values
      _todoistStatus = null;
      _geminiStatus = null;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              FadeSlideIn(
                delaySeconds: 0.0,
                child: CleanCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Settings',
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _loadFromEnv,
                        icon: const Icon(Icons.file_open_outlined, size: 16),
                        label: Text('Load .env', style: GoogleFonts.inter(fontSize: 12)),
                        style:
                            TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 8),
                      _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.primary),
                            )
                          : PrimaryButton('Save', _saveSettings, height: 40),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── API Keys ──
              FadeSlideIn(
                delaySeconds: 0.1,
                child: CleanCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                          title: 'API Keys', icon: Icons.key_outlined, color: AppColors.primary),
                      const SizedBox(height: 20),

                      // Todoist
                      _ApiKeyField(
                        label: 'Todoist API Token',
                        controller: _todoistController,
                        hint: 'Paste your Todoist API token',
                        helpText: 'app.todoist.com → Settings → Integrations → Developer',
                        testStatus: _todoistStatus,
                        isTesting: _testingTodoist,
                        onTest: _testTodoist,
                        onChanged: () => setState(() => _todoistStatus = null),
                      ),
                      const SizedBox(height: 20),

                      // Gemini
                      _ApiKeyField(
                        label: 'Gemini API Key',
                        controller: _geminiController,
                        hint: 'Paste your Gemini API key',
                        helpText: 'aistudio.google.com/app/apikey',
                        testStatus: _geminiStatus,
                        isTesting: _testingGemini,
                        onTest: _testGemini,
                        onChanged: () => setState(() => _geminiStatus = null),
                      ),
                      const SizedBox(height: 20),

                      // Model selector
                      Text(
                        'GEMINI MODEL',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: _kGeminiModels.map((model) {
                          final (value, name, subtitle) = model;
                          final isSelected = _selectedModel == value;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedModel = value;
                              _geminiStatus = null;
                            }),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryBg
                                    : AppColors.bg,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.primary
                                            : AppColors.border,
                                        width: isSelected ? 4 : 1.5,
                                      ),
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          subtitle,
                                          style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Independence Goal ──
              FadeSlideIn(
                delaySeconds: 0.15,
                child: CleanCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                          title: 'Independence Goal',
                          icon: Icons.flag_outlined,
                          color: AppColors.info),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _independenceDate ??
                                DateTime.now().add(const Duration(days: 365)),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365 * 5)),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.primary,
                                  surface: AppColors.card,
                                  onSurface: AppColors.textPrimary,
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (date != null)
                            setState(() => _independenceDate = date);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Goal Date',
                                        style: GoogleFonts.inter(
                                            fontSize: 11,
                                            color: AppColors.textMuted)),
                                    const SizedBox(height: 2),
                                    Text(
                                      _independenceDate
                                              ?.toIso8601String()
                                              .split('T')
                                              .first ??
                                          'Select a date',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: _independenceDate != null
                                            ? AppColors.textPrimary
                                            : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  size: 18, color: AppColors.textMuted),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _CleanTextField(
                        controller:
                            TextEditingController(text: _independenceLabel),
                        label: 'Goal Label',
                        hint: 'e.g., Graduation, Placement Season',
                        onChanged: (v) => _independenceLabel = v,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Personal ──
              FadeSlideIn(
                delaySeconds: 0.2,
                child: CleanCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                          title: 'Personal',
                          icon: Icons.person_outline,
                          color: AppColors.success),
                      const SizedBox(height: 20),
                      _CleanTextField(
                          controller: _nameController,
                          label: 'Your Name',
                          hint: 'How should Anchor address you?'),
                      const SizedBox(height: 12),
                      _CleanTextField(
                          controller: _cityController,
                          label: 'City',
                          hint: 'For weather updates'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Screen Time ──
              FadeSlideIn(
                delaySeconds: 0.25,
                child: CleanCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                          title: 'Screen Time',
                          icon: Icons.monitor_outlined,
                          color: AppColors.error),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Daily Distraction Limit',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${_distractionLimit ~/ 60}h ${_distractionLimit % 60}m',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: AppColors.primary,
                          inactiveTrackColor: AppColors.trackBg,
                          thumbColor: AppColors.primary,
                          overlayColor: AppColors.primary.withValues(alpha: 0.1),
                          trackHeight: 6,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10),
                        ),
                        child: Slider(
                          value: _distractionLimit.toDouble(),
                          min: 30,
                          max: 300,
                          divisions: 54,
                          label:
                              '${_distractionLimit ~/ 60}h ${_distractionLimit % 60}m',
                          onChanged: (v) =>
                              setState(() => _distractionLimit = v.round()),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── About ──
              FadeSlideIn(
                delaySeconds: 0.3,
                child: CleanCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Icon(Icons.anchor,
                                size: 20, color: AppColors.primary),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Anchor',
                                    style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary)),
                                Text('Personal Student Life OS',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppColors.textSecondary)),
                              ],
                            ),
                          ),
                          Text('v1.0.0',
                              style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Your data never leaves your device. No analytics. No cloud. No accounts.',
                          style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _todoistController.dispose();
    _geminiController.dispose();
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}

// ─── Section Header ────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader(
      {required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── API Key Field with Test Button ───────────────────────────

class _ApiKeyField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final String helpText;
  final bool? testStatus;
  final bool isTesting;
  final VoidCallback onTest;
  final VoidCallback onChanged;

  const _ApiKeyField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.helpText,
    required this.testStatus,
    required this.isTesting,
    required this.onTest,
    required this.onChanged,
  });

  @override
  State<_ApiKeyField> createState() => _ApiKeyFieldState();
}

class _ApiKeyFieldState extends State<_ApiKeyField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      widget.onChanged();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasValue = widget.controller.text.isNotEmpty;
    final status = widget.testStatus;

    Color borderColor = AppColors.border;
    if (status == true) borderColor = AppColors.success;
    if (status == false) borderColor = AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary),
            ),
            const SizedBox(width: 6),
            // Status dot
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: status == null
                    ? (hasValue ? AppColors.info : AppColors.border)
                    : (status ? AppColors.success : AppColors.error),
              ),
            ),
            const Spacer(),
            // Test button
            if (hasValue)
              widget.isTesting
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 1.5, color: AppColors.primary),
                    )
                  : GestureDetector(
                      onTap: widget.onTest,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == true
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.primaryBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: status == true
                                ? AppColors.success.withValues(alpha: 0.4)
                                : AppColors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          status == true
                              ? '✓ Connected'
                              : status == false
                                  ? '✗ Failed — Retry'
                                  : 'Test',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: status == true
                                ? AppColors.success
                                : status == false
                                    ? AppColors.error
                                    : AppColors.primary,
                          ),
                        ),
                      ),
                    ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: GoogleFonts.inter(
                  fontSize: 13, color: AppColors.textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              suffixIcon: hasValue
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () => widget.controller.clear(),
                      color: AppColors.textMuted,
                    )
                  : null,
            ),
            obscureText: true,
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textPrimary),
          ),
        ),
        const SizedBox(height: 6),
        Text(widget.helpText,
            style: GoogleFonts.inter(
                fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }
}

// ─── Clean Text Field ──────────────────────────────────────────

class _CleanTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final ValueChanged<String>? onChanged;

  const _CleanTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: InputBorder.none,
          labelStyle: GoogleFonts.inter(
              fontSize: 11, color: AppColors.textMuted),
          hintStyle: GoogleFonts.inter(
              fontSize: 13, color: AppColors.textDisabled),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        style: GoogleFonts.inter(
            fontSize: 14, color: AppColors.textPrimary),
      ),
    );
  }
}
