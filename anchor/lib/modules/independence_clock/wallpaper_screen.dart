import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:workmanager/workmanager.dart' as wm;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../core/design/anchor_theme.dart';
import '../../core/widgets/glass_card.dart';
import '../../providers/settings_provider.dart';
import 'wallpaper_canvas.dart';

class WallpaperScreen extends ConsumerStatefulWidget {
  const WallpaperScreen({super.key});
  @override
  ConsumerState<WallpaperScreen> createState() => _WallpaperScreenState();
}

class _WallpaperScreenState extends ConsumerState<WallpaperScreen> {
  Color _bgColor = const Color(0xFF0A0A0A);
  bool _applying = false;
  bool _autoUpdate = false;
  final GlobalKey _wallpaperKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoUpdate = prefs.getBool('anchor_wallpaper_auto') ?? false;
      _bgColor = Color(prefs.getInt('anchor_wallpaper_bg_color') ?? 0xFF0A0A0A);
    });
  }

  Future<bool> _requestWallpaperPermissions() async {
    bool confirmed = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF161616),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Text("🌅", style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text("Daily Wallpaper", style: AnchorTheme.display(18)),
          ],
        ),
        content: Text(
          "Anchor will update your wallpaper every day at 12:00 AM "
          "to show your latest countdown progress.\n\n"
          "This runs silently in the background.",
          style: AnchorTheme.label(14, color: Colors.white.withOpacity(0.70)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Not Now", style: AnchorTheme.label(14)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC6F52C),
            ),
            onPressed: () {
              confirmed = true;
              Navigator.pop(context);
            },
            child: Text("Allow", style: AnchorTheme.body(14, color: Colors.black)),
          ),
        ],
      ),
    );
    return confirmed;
  }

  Future<void> _toggleAutoUpdate(bool enabled) async {
    if (enabled) {
      final allowed = await _requestWallpaperPermissions();
      if (!allowed) return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('anchor_wallpaper_auto', enabled);
    setState(() => _autoUpdate = enabled);

    if (enabled) {
      await prefs.setInt('anchor_wallpaper_bg_color', _bgColor.value);
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day + 1, 0, 2, 0);
      final delay = midnight.difference(now);

      await wm.Workmanager().registerPeriodicTask(
        "anchor_wallpaper_midnight",
        "applyWallpaper",
        frequency: const Duration(hours: 24),
        initialDelay: delay,
        existingWorkPolicy: wm.ExistingPeriodicWorkPolicy.update,
        constraints: wm.Constraints(networkType: wm.NetworkType.notRequired),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            "Next update at ${midnight.hour.toString().padLeft(2, '0')}:00 ✓",
            style: AnchorTheme.body(14),
          ),
          backgroundColor: const Color(0xFF1A2200),
        ));
      }
    } else {
      await wm.Workmanager().cancelByUniqueName("anchor_wallpaper_midnight");
    }
  }

  Future<void> _applyWallpaper() async {
    setState(() => _applying = true);
    try {
      final boundary = _wallpaperKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception("Failed to render");

      final Uint8List bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/anchor_wallpaper.png');
      await file.writeAsBytes(bytes);

      await WallpaperManagerFlutter().setWallpaper(
        file,
        WallpaperManagerFlutter.bothScreens,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Wallpaper applied ✓", style: AnchorTheme.body(14)),
          backgroundColor: const Color(0xFF1A2200),
        ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Failed: $e"),
          backgroundColor: const Color(0xFF2A0000),
        ));
      }
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  void _pickBackground() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BackgroundPickerSheet(
        currentColor: _bgColor,
        onColorSelected: (c) {
          setState(() => _bgColor = c);
          if (_autoUpdate) {
            SharedPreferences.getInstance().then((prefs) {
              prefs.setInt('anchor_wallpaper_bg_color', c.value);
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider).valueOrNull;
    if (settings == null) return const Scaffold(backgroundColor: Color(0xFF050505));

    final now = DateTime.now();
    final endDate = settings.independenceDate;
    final totalDays = 365;
    final daysRemaining = endDate != null ? endDate.difference(now).inDays : 365;

    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: SafeArea(
        child: Column(
          children: [
            // TOP BAR
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 16),
                  Text("Wallpaper", style: AnchorTheme.display(20)),
                  const Spacer(),
                  GestureDetector(
                    onTap: _pickBackground,
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: _bgColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white.withOpacity(0.25)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text("Background", style: AnchorTheme.label(13)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC6F52C),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _applying ? null : _applyWallpaper,
                    child: _applying
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : Text(
                            "Apply Now",
                            style: GoogleFonts.spaceGrotesk(
                                fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black),
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // WALLPAPER PREVIEW
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: AspectRatio(
                  aspectRatio: 9 / 19.5,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: RepaintBoundary(
                      key: _wallpaperKey,
                      child: WallpaperCanvas(
                        daysRemaining: daysRemaining,
                        totalDays: totalDays,
                        goalTitle: settings.independenceLabel ?? 'Focus Goals',
                        backgroundColor: _bgColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // AUTO UPDATE TOGGLE
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: GlassCard(
                variant: GlassVariant.surface,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Auto-update at midnight", style: AnchorTheme.body(14)),
                          const SizedBox(height: 4),
                          Text("Updates wallpaper daily at 12:00 AM", style: AnchorTheme.label(12)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _autoUpdate,
                      activeColor: const Color(0xFFC6F52C),
                      onChanged: _toggleAutoUpdate,
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

class _BackgroundPickerSheet extends StatelessWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorSelected;

  static const _presets = [
    Color(0xFF0A0A0A),
    Color(0xFF0A1628),
    Color(0xFF14080A),
    Color(0xFF0D1408),
    Color(0xFF1A0A1A),
    Color(0xFF1A1400),
    Color(0xFF001414),
    Color(0xFF000000),
    Color(0xFF0D0D0D),
    Color(0xFF101020),
  ];

  const _BackgroundPickerSheet({
    required this.currentColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      variant: GlassVariant.floating,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text("Choose Background", style: AnchorTheme.display(18)),
          const SizedBox(height: 20),
          Text("Presets", style: AnchorTheme.label(12)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _presets.map((c) {
              return GestureDetector(
                onTap: () {
                  onColorSelected(c);
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: c == currentColor
                          ? const Color(0xFFC6F52C)
                          : Colors.white.withOpacity(0.15),
                      width: c == currentColor ? 2 : 1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.white.withOpacity(0.20)),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Color picked = currentColor;
              await showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  backgroundColor: const Color(0xFF161616),
                  title: Text("Custom Color", style: AnchorTheme.body(16)),
                  content: ColorPicker(
                    pickerColor: currentColor,
                    onColorChanged: (c) => picked = c,
                    hexInputBar: true,
                    labelTypes: const [],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel", style: AnchorTheme.label(14)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC6F52C),
                      ),
                      onPressed: () {
                        onColorSelected(picked);
                        Navigator.pop(context);
                        Navigator.pop(context); // close sheet too
                      },
                      child: Text("Apply", style: AnchorTheme.body(14, color: Colors.black)),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.color_lens_outlined, size: 16),
            label: Text("Custom Color", style: AnchorTheme.body(14)),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
        ],
      ),
    );
  }
}
