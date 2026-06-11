import 'package:flutter/services.dart';

class NativeBridge {
  NativeBridge._();

  /// Channel for Home Screen widget updates.
  static const MethodChannel widgetSyncChannel =
      MethodChannel('com.example.anchor/streak_widget');

  /// Channel for setting wallpapers.
  static const MethodChannel wallpaperChannel =
      MethodChannel('com.example.anchor/wallpaper');
}
