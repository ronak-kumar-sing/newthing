import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';

import '../../core/design/anchor_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../core/widgets/anchor_background.dart';
import '../../data/local/database.dart';
import '../../providers/api_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/settings_provider.dart';
import '../../features/streak/services/widget_sync_service.dart';

// ─── Custom Bouncing Gesture Wrapper ───────────────────────────────────────
class BouncingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  const BouncingButton({super.key, required this.child, this.onTap});

  @override
  State<BouncingButton> createState() => _BouncingButtonState();
}

class _BouncingButtonState extends State<BouncingButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onTap != null) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (widget.onTap != null) setState(() => _isPressed = false);
      },
      onTapCancel: () {
        if (widget.onTap != null) setState(() => _isPressed = false);
      },
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _ModelItem {
  final String name;
  final String description;
  final String value;
  const _ModelItem({required this.name, required this.description, required this.value});
}

const _models = [
  _ModelItem(name: '2.0 Flash', description: 'Fast', value: 'gemini-2.0-flash'),
  _ModelItem(name: '2.5 Flash', description: 'Balanced', value: 'gemini-2.5-flash'),
  _ModelItem(name: '2.5 Pro', description: 'Powerful', value: 'gemini-2.5-pro'),
];

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController todoistKeyController;
  late final TextEditingController geminiKeyController;
  late final TextEditingController goalTitleController;
  late final TextEditingController nameController;
  late final TextEditingController cityController;

  DateTime? _independenceDate;
  int limitMinutes = 120;
  String _selectedModel = 'gemini-2.5-flash';

  bool _isSaving = false;
  bool? _todoistStatus; // null=untested, true=ok, false=fail
  bool? _geminiStatus;
  bool _testingTodoist = false;
  bool _testingGemini = false;
  Timer? _sliderDebounce;

  @override
  void initState() {
    super.initState();
    todoistKeyController = TextEditingController();
    geminiKeyController = TextEditingController();
    goalTitleController = TextEditingController();
    nameController = TextEditingController();
    cityController = TextEditingController();
    _loadSettings();
  }

  @override
  void dispose() {
    todoistKeyController.dispose();
    geminiKeyController.dispose();
    goalTitleController.dispose();
    nameController.dispose();
    cityController.dispose();
    _sliderDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await ref.read(settingsDaoProvider).getSettings();
    setState(() {
      todoistKeyController.text = settings.todoistApiToken ?? '';
      geminiKeyController.text = settings.geminiApiKey ?? '';
      goalTitleController.text = settings.independenceLabel ?? '';
      nameController.text = settings.userName ?? '';
      cityController.text = settings.weatherCity ?? '';
      _independenceDate = settings.independenceDate;
      limitMinutes = settings.distractionLimitMinutes;
      _selectedModel = settings.geminiModel;
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    final dao = ref.read(settingsDaoProvider);
    await dao.updateSettings(AppSettingsCompanion(
      todoistApiToken: Value(todoistKeyController.text),
      geminiApiKey: Value(geminiKeyController.text),
      userName: Value(nameController.text),
      weatherCity: Value(cityController.text),
      independenceLabel: Value(goalTitleController.text),
      distractionLimitMinutes: Value(limitMinutes),
      geminiModel: Value(_selectedModel),
    ));

    if (_independenceDate != null) {
      await dao.updateTargetDate(_independenceDate!);
    }

    // Apply to live API clients
    ref.read(todoistApiProvider).setToken(todoistKeyController.text);
    ref.read(geminiApiProvider)
      ..setApiKey(geminiKeyController.text)
      ..setModel(_selectedModel);

    ref.invalidate(settingsProvider);
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Settings saved ✓',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: const Color(0xFFC6F52C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _testTodoist() async {
    if (todoistKeyController.text.isEmpty) return;
    setState(() => _testingTodoist = true);
    ref.read(todoistApiProvider).setToken(todoistKeyController.text);
    final ok = await ref.read(todoistApiProvider).testConnection();
    setState(() {
      _todoistStatus = ok;
      _testingTodoist = false;
    });
  }

  Future<void> _testGemini() async {
    if (geminiKeyController.text.isEmpty) return;
    setState(() => _testingGemini = true);
    ref.read(geminiApiProvider)
      ..setApiKey(geminiKeyController.text)
      ..setModel(_selectedModel);
    final (ok, errorMsg) = await ref.read(geminiApiProvider).testConnectionWithDetails();
    setState(() {
      _geminiStatus = ok;
      _testingGemini = false;
    });
    if (!ok && errorMsg != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF2A1A1A),
          duration: const Duration(seconds: 4),
          content: Text(
            'Gemini: $errorMsg',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ),
      );
    }
  }

  Future<void> _loadFromEnvFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.any,
      );
      if (result == null || result.files.single.path == null) return;

      final file = File(result.files.single.path!);
      final lines = await file.readAsLines();

      final envData = <String, String>{};
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
        final parts = trimmed.split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          final val = parts.sublist(1).join('=').trim().replaceAll('"', '').replaceAll("'", "");
          envData[key] = val;
        }
      }

      setState(() {
        if (envData.containsKey('TODOIST_API_TOKEN')) {
          todoistKeyController.text = envData['TODOIST_API_TOKEN']!;
        }
        if (envData.containsKey('GEMINI_API_KEY')) {
          geminiKeyController.text = envData['GEMINI_API_KEY']!;
        }
        if (envData.containsKey('USER_NAME')) {
          nameController.text = envData['USER_NAME']!;
        }
        if (envData.containsKey('WEATHER_CITY')) {
          cityController.text = envData['WEATHER_CITY']!;
        }
        if (envData.containsKey('INDEPENDENCE_LABEL')) {
          goalTitleController.text = envData['INDEPENDENCE_LABEL']!;
        }
        if (envData.containsKey('INDEPENDENCE_DATE')) {
          try {
            _independenceDate = DateTime.parse(envData['INDEPENDENCE_DATE']!);
          } catch (_) {}
        }
        if (envData.containsKey('DISTRACTION_LIMIT_MINUTES')) {
          final limit = int.tryParse(envData['DISTRACTION_LIMIT_MINUTES']!);
          if (limit != null) {
            limitMinutes = limit;
          }
        }
        if (envData.containsKey('GEMINI_MODEL')) {
          _selectedModel = envData['GEMINI_MODEL']!;
        }

        _todoistStatus = null;
        _geminiStatus = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Loaded from .env ✓',
              style: GoogleFonts.spaceGrotesk(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFFC6F52C),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load .env: $e', style: GoogleFonts.inter(fontSize: 13, color: Colors.white)),
            backgroundColor: AnchorTheme.statusRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = _independenceDate != null
        ? DateFormat('MMM dd, yyyy').format(_independenceDate!)
        : 'Select Date';

    final hours = limitMinutes ~/ 60;
    final mins = limitMinutes % 60;
    final formattedLimit = '${hours}h ${mins.toString().padLeft(2, '0')}m';

    return Scaffold(
      backgroundColor: AnchorTheme.backgroundDeep,
      body: AnchorBackground(
        child: Column(
          children: [
            // ── Top Bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text(
                    'Settings',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  BouncingButton(
                    onTap: _loadFromEnvFile,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white.withOpacity(0.25)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Text(
                        'Load .env',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  BouncingButton(
                    onTap: _isSaving ? null : _saveSettings,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFC6F52C),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: _isSaving
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : Text(
                              'Save',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.08),
            ),
            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── API Keys Section ──
                    _buildSectionHeader('API KEYS'),
                    GlassCard(
                      variant: GlassVariant.surface,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Todoist Key
                          Text(
                            'Todoist API Key',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D0D0D),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white.withOpacity(0.10)),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: TextField(
                                    controller: todoistKeyController,
                                    obscureText: true,
                                    style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 14),
                                    decoration: const InputDecoration.collapsed(hintText: ''),
                                    onChanged: (_) => setState(() => _todoistStatus = null),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              BouncingButton(
                                onTap: _testingTodoist ? null : _testTodoist,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFC6F52C)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: _testingTodoist
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC6F52C)),
                                        )
                                      : Text(
                                          'Test',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFFC6F52C),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _todoistStatus == null
                                      ? Colors.white.withOpacity(0.25)
                                      : (_todoistStatus! ? const Color(0xFF4ADE80) : const Color(0xFFFF4444)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: _todoistStatus == null
                                      ? Colors.white.withOpacity(0.35)
                                      : (_todoistStatus! ? const Color(0xFF4ADE80) : const Color(0xFFFF4444)),
                                ),
                                child: Text(_todoistStatus == null
                                    ? "Not tested"
                                    : (_todoistStatus! ? "Connected" : "Not connected")),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),
                          Divider(height: 24, color: Colors.white.withOpacity(0.07)),
                          const SizedBox(height: 8),

                          // Gemini Key
                          Text(
                            'Gemini API Key',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0D0D0D),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white.withOpacity(0.10)),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  child: TextField(
                                    controller: geminiKeyController,
                                    obscureText: true,
                                    style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 14),
                                    decoration: const InputDecoration.collapsed(hintText: ''),
                                    onChanged: (_) => setState(() => _geminiStatus = null),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              BouncingButton(
                                onTap: _testingGemini ? null : _testGemini,
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFC6F52C)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: _testingGemini
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFC6F52C)),
                                        )
                                      : Text(
                                          'Test',
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFFC6F52C),
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _geminiStatus == null
                                      ? Colors.white.withOpacity(0.25)
                                      : (_geminiStatus! ? const Color(0xFF4ADE80) : const Color(0xFFFF4444)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: _geminiStatus == null
                                      ? Colors.white.withOpacity(0.35)
                                      : (_geminiStatus! ? const Color(0xFF4ADE80) : const Color(0xFFFF4444)),
                                ),
                                child: Text(_geminiStatus == null
                                    ? "Not tested"
                                    : (_geminiStatus! ? "Connected" : "Not connected")),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0, duration: 300.ms),

                    // ── Gemini Model Section ──
                    _buildSectionHeader('GEMINI MODEL'),
                    Row(
                      children: _models.map((model) {
                        final isSelected = _selectedModel == model.value;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _selectedModel = model.value;
                              _geminiStatus = null;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.transparent : const Color(0xFF141414),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? const Color(0xFFC6F52C) : Colors.white.withOpacity(0.12),
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              padding: const EdgeInsets.all(14),
                              child: Stack(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        model.name,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected ? const Color(0xFFC6F52C) : Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        model.description,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: Colors.white.withOpacity(0.35),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isSelected)
                                    const Positioned(
                                      top: 6,
                                      right: 0,
                                      child: Icon(Icons.check, size: 14, color: Color(0xFFC6F52C)),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ).animate(delay: 80.ms).fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0, duration: 300.ms),

                    // ── Independence Goal Section ──
                    _buildSectionHeader('INDEPENDENCE GOAL'),
                    GlassCard(
                      variant: GlassVariant.surface,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Goal Title',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.55),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D0D0D),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white.withOpacity(0.10)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: TextField(
                              controller: goalTitleController,
                              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                              decoration: const InputDecoration.collapsed(hintText: 'e.g. Financial Freedom'),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Target Date',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.55),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final date = await showDatePicker(
                                context: context,
                                initialDate: _independenceDate ?? DateTime.now().add(const Duration(days: 365)),
                                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                                builder: (context, child) => Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: Color(0xFFC6F52C),
                                      onPrimary: Colors.black,
                                      surface: Color(0xFF141414),
                                      onSurface: Colors.white,
                                    ),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (date != null) {
                                setState(() => _independenceDate = date);
                                // Immediate target date update
                                await ref.read(settingsDaoProvider).updateTargetDate(date);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF141414),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white.withOpacity(0.12)),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    formattedDate,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Spacer(),
                                  const Text('📅', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 160.ms).fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0, duration: 300.ms),

                    // ── Personal Section ──
                    _buildSectionHeader('PERSONAL'),
                    GlassCard(
                      variant: GlassVariant.surface,
                      padding: const EdgeInsets.all(20),
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
                                      'Name',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.55),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0D0D0D),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.white.withOpacity(0.10)),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      child: TextField(
                                        controller: nameController,
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                                        decoration: const InputDecoration.collapsed(hintText: ''),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'City',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white.withOpacity(0.55),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0D0D0D),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.white.withOpacity(0.10)),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      child: TextField(
                                        controller: cityController,
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                                        decoration: const InputDecoration.collapsed(hintText: ''),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                'Daily Limit',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A2200),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  formattedLimit,
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFC6F52C),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: const Color(0xFFC6F52C),
                              inactiveTrackColor: Colors.white.withOpacity(0.10),
                              thumbColor: const Color(0xFFC6F52C),
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                              overlayColor: const Color(0xFFC6F52C).withOpacity(0.15),
                              trackHeight: 5,
                              showValueIndicator: ShowValueIndicator.always,
                              valueIndicatorColor: const Color(0xFF1E2200),
                              valueIndicatorTextStyle: GoogleFonts.spaceGrotesk(
                                color: const Color(0xFFC6F52C),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: Slider(
                              value: limitMinutes.toDouble(),
                              min: 30,
                              max: 360,
                              divisions: 11,
                              label: formattedLimit,
                              onChanged: (v) {
                                setState(() {
                                  limitMinutes = v.round();
                                });
                                _sliderDebounce?.cancel();
                                _sliderDebounce = Timer(const Duration(milliseconds: 300), () {
                                  ref.read(settingsDaoProvider).updateSettings(AppSettingsCompanion(
                                    distractionLimitMinutes: Value(limitMinutes),
                                  ));
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 240.ms).fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0, duration: 300.ms),

                    // ── Home Widget Section ──
                    _buildSectionHeader('HOME WIDGET'),
                    GlassCard(
                      variant: GlassVariant.surface,
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Streak Widget',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Add your Anchor Streak widget directly to your home screen to keep your focus front and center.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.55),
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFC6F52C)),
                                foregroundColor: const Color(0xFFC6F52C),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              onPressed: () async {
                                final success = await WidgetSyncService.pinStreakWidget();
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        success ? 'Widget pin requested ✓' : 'Failed to request widget pin. You may need to add it manually.',
                                        style: GoogleFonts.inter(fontSize: 13, color: Colors.black),
                                      ),
                                      backgroundColor: success ? const Color(0xFFC6F52C) : const Color(0xFFFFB4AB),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                "Pin to Home Screen",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 300.ms).fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0, duration: 300.ms),
                  ],
                ),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms, curve: Curves.easeOut),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Text(
        title,
        style: GoogleFonts.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white.withOpacity(0.40),
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}
