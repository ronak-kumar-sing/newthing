import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'core/constants/env_config.dart';
import 'core/services/background_service.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'data/local/database.dart';
import 'data/local/daos/journal_dao.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == "applyWallpaper") {
      await _backgroundApplyWallpaper();
    }
    return true;
  });
}

Future<void> _backgroundApplyWallpaper() async {
  AnchorDatabase? db;
  try {
    final prefs = await SharedPreferences.getInstance();

    final targetDateStr = prefs.getString('anchor_target_date') ?? '';
    final goalTitle     = prefs.getString('anchor_goal_title')  ?? 'My Goal';
    final bgColorInt    = prefs.getInt('anchor_wallpaper_bg_color') ?? 0xFF0A0A0A;
    final startDateStr  = prefs.getString('anchor_start_date')  ?? '';

    // New configurations
    final mode          = prefs.getString('anchor_wallpaper_mode') ?? 'color';
    final imagePath     = prefs.getString('anchor_wallpaper_image_path') ?? '';
    final gridScale     = prefs.getDouble('anchor_wallpaper_grid_scale') ?? 1.0;
    final overlayOpacity = prefs.getDouble('anchor_wallpaper_overlay_opacity') ?? 0.4;
    final textAlignment = prefs.getString('anchor_wallpaper_text_alignment') ?? 'bottom';
    final targetScreen  = prefs.getString('anchor_wallpaper_target') ?? 'both';

    if (targetDateStr.isEmpty) return;

    final targetDate = DateTime.parse(targetDateStr);
    final startDate  = startDateStr.isNotEmpty ? DateTime.parse(startDateStr) : DateTime.now();
    final now = DateTime.now();

    final daysRemaining = targetDate.difference(now).inDays.clamp(0, 9999);
    final totalDays     = targetDate.difference(startDate).inDays.clamp(1, 9999);
    final bgColor       = Color(bgColorInt);

    // Build actual check-in data from the database.
    db = AnchorDatabase();
    final journalDao = JournalDao(db);
    final entries = await journalDao.getEntriesForRange(startDate, now);
    final entryMap = {
      for (var e in entries)
        DateTime(e.date.year, e.date.month, e.date.day): e,
    };
    final completedDays = List<bool>.generate(totalDays, (i) {
      final date = startDate.add(Duration(days: i));
      final key = DateTime(date.year, date.month, date.day);
      final entry = entryMap[key];
      return entry != null && entry.focusRating != null && entry.focusRating! >= 3;
    });

    ui.Image? bgImage;
    if (mode == 'image' && imagePath.isNotEmpty && File(imagePath).existsSync()) {
      final bytes = await File(imagePath).readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      bgImage = frame.image;
    }

    final recorder = ui.PictureRecorder();
    final canvas    = Canvas(recorder);

    final screenW = prefs.getDouble('anchor_wallpaper_width') ?? 1080.0;
    final screenH = prefs.getDouble('anchor_wallpaper_height') ?? 2340.0;
    final W = screenW * 3.0; // render at high pixel density
    final H = screenH * 3.0;

    _paintWallpaperHeadless(
      canvas: canvas,
      w: W, h: H,
      daysRemaining: daysRemaining,
      totalDays: totalDays,
      completedDays: completedDays,
      goalTitle: goalTitle,
      bgColor: bgColor,
      bgImage: bgImage,
      gridScale: gridScale,
      overlayOpacity: overlayOpacity,
      textAlignment: textAlignment,
    );

    final picture = recorder.endRecording();
    final image   = await picture.toImage(W.round(), H.round());
    final bytes   = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return;

    final tempDir = await getTemporaryDirectory();
    final file    = File('${tempDir.path}/anchor_wallpaper_bg.png');
    await file.writeAsBytes(bytes.buffer.asUint8List());

    int target = WallpaperManagerFlutter.bothScreens;
    if (targetScreen == 'home') {
      target = WallpaperManagerFlutter.homeScreen;
    } else if (targetScreen == 'lock') {
      target = WallpaperManagerFlutter.lockScreen;
    }

    await WallpaperManagerFlutter().setWallpaper(file, target);

  } catch (e) {
    debugPrint('Background wallpaper error: $e');
  } finally {
    db?.close();
  }
}

void _paintWallpaperHeadless({
  required Canvas canvas,
  required double w, required double h,
  required int daysRemaining, required int totalDays,
  required List<bool> completedDays,
  required String goalTitle, required Color bgColor,
  ui.Image? bgImage,
  required double gridScale,
  required double overlayOpacity,
  required String textAlignment,
}) {
  // 1. Draw background
  if (bgImage != null) {
    final double imgW = bgImage.width.toDouble();
    final double imgH = bgImage.height.toDouble();
    final double scaleX = w / imgW;
    final double scaleY = h / imgH;
    final double scale = math.max(scaleX, scaleY);
    final double dx = (w - imgW * scale) / 2;
    final double dy = (h - imgH * scale) / 2;
    canvas.drawImageRect(
      bgImage,
      Rect.fromLTWH(0, 0, imgW, imgH),
      Rect.fromLTWH(dx, dy, imgW * scale, imgH * scale),
      Paint()..isAntiAlias = true,
    );
  } else {
    // Draw solid color gradient
    final paint = Paint()
      ..shader = ui.Gradient.radial(
        Offset(w / 2, h / 2),
        w * 0.9,
        [
          bgColor,
          Color.lerp(bgColor, Colors.black, 0.6)!,
          Colors.black,
        ],
        [0.0, 0.7, 1.0],
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint);
  }

  // 2. Draw Tint overlay
  canvas.drawRect(
    Rect.fromLTWH(0, 0, w, h),
    Paint()..color = Colors.black.withValues(alpha: overlayOpacity),
  );

  // 3. Draw Grid
  const int cols = 18;
  final int rows = totalDays > 0 ? (totalDays / cols).ceil() : 1;
  final double hMargin = w * 0.055;
  final double gridW = w - hMargin * 2;

  final double dotStep = gridW / cols;
  final double dotSize = (dotStep * 0.72) * gridScale;
  final double dotGap = (dotStep - dotStep * 0.72) * gridScale;

  final double actualGridW = cols * dotSize + (cols - 1) * dotGap;
  final double actualGridH = rows * dotSize + (rows - 1) * dotGap;
  final double gridY = (h - actualGridH) / 2;
  final double startX = (w - actualGridW) / 2;

  final Paint filledP = Paint()..color = const Color(0xFFC6F52C); // Anchor Lime Accent
  final Paint emptyP  = Paint()
    ..color = Colors.white.withValues(alpha: 0.12) // Subtle outline
    ..style = PaintingStyle.stroke
    ..strokeWidth = dotSize * 0.10;

  final double step = dotSize + dotGap;
  final double cornerR = dotSize * 0.28;

  final int completedCount = completedDays.where((c) => c).length;

  for (int i = 0; i < totalDays; i++) {
    int col = i % cols;
    int row = i ~/ cols;
    double x = startX + col * step;
    double y = gridY + row * step;

    if (y + dotSize > h) break;

    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, dotSize, dotSize),
      Radius.circular(cornerR));

    final bool isCompleted = i < completedDays.length && completedDays[i];
    if (isCompleted) {
      canvas.drawRRect(rr, filledP);
    } else {
      canvas.drawRRect(rr, emptyP);
    }
  }

  // 4. Draw Elegant Text (No clock months:days)
  double textY;
  if (textAlignment == 'top') {
    textY = h * 0.08;
  } else if (textAlignment == 'center') {
    textY = gridY - 140;
  } else {
    textY = gridY + actualGridH + 60;
  }

  final double progressPct = totalDays > 0 ? (completedCount / totalDays * 100) : 0;

  void drawText(String text, Offset offset, double size, FontWeight weight, Color color) {
    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      fontFamily: 'sans-serif',
      fontSize: size,
      fontWeight: weight,
      textAlign: ui.TextAlign.center,
    ))
      ..pushStyle(ui.TextStyle(color: color))
      ..addText(text);
    final para = pb.build()..layout(ui.ParagraphConstraints(width: gridW));
    canvas.drawParagraph(para, Offset((w - gridW) / 2, offset.dy));
  }

  drawText(
    goalTitle.toUpperCase(),
    Offset(0, textY),
    w * 0.046,
    FontWeight.w800,
    Colors.white,
  );

  drawText(
    "${progressPct.round()}% COMPLETE  ·  $daysRemaining DAYS LEFT",
    Offset(0, textY + w * 0.046 + 15),
    w * 0.030,
    FontWeight.w700,
    const Color(0xFFC6F52C),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background tasks and notifications
  if (!kIsWeb && Platform.isAndroid) {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
    await BackgroundService.initialize();
  }

  // Load environment config
  await EnvConfig.load();

  // Preload Google Fonts safely (do not block startup on network failure)
  try {
    GoogleFonts.config.allowRuntimeFetching = true;
    await GoogleFonts.pendingFonts([
      GoogleFonts.spaceGrotesk(),
      GoogleFonts.plusJakartaSans(),
      GoogleFonts.inter(),
      GoogleFonts.sora(),
    ]).timeout(const Duration(seconds: 3));
  } catch (e) {
    debugPrint('Google Fonts preloading failed or timed out: $e');
  }

  // Initialize window manager for desktop only
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    await windowManager.ensureInitialized();

    final windowOptions = WindowOptions(
      size: Size(1400, 900),
      minimumSize: Size(1000, 700),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: Platform.isMacOS ? true : false,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  runApp(
    const ProviderScope(
      child: AnchorApp(),
    ),
  );
}
