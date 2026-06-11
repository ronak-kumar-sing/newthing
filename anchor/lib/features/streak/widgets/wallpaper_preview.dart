import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/design/anchor_theme.dart';
import '../../../core/theme/slice_spacing.dart';
import '../models/streak_widget_data.dart';
import '../models/wallpaper_config.dart';
import '../services/wallpaper_renderer.dart';

class WallpaperPreviewScreen extends StatefulWidget {
  final StreakWidgetData streakData;

  const WallpaperPreviewScreen({
    super.key,
    required this.streakData,
  });

  @override
  State<WallpaperPreviewScreen> createState() => _WallpaperPreviewScreenState();
}

class _WallpaperPreviewScreenState extends State<WallpaperPreviewScreen> {
  // Config state
  WallpaperType _wallpaperType = WallpaperType.homeScreen;
  double _gridScale = 1.0;
  TextAlignment _textAlignment = TextAlignment.bottom;
  double _overlayOpacity = 0.4;
  
  File? _selectedImageFile;
  ui.Image? _loadedBgImage;
  Uint8List? _previewBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDefaultWallpaper();
  }

  Future<void> _loadDefaultWallpaper() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final ui.Image placeholder = await _generatePlaceholderBg();
      _loadedBgImage = placeholder;
      await _generatePreview();
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<ui.Image> _generatePlaceholderBg() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const double w = 1080;
    const double h = 1920;

    // Gradient fill
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        const Offset(w / 2, h / 2),
        w * 0.9,
        [
          const Color(0xFF1E1E2F),
          const Color(0xFF0C0C14),
          const Color(0xFF030303),
        ],
        [0.0, 0.65, 1.0],
      );
    canvas.drawRect(const Rect.fromLTWH(0, 0, w, h), paint);

    // Dynamic decorative orbs
    final paintOrb1 = Paint()
      ..color = const Color(0xFFC6F52C).withOpacity(0.05) // Lime
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 120);
    canvas.drawCircle(const Offset(200, 400), 300, paintOrb1);

    final paintOrb2 = Paint()
      ..color = const Color(0xFFCC00CC).withOpacity(0.04) // Purple/Magenta
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 180);
    canvas.drawCircle(const Offset(900, 1600), 400, paintOrb2);

    final picture = recorder.endRecording();
    return await picture.toImage(w.toInt(), h.toInt());
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _isLoading = true;
      });
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      
      setState(() {
        _selectedImageFile = file;
        _loadedBgImage = frame.image;
      });
      await _generatePreview();
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePreview() async {
    if (_loadedBgImage == null) return;
    
    final config = StreakWallpaperConfig(
      type: _wallpaperType,
      gridScale: _gridScale,
      textAlignment: _textAlignment,
      overlayOpacity: _overlayOpacity,
      accentColor: AnchorTheme.accent,
    );

    final bytes = await WallpaperRenderer.renderWallpaper(
      config: config,
      data: widget.streakData,
      backgroundImage: _loadedBgImage!,
    );

    setState(() {
      _previewBytes = bytes;
    });
  }

  Future<void> _applyWallpaper() async {
    if (_previewBytes == null) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final tempPath = await WallpaperRenderer.saveTempWallpaper(_previewBytes!);
      final success = await WallpaperRenderer.setSystemWallpaper(tempPath, _wallpaperType);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
                ? "Wallpaper applied successfully!" 
                : "Failed to apply wallpaper directly. Save to gallery and set manually."),
            backgroundColor: success ? AnchorTheme.statusGreen : AnchorTheme.statusRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("An error occurred while setting the wallpaper."),
            backgroundColor: AnchorTheme.statusRed,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AnchorTheme.background,
      appBar: AppBar(
        title: Text(
          'WALLPAPER ENGINE',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Preview Panel (rounded phone frame preview)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AnchorTheme.backgroundDeep,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(color: AnchorTheme.cardBorder, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          if (_previewBytes != null)
                            Positioned.fill(
                              child: Image.memory(
                                _previewBytes!,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation(AnchorTheme.accent),
                              ),
                            ),
                          if (_isLoading)
                            Container(
                              color: Colors.black.withOpacity(0.4),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(AnchorTheme.accent),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Configurations Panel
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AnchorTheme.cardBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: AnchorTheme.cardBorder, width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Select Image preset / custom
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Background Image',
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                      ),
                      TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image_outlined, size: 18),
                        label: const Text('Choose Photo'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Wallpaper type target selector
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Target Screen',
                          style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
                        ),
                      ),
                      DropdownButton<WallpaperType>(
                        value: _wallpaperType,
                        dropdownColor: AnchorTheme.cardBgHigh,
                        underline: const SizedBox(),
                        style: theme.textTheme.bodyMedium?.copyWith(color: AnchorTheme.accent),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _wallpaperType = val;
                            });
                            _generatePreview();
                          }
                        },
                        items: const [
                          DropdownMenuItem(
                            value: WallpaperType.homeScreen,
                            child: Text('Home Screen'),
                          ),
                          DropdownMenuItem(
                            value: WallpaperType.lockScreen,
                            child: Text('Lock Screen'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Divider(color: AnchorTheme.rimBottom, height: 24),

                  // Grid Scale slider
                  Row(
                    children: [
                      Text(
                        'Grid Scale',
                        style: theme.textTheme.bodyMedium?.copyWith(color: AnchorTheme.textSecondary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Slider(
                          value: _gridScale,
                          min: 0.6,
                          max: 1.4,
                          activeColor: AnchorTheme.accent,
                          inactiveColor: Colors.white.withOpacity(0.1),
                          onChanged: (val) {
                            setState(() {
                              _gridScale = val;
                            });
                          },
                          onChangeEnd: (_) => _generatePreview(),
                        ),
                      ),
                    ],
                  ),

                  // Overlay Opacity slider
                  Row(
                    children: [
                      Text(
                        'Dim Background',
                        style: theme.textTheme.bodyMedium?.copyWith(color: AnchorTheme.textSecondary),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Slider(
                          value: _overlayOpacity,
                          min: 0.1,
                          max: 0.9,
                          activeColor: AnchorTheme.accent,
                          inactiveColor: Colors.white.withOpacity(0.1),
                          onChanged: (val) {
                            setState(() {
                              _overlayOpacity = val;
                            });
                          },
                          onChangeEnd: (_) => _generatePreview(),
                        ),
                      ),
                    ],
                  ),

                  // Text Alignment picker
                  Row(
                    children: [
                      Text(
                        'Text Position',
                        style: theme.textTheme.bodyMedium?.copyWith(color: AnchorTheme.textSecondary),
                      ),
                      const Spacer(),
                      ToggleButtons(
                        isSelected: [
                          _textAlignment == TextAlignment.top,
                          _textAlignment == TextAlignment.center,
                          _textAlignment == TextAlignment.bottom,
                        ],
                        onPressed: (index) {
                          setState(() {
                            _textAlignment = index == 0
                                ? TextAlignment.top
                                : index == 1
                                    ? TextAlignment.center
                                    : TextAlignment.bottom;
                          });
                          _generatePreview();
                        },
                        fillColor: AnchorTheme.accent.withOpacity(0.1),
                        selectedColor: AnchorTheme.accent,
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(8),
                        borderColor: AnchorTheme.cardBorder,
                        selectedBorderColor: AnchorTheme.accent,
                        children: const [
                          Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Top')),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Mid')),
                          Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Bot')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Apply button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _applyWallpaper,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AnchorTheme.accent,
                      foregroundColor: AnchorTheme.background,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(AnchorTheme.background),
                            ),
                          )
                        : Text(
                            'APPLY WALLPAPER',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: AnchorTheme.background,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
