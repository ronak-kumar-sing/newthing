import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../modules/independence_clock/independence_clock_screen.dart';
import '../../modules/life_progress/life_progress_screen.dart';
import '../../modules/morning_brief/morning_brief_screen.dart';
import '../../modules/screen_mirror/screen_mirror_screen.dart';
import '../../modules/task_center/task_center_screen.dart';
import '../../modules/placement_tracker/placement_tracker_screen.dart';
import '../../modules/settings/settings_screen.dart';
import '../../modules/whatsapp_digest/whatsapp_digest_screen.dart';
import '../widgets/main_shell.dart';

/// Route names for type-safe navigation
class Routes {
  Routes._();

  static const String morningBrief = '/';
  static const String independenceClock = '/clock';
  static const String screenMirror = '/screen';
  static const String taskCenter = '/tasks';
  static const String lifeProgress = '/progress';
  static const String whatsappDigest = '/whatsapp';
  static const String placementTracker = '/placement';
  static const String settings = '/settings';
}

/// GoRouter configuration for Anchor.
/// Uses a shell route with the main navigation sidebar.
final GoRouter appRouter = GoRouter(
  initialLocation: Routes.lifeProgress,
  debugLogDiagnostics: true,
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: Routes.lifeProgress,
          name: 'lifeProgress',
          pageBuilder: (context, state) => _buildPage(state, const LifeProgressScreen()),
        ),
        GoRoute(
          path: Routes.morningBrief,
          name: 'morningBrief',
          pageBuilder: (context, state) => _buildPage(state, const MorningBriefScreen()),
        ),
        GoRoute(
          path: Routes.independenceClock,
          name: 'independenceClock',
          pageBuilder: (context, state) => _buildPage(state, const IndependenceClockScreen()),
        ),
        GoRoute(
          path: Routes.screenMirror,
          name: 'screenMirror',
          pageBuilder: (context, state) => _buildPage(state, const ScreenMirrorScreen()),
        ),
        GoRoute(
          path: Routes.taskCenter,
          name: 'taskCenter',
          pageBuilder: (context, state) => _buildPage(state, const TaskCenterScreen()),
        ),

        GoRoute(
          path: Routes.whatsappDigest,
          name: 'whatsappDigest',
          pageBuilder: (context, state) => _buildPage(state, const WhatsappDigestScreen()),
        ),
        GoRoute(
          path: Routes.placementTracker,
          name: 'placementTracker',
          pageBuilder: (context, state) => _buildPage(state, const PlacementTrackerScreen()),
        ),
      ],
    ),
    GoRoute(
      path: Routes.settings,
      name: 'settings',
      pageBuilder: (context, state) => _buildPage(state, const SettingsScreen()),
    ),
  ],
);

/// Builds a page with no transition for desktop-native feel.
Page<dynamic> _buildPage(GoRouterState state, Widget child) {
  return NoTransitionPage(
    key: state.pageKey,
    child: child,
  );
}
