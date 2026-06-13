import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/settings_table.dart';

part 'settings_dao.g.dart';

/// Data Access Object for app settings.
@DriftAccessor(tables: [AppSettings])
class SettingsDao extends DatabaseAccessor<AnchorDatabase> with _$SettingsDaoMixin {
  SettingsDao(super.db);

  static const String _settingsId = 'anchor_settings';

  /// Get settings or create defaults.
  Future<AppSetting> getSettings() async {
    final existing = await (select(appSettings)
      ..where((s) => s.id.equals(_settingsId)))
        .getSingleOrNull();

    if (existing != null) return existing;

    // Create default settings
    final defaults = AppSettingsCompanion(
      id: const Value(_settingsId),
      distractionLimitMinutes: const Value(120),
      screenTimeResetHour: const Value(0),
      newsCategory: const Value('technology'),
      showPersistentWidget: const Value(true),
      launchOnStartup: const Value(false),
      whatsappDigestEnabled: const Value(false),
      geminiModel: const Value('gemini-2.0-flash'),
    );
    await into(appSettings).insert(defaults, mode: InsertMode.insertOrIgnore);
    return (select(appSettings)
      ..where((s) => s.id.equals(_settingsId)))
        .getSingle();
  }

  /// Update settings.
  Future<void> updateSettings(AppSettingsCompanion settings) {
    return (update(appSettings)
      ..where((s) => s.id.equals(_settingsId)))
        .write(settings);
  }

  /// Set independence goal date.
  Future<void> setIndependenceDate(DateTime date, String label) {
    return updateSettings(AppSettingsCompanion(
      independenceDate: Value(date),
      independenceLabel: Value(label),
    ));
  }

  /// Set the journey start date.
  Future<void> setIndependenceStartDate(DateTime date) {
    return updateSettings(AppSettingsCompanion(
      independenceStartDate: Value(date),
    ));
  }

  /// Get the journey start date, if the user has set one.
  Future<DateTime?> getIndependenceStartDate() async {
    final settings = await getSettings();
    return settings.independenceStartDate;
  }

  /// Update target/independence date immediately.
  Future<void> updateTargetDate(DateTime date) {
    return updateSettings(AppSettingsCompanion(
      independenceDate: Value(date),
    ));
  }

  /// Set Todoist API token.
  Future<void> setTodoistToken(String token) {
    return updateSettings(AppSettingsCompanion(
      todoistApiToken: Value(token),
    ));
  }

  /// Set Gemini API key.
  Future<void> setGeminiApiKey(String key) {
    return updateSettings(AppSettingsCompanion(
      geminiApiKey: Value(key),
    ));
  }

  /// Set Gemini model.
  Future<void> setGeminiModel(String model) {
    return updateSettings(AppSettingsCompanion(
      geminiModel: Value(model),
    ));
  }

  /// Get independence date days remaining.
  Future<int?> getDaysRemaining() async {
    final settings = await getSettings();
    if (settings.independenceDate == null) return null;
    return settings.independenceDate!.difference(DateTime.now()).inDays;
  }
}
