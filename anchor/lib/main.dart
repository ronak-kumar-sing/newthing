import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'app.dart';
import 'core/constants/env_config.dart';
import 'core/services/background_service.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background tasks and notifications
  if (!kIsWeb && Platform.isAndroid) {
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
