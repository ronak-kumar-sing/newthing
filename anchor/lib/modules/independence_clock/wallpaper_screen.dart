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
import 'package:file_picker/file_picker.dart';

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

  // Unified configurations state
  String _mode = 'color'; // 'color' or 'image'
  String _imagePath = '';
  double _gridScale = 1.0;
  double _overlayOpacity = 0.4;
  String _textAlignment = 'bottom'; // 'top', 'center', 'bottom'
  String _targetScreen = 'both'; // 'home', 'lock', 'both'

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
      _mode = prefs.getString('anchor_wallpaper_mode') ?? 'color';
      _imagePath = prefs.getString('anchor_wallpaper_image_path') ?? '';
      _gridScale = prefs.getDouble('anchor_wallpaper_grid_scale') ?? 1.0;
      _overlayOpacity = prefs.getDouble('anchor_wallpaper_overlay_opacity') ?? 0.4;
      _textAlignment = prefs.getString('anchor_wallpaper_text_alignment') ?? 'bottom';
      _targetScreen = prefs.getString('anchor_wallpaper_target') ?? 'both';
    });
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    }
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
      // Save all active configurations to SharedPrefs for background task execution
      await prefs.setInt('anchor_wallpaper_bg_color', _bgColor.value);
      await prefs.setString('anchor_wallpaper_mode', _mode);
      await prefs.setString('anchor_wallpaper_image_path', _imagePath);
      await prefs.setDouble('anchor_wallpaper_grid_scale', _gridScale);
      await prefs.setDouble('anchor_wallpaper_overlay_opacity', _overlayOpacity);
      await prefs.setString('anchor_wallpaper_text_alignment', _textAlignment);
      await prefs.setString('anchor_wallpaper_target', _targetScreen);

      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day + 1, 0, 2, 0);
      final delay = midnight.difference(now);

      if (Platform.isAndroid) {
        await wm.Workmanager().registerPeriodicTask(
          "anchor_wallpaper_midnight",
          "applyWallpaper",
          frequency: const Duration(hours: 24),
          initialDelay: delay,
          existingWorkPolicy: wm.ExistingPeriodicWorkPolicy.update,
          constraints: wm.Constraints(networkType: wm.NetworkType.notRequired),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            Platform.isAndroid
                ? "Next update at ${midnight.hour.toString().padLeft(2, '0')}:00 ✓"
                : "Auto-update set (runs on Android only) ✓",
            style: AnchorTheme.body(14),
          ),
          backgroundColor: const Color(0xFF1A2200),
        ));
      }
    } else {
      if (Platform.isAndroid) {
        await wm.Workmanager().cancelByUniqueName("anchor_wallpaper_midnight");
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        setState(() {
          _imagePath = path;
          _mode = 'image';
        });
        await _updateSetting('anchor_wallpaper_image_path', path);
        await _updateSetting('anchor_wallpaper_mode', 'image');
      }
    } catch (e) {
      debugPrint('Error picking background file: $e');
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

      if (!Platform.isAndroid) {
        throw Exception("Setting wallpaper programmatically is only supported on Android. Save the image and apply manually.");
      }

      int target = WallpaperManagerFlutter.bothScreens;
      if (_targetScreen == 'home') {
        target = WallpaperManagerFlutter.homeScreen;
      } else if (_targetScreen == 'lock') {
        target = WallpaperManagerFlutter.lockScreen;
      }

      await WallpaperManagerFlutter().setWallpaper(
        file,
        target,
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
          setState(() {
            _bgColor = c;
            _mode = 'color';
          });
          _updateSetting('anchor_wallpaper_bg_color', c.value);
          _updateSetting('anchor_wallpaper_mode', 'color');
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
            // 1. TOP BAR
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

            const SizedBox(height: 12),

            // 2. WALLPAPER PREVIEW
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 8),
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
                        mode: _mode,
                        imagePath: _imagePath,
                        gridScale: _gridScale,
                        overlayOpacity: _overlayOpacity,
                        textAlignment: _textAlignment,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 3. SCROLLABLE CONFIGURATIONS PANEL
            Container(
              height: 240,
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.08), width: 1)),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // A. Background Mode selection
                    Row(
                      children: [
                        Text("Bg Style:", style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        ToggleButtons(
                          constraints: const BoxConstraints(minHeight: 28, minWidth: 80),
                          isSelected: [_mode == 'color', _mode == 'image'],
                          onPressed: (idx) {
                            setState(() {
                              _mode = idx == 0 ? 'color' : 'image';
                            });
                            _updateSetting('anchor_wallpaper_mode', _mode);
                          },
                          fillColor: const Color(0xFFC6F52C).withOpacity(0.12),
                          selectedColor: const Color(0xFFC6F52C),
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                          borderColor: Colors.white.withOpacity(0.08),
                          selectedBorderColor: const Color(0xFFC6F52C),
                          children: [
                            Text("Solid", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                            Text("Photo", style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(width: 8),
                        if (_mode == 'color')
                          IconButton(
                            icon: const Icon(Icons.color_lens, color: Colors.white, size: 20),
                            onPressed: _pickBackground,
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.image, color: Colors.white, size: 20),
                            onPressed: _pickImage,
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // B. Custom Image name if chosen
                    if (_mode == 'image' && _imagePath.isNotEmpty) ...[
                      Row(
                        children: [
                          const Icon(Icons.file_present_rounded, color: Colors.white54, size: 14),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _imagePath.split('/').last,
                              style: GoogleFonts.plusJakartaSans(color: Colors.white38, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],

                    // C. Target Screen selection
                    Row(
                      children: [
                        Text("Apply To:", style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        DropdownButton<String>(
                          dropdownColor: const Color(0xFF161616),
                          value: _targetScreen,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                          items: [
                            DropdownMenuItem(value: 'home', child: Text("Home Screen", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12))),
                            DropdownMenuItem(value: 'lock', child: Text("Lock Screen", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12))),
                            DropdownMenuItem(value: 'both', child: Text("Both Screens", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12))),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _targetScreen = val);
                              _updateSetting('anchor_wallpaper_target', val);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // D. Sliders: Grid Scale
                    Row(
                      children: [
                        Text("Grid Scale (x${_gridScale.toStringAsFixed(1)}):", style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 13)),
                        Expanded(
                          child: Slider(
                            value: _gridScale,
                            min: 0.6,
                            max: 1.4,
                            activeColor: const Color(0xFFC6F52C),
                            inactiveColor: Colors.white.withOpacity(0.08),
                            onChanged: (v) {
                              setState(() => _gridScale = v);
                            },
                            onChangeEnd: (v) => _updateSetting('anchor_wallpaper_grid_scale', v),
                          ),
                        ),
                      ],
                    ),

                    // E. Sliders: Dim Opacity
                    Row(
                      children: [
                        Text("Dim Bg (${(_overlayOpacity * 100).round()}%):", style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 13)),
                        Expanded(
                          child: Slider(
                            value: _overlayOpacity,
                            min: 0.1,
                            max: 0.9,
                            activeColor: const Color(0xFFC6F52C),
                            inactiveColor: Colors.white.withOpacity(0.08),
                            onChanged: (v) {
                              setState(() => _overlayOpacity = v);
                            },
                            onChangeEnd: (v) => _updateSetting('anchor_wallpaper_overlay_opacity', v),
                          ),
                        ),
                      ],
                    ),

                    // F. Text Position
                    Row(
                      children: [
                        Text("Text Position:", style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        ToggleButtons(
                          constraints: const BoxConstraints(minHeight: 28, minWidth: 60),
                          isSelected: [_textAlignment == 'top', _textAlignment == 'center', _textAlignment == 'bottom'],
                          onPressed: (idx) {
                            setState(() {
                              _textAlignment = idx == 0 ? 'top' : (idx == 1 ? 'center' : 'bottom');
                            });
                            _updateSetting('anchor_wallpaper_text_alignment', _textAlignment);
                          },
                          fillColor: const Color(0xFFC6F52C).withOpacity(0.12),
                          selectedColor: const Color(0xFFC6F52C),
                          color: Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                          borderColor: Colors.white.withOpacity(0.08),
                          selectedBorderColor: const Color(0xFFC6F52C),
                          children: [
                            Text("Top", style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                            Text("Center", style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                            Text("Bottom", style: GoogleFonts.plusJakartaSans(fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // G. Auto Update Toggle Card
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Auto-update at midnight", style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 2),
                              Text("Updates daily at 12:00 AM on Android", style: GoogleFonts.plusJakartaSans(color: Colors.white30, fontSize: 11)),
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
