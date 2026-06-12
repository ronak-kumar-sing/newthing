import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'core/constants/env_config.dart';
import 'core/services/background_service.dart';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:workmanager/workmanager.dart';

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
  try {
    final prefs = await SharedPreferences.getInstance();

    final targetDateStr = prefs.getString('anchor_target_date') ?? '';
    final goalTitle     = prefs.getString('anchor_goal_title')  ?? 'My Goal';
    final bgColorInt    = prefs.getInt('anchor_wallpaper_bg_color') ?? 0xFF0A0A0A;
    final startDateStr  = prefs.getString('anchor_start_date')  ?? '';

    if (targetDateStr.isEmpty) return;

    final targetDate = DateTime.parse(targetDateStr);
    final startDate  = startDateStr.isNotEmpty ? DateTime.parse(startDateStr) : DateTime.now();
    final now = DateTime.now();

    final daysRemaining = targetDate.difference(now).inDays.clamp(0, 9999);
    final totalDays     = targetDate.difference(startDate).inDays.clamp(1, 9999);
    final bgColor       = Color(bgColorInt);

    final recorder = ui.PictureRecorder();
    final canvas    = Canvas(recorder);

    const double W = 1080.0;
    const double H = 2340.0;

    _paintWallpaperHeadless(
      canvas: canvas,
      w: W, h: H,
      daysRemaining: daysRemaining,
      totalDays: totalDays,
      goalTitle: goalTitle,
      bgColor: bgColor,
    );

    final picture = recorder.endRecording();
    final image   = await picture.toImage(W.round(), H.round());
    final bytes   = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return;

    final tempDir = await getTemporaryDirectory();
    final file    = File('${tempDir.path}/anchor_wallpaper_bg.png');
    await file.writeAsBytes(bytes.buffer.asUint8List());

    await WallpaperManagerFlutter().setWallpaper(
      file, WallpaperManagerFlutter.bothScreens);

  } catch (e) {
    debugPrint('Background wallpaper error: $e');
  }
}

void _paintWallpaperHeadless({
  required Canvas canvas,
  required double w, required double h,
  required int daysRemaining, required int totalDays,
  required String goalTitle, required Color bgColor,
}) {
  canvas.drawRect(Rect.fromLTWH(0, 0, w, h), Paint()..color = bgColor);

  final double hMargin   = w * 0.055;
  final double topPad    = h * 0.08;
  final double headerH   = h * 0.20;
  final double gridGapT  = h * 0.025;
  final double bottomPad = h * 0.04;

  final double gridW = w - hMargin * 2;
  final double gridH = h - topPad - headerH - gridGapT - bottomPad;

  final int monthsLeft = daysRemaining ~/ 30;
  final int daysLeft   = daysRemaining % 30;
  final int elapsed    = totalDays - daysRemaining;
  final double pct     = totalDays > 0 ? elapsed / totalDays * 100 : 0;

  void drawText(String text, Offset offset, double size, FontWeight weight, Color color) {
    final pb = ui.ParagraphBuilder(ui.ParagraphStyle(
      fontFamily: 'sans-serif',
      fontSize: size,
      fontWeight: weight,
    ))
      ..pushStyle(ui.TextStyle(color: color))
      ..addText(text);
    final para = pb.build()..layout(ui.ParagraphConstraints(width: gridW));
    canvas.drawParagraph(para, offset);
  }

  final double numSize = w * 0.20;
  drawText(monthsLeft.toString(),
    Offset(hMargin, topPad + headerH * 0.10), numSize,
    FontWeight.w800, Colors.white);
  drawText(":",
    Offset(hMargin + numSize * 0.65, topPad + headerH * 0.18), numSize * 0.65,
    FontWeight.w300, Colors.white.withOpacity(0.30));
  drawText(daysLeft.toString().padLeft(2, '0'),
    Offset(hMargin + numSize * 0.65 + numSize * 0.52, topPad + headerH * 0.10),
    numSize, FontWeight.w800, Colors.white);

  drawText("${pct.round()}%  /  $totalDays days",
    Offset(hMargin, topPad + headerH * 0.72),
    w * 0.042, FontWeight.w500,
    const Color(0xFFC6F52C));

  const int cols = 6;
  final int rows = totalDays > 0 ? (totalDays / cols).ceil() : 1;
  final double rowStep  = min(gridW / cols, gridH / rows);
  final double dotSize  = rowStep * 0.72;
  final double dotGap   = rowStep - dotSize;
  final double cornerR  = dotSize * 0.28;

  final Paint filledP = Paint()..color = const Color(0xFF4CAF50);
  final Paint emptyP  = Paint()
    ..color = Colors.white.withOpacity(0.70)
    ..style = PaintingStyle.stroke
    ..strokeWidth = dotSize * 0.10;

  final double gridTop = topPad + headerH + gridGapT;

  for (int i = 0; i < totalDays; i++) {
    int col = i % cols;
    int row = i ~/ cols;
    double x = hMargin + col * (dotSize + dotGap);
    double y = gridTop  + row * (dotSize + dotGap);
    if (y + dotSize > h - bottomPad) break;

    final rr = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, y, dotSize, dotSize),
      Radius.circular(cornerR));

    if (i < elapsed) {
      canvas.drawRRect(rr, filledP);
    } else {
      canvas.drawRRect(rr, emptyP);
    }
  }
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
