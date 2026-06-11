import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/design/anchor_theme.dart';
import '../../../core/platform/native_bridge.dart';
import '../models/streak_widget_data.dart';
import '../models/wallpaper_config.dart';

class WallpaperRenderer {
  WallpaperRenderer._();

  /// Generates a wallpaper image from current streak data and background
  static Future<Uint8List> renderWallpaper({
    required StreakWallpaperConfig config,
    required StreakWidgetData data,
    required ui.Image backgroundImage,
  }) async {
    const double width = 1080;
    const double height = 1920;

    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);

    // 1. Draw Background Image (Aspect Fill)
    final double imgWidth = backgroundImage.width.toDouble();
    final double imgHeight = backgroundImage.height.toDouble();
    final double scaleX = width / imgWidth;
    final double scaleY = height / imgHeight;
    final double scale = math.max(scaleX, scaleY);
    final double dx = (width - imgWidth * scale) / 2;
    final double dy = (height - imgHeight * scale) / 2;

    canvas.drawImageRect(
      backgroundImage,
      Rect.fromLTWH(0, 0, imgWidth, imgHeight),
      Rect.fromLTWH(dx, dy, imgWidth * scale, imgHeight * scale),
      Paint()..isAntiAlias = true,
    );

    // 2. Draw Translucent Tint Overlay for Readability
    final double opacity = config.overlayOpacity;
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, width, height),
      Paint()..color = AnchorTheme.background.withOpacity(opacity),
    );

    // 3. Draw Streak Matrix (7 columns x 53 rows)
    final Color activeAccent = config.accentColor ?? AnchorTheme.accent;
    final double gridScale = config.gridScale;
    
    // Grid measurements
    const double baseDotSize = 20.0;
    const double baseSpacing = 8.0;
    final double dotSize = baseDotSize * gridScale;
    final double spacing = baseSpacing * gridScale;

    const int cols = 7;
    const int rows = 53; // 371 days

    final double gridWidth = cols * dotSize + (cols - 1) * spacing;
    final double gridHeight = rows * dotSize + (rows - 1) * spacing;

    // Center grid on screen
    final double gridX = (width - gridWidth) / 2 + config.gridOffset.dx;
    final double gridY = (height - gridHeight) / 2 + config.gridOffset.dy;

    // Generate historical completion representation matching percentage & last 7 days
    final List<bool> completions = List.filled(rows * cols, false);
    final int completedCount = ((rows * cols) * (data.percentage / 100.0)).toInt();
    
    // Seed last 7 days at the end of the grid
    final int lastIndex = completions.length - 1;
    for (int i = 0; i < 7; i++) {
      if (i < data.last7Days.length) {
        completions[lastIndex - (6 - i)] = data.last7Days[i];
      }
    }

    int remainingToFill = completedCount - data.last7Days.where((x) => x).length;
    if (remainingToFill > 0) {
      final rand = math.Random(1337); // stable seed for rendering layout
      for (int i = 0; i < completions.length - 7 && remainingToFill > 0; i++) {
        if (rand.nextDouble() < (data.percentage / 100.0)) {
          completions[i] = true;
          remainingToFill--;
        }
      }
      for (int i = 0; i < completions.length - 7 && remainingToFill > 0; i++) {
        if (!completions[i]) {
          completions[i] = true;
          remainingToFill--;
        }
      }
    }

    final Paint glowPaint = Paint()
      ..color = activeAccent.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12.0);

    final Paint activePaint = Paint()
      ..color = activeAccent
      ..isAntiAlias = true;

    final Paint inactivePaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2.0 * gridScale
      ..isAntiAlias = true;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final int index = r * cols + c;
        final double x = gridX + c * (dotSize + spacing);
        final double y = gridY + r * (dotSize + spacing);

        final Rect dotRect = Rect.fromLTWH(x, y, dotSize, dotSize);
        final RRect roundedDot = RRect.fromRectAndRadius(dotRect, Radius.circular(4.0 * gridScale));

        if (completions[index]) {
          // Draw outer glow shadow
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(x - 4 * gridScale, y - 4 * gridScale, dotSize + 8 * gridScale, dotSize + 8 * gridScale),
              Radius.circular(6.0 * gridScale),
            ),
            glowPaint,
          );
          // Draw solid dot
          canvas.drawRRect(roundedDot, activePaint);
        } else {
          canvas.drawRRect(roundedDot, inactivePaint);
        }
      }
    }

    // 4. Draw Header/Footer Text Overlay
    if (config.showText) {
      final ui.ParagraphBuilder titleBuilder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textAlign: ui.TextAlign.center,
          fontWeight: ui.FontWeight.bold,
          fontSize: 48.0,
        ),
      )
        ..pushStyle(ui.TextStyle(color: Colors.white, fontFamily: 'Inter'))
        ..addText(data.habitName.toUpperCase());

      final ui.Paragraph titleParagraph = titleBuilder.build()
        ..layout(const ui.ParagraphConstraints(width: width));

      final ui.ParagraphBuilder subtitleBuilder = ui.ParagraphBuilder(
        ui.ParagraphStyle(
          textAlign: ui.TextAlign.center,
          fontWeight: ui.FontWeight.w600,
          fontSize: 36.0,
        ),
      )
        ..pushStyle(ui.TextStyle(color: activeAccent, fontFamily: 'Inter'))
        ..addText("${data.daysLeft}d left")
        ..pushStyle(ui.TextStyle(color: Colors.white.withOpacity(0.5)))
        ..addText(" · ")
        ..pushStyle(ui.TextStyle(color: Colors.white.withOpacity(0.9)))
        ..addText("${data.percentage.toInt()}% complete");

      final ui.Paragraph subtitleParagraph = subtitleBuilder.build()
        ..layout(const ui.ParagraphConstraints(width: width));

      // Calculate placement height
      double textY = height - 300; // bottom default
      if (config.textAlignment == TextAlignment.top) {
        textY = 150;
      } else if (config.textAlignment == TextAlignment.center) {
        textY = gridY - 180;
      }

      // Draw background pill behind text for readability
      final double containerHeight = titleParagraph.height + subtitleParagraph.height + 40;
      final Rect textBgRect = Rect.fromLTWH(50, textY - 20, width - 100, containerHeight);
      canvas.drawRRect(
        RRect.fromRectAndRadius(textBgRect, const Radius.circular(16)),
        Paint()..color = AnchorTheme.backgroundDeep.withOpacity(0.6),
      );

      canvas.drawParagraph(titleParagraph, Offset(0, textY));
      canvas.drawParagraph(subtitleParagraph, Offset(0, textY + titleParagraph.height + 10));
    }

    final ui.Picture picture = recorder.endRecording();
    final ui.Image renderedImage = await picture.toImage(width.toInt(), height.toInt());
    final ByteData? byteData = await renderedImage.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  /// Sets the lock or home screen wallpaper via the platform MethodChannel
  static Future<bool> setSystemWallpaper(String filePath, WallpaperType type) async {
    try {
      final String typeStr = type == WallpaperType.lockScreen 
          ? "lock" 
          : (type == WallpaperType.homeScreen ? "home" : "both");
      
      final bool? success = await NativeBridge.wallpaperChannel.invokeMethod<bool>('setWallpaper', {
        'path': filePath,
        'type': typeStr,
      });
      return success ?? false;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Utility to helper save Uint8List data to a temporary file
  static Future<String> saveTempWallpaper(Uint8List bytes) async {
    final Directory tempDir = await getTemporaryDirectory();
    final String path = "${tempDir.path}/rendered_wallpaper_${DateTime.now().millisecondsSinceEpoch}.png";
    final File file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }
}
