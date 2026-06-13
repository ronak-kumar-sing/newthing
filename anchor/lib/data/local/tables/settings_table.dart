import 'package:drift/drift.dart';

/// User settings and configuration.
class AppSettings extends Table {
  /// Single row — always 'anchor_settings'.
  TextColumn get id => text()();

  /// User's display name.
  TextColumn get userName => text().nullable()();

  /// Independence goal date.
  DateTimeColumn get independenceDate => dateTime().nullable()();

  /// Start date of the independence journey (user-picked).
  DateTimeColumn get independenceStartDate => dateTime().nullable()();

  /// What the independence date represents (e.g., "Graduation").
  TextColumn get independenceLabel => text().nullable()();

  /// Daily distraction time limit in minutes.
  IntColumn get distractionLimitMinutes => integer().withDefault(const Constant(120))();

  /// Screen time reset hour (0-23).
  IntColumn get screenTimeResetHour => integer().withDefault(const Constant(0))();

  /// Todoist API token.
  TextColumn get todoistApiToken => text().nullable()();

  /// Gemini API key.
  TextColumn get geminiApiKey => text().nullable()();

  /// City for weather.
  TextColumn get weatherCity => text().nullable()();

  /// Latitude for weather.
  RealColumn get weatherLat => real().nullable()();

  /// Longitude for weather.
  RealColumn get weatherLon => real().nullable()();

  /// News category preference.
  TextColumn get newsCategory => text().withDefault(const Constant('technology'))();

  /// Whether to show the persistent widget.
  BoolColumn get showPersistentWidget => boolean().withDefault(const Constant(true))();

  /// Whether app should launch on startup.
  BoolColumn get launchOnStartup => boolean().withDefault(const Constant(false))();

  /// Whether WhatsApp digest is enabled.
  BoolColumn get whatsappDigestEnabled => boolean().withDefault(const Constant(false))();

  /// Last digest generation timestamp.
  DateTimeColumn get lastDigestAt => dateTime().nullable()();

  /// Selected Gemini model for AI features.
  TextColumn get geminiModel => text().withDefault(const Constant('gemini-2.0-flash'))();


  @override
  Set<Column> get primaryKey => {id};
}
