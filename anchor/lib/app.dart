import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/env_config.dart';
import 'core/permissions/permissions_provider.dart';
import 'core/permissions/permissions_screen.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/local/database.dart' show AppSettingsCompanion;
import 'providers/api_provider.dart';
import 'providers/database_provider.dart';
import 'features/streak/services/widget_sync_service.dart';
import 'modules/whatsapp_digest/whatsapp_notification_service.dart';

/// Anchor app widget.
/// Shows permission screen on first launch, then the main app.
class AnchorApp extends ConsumerWidget {
  const AnchorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionsAsync = ref.watch(permissionsGrantedProvider);

    return MaterialApp(
      title: 'Anchor',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: permissionsAsync.when(
        data: (granted) {
          if (granted) {
            return _ApiInitializer(
              child: MaterialApp.router(
                title: 'Anchor',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.darkTheme,
                routerConfig: appRouter,
              ),
            );
          }
          return PermissionsScreen(
            onPermissionsGranted: () {
              ref.invalidate(permissionsGrantedProvider);
            },
          );
        },
        loading: () => const _LoadingScreen(),
        error: (e, s) => PermissionsScreen(
          onPermissionsGranted: () {
            ref.invalidate(permissionsGrantedProvider);
          },
        ),
      ),
    );
  }
}

/// Initializes APIs from saved settings and starts the WhatsApp bridge.
class _ApiInitializer extends ConsumerStatefulWidget {
  final Widget child;
  const _ApiInitializer({required this.child});

  @override
  ConsumerState<_ApiInitializer> createState() => _ApiInitializerState();
}

class _ApiInitializerState extends ConsumerState<_ApiInitializer> {
  @override
  void initState() {
    super.initState();
    _initApis();
  }

  Future<void> _initApis() async {
    // Load .env file first
    await EnvConfig.load();

    // Load settings from DB
    final dao = ref.read(settingsDaoProvider);
    final settings = await dao.getSettings();

    final todoistApi = ref.read(todoistApiProvider);
    final geminiApi = ref.read(geminiApiProvider);

    // Configure Todoist
    final todoistToken = settings.todoistApiToken ?? EnvConfig.todoistApiToken ?? '';
    if (todoistToken.isNotEmpty) {
      todoistApi.setToken(todoistToken);
    }

    // Configure Gemini
    final geminiKey = settings.geminiApiKey ?? EnvConfig.geminiApiKey ?? '';
    if (geminiKey.isNotEmpty) {
      geminiApi.setApiKey(geminiKey);
    }

    // Configure Gemini model
    geminiApi.setModel(settings.geminiModel);

    // Auto-save .env values to DB if DB is still empty
    final needsSave = (settings.todoistApiToken == null || settings.todoistApiToken!.isEmpty)
        && EnvConfig.todoistApiToken != null;
    if (needsSave) {
      await dao.updateSettings(AppSettingsCompanion(
        todoistApiToken: Value(EnvConfig.todoistApiToken ?? ''),
        geminiApiKey: Value(EnvConfig.geminiApiKey ?? ''),
        userName: Value(EnvConfig.userName ?? ''),
        weatherCity: Value(EnvConfig.weatherCity ?? ''),
      ));
    }

    // Initialize WhatsApp Notification reader
    final whatsappDao = ref.read(whatsappDaoProvider);
    await WhatsappNotificationService.init(whatsappDao);
    debugPrint('[App] WhatsApp Notification Reader Initialized');
  }

  @override
  Widget build(BuildContext context) {
    // Reactively monitor and sync streak/task data changes to native OS widgets
    ref.watch(widgetSyncProvider);
    return widget.child;
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.anchor,
                color: AppColors.background,
                size: 28,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'ANCHOR',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 4,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your Life. Owned.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
