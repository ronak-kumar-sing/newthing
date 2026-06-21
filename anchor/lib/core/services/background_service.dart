import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const updateWallpaperTask = "updateWallpaperTask";
const applyWallpaperTask = "applyWallpaper";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == updateWallpaperTask || task == applyWallpaperTask) {
      final prefs = await SharedPreferences.getInstance();
      final daysRemaining = prefs.getInt('anchor_wallpaper_days_remaining') ?? 0;
      final intensitiesJson = prefs.getString('anchor_wallpaper_intensities');
      final completedCount = intensitiesJson != null
          ? (jsonDecode(intensitiesJson) as List<dynamic>)
              .where((i) => (i as double) > 0)
              .length
          : 0;

      BackgroundService.showNotification(
        "Anchor",
        "$daysRemaining days remaining · $completedCount days completed",
      );
    }
    return Future.value(true);
  });
}

class BackgroundService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsDarwin = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
    );
    await _notifications.initialize(initializationSettings);

    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    await Workmanager().registerPeriodicTask(
      "1",
      updateWallpaperTask,
      frequency: const Duration(days: 1),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
      ),
    );
  }

  static Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'anchor_channel',
      'Anchor Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
      macOS: DarwinNotificationDetails(),
    );
    await _notifications.show(0, title, body, notificationDetails);
  }
}
