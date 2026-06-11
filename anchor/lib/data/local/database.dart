import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'tables/task_table.dart';
import 'tables/journal_table.dart';
import 'tables/progress_table.dart';
import 'tables/settings_table.dart';
import 'tables/screen_time_table.dart';
import 'tables/chat_message_table.dart';
import 'tables/whatsapp_digest_table.dart';
import 'tables/whatsapp_group_table.dart';
import 'tables/placement_table.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  Tasks,
  JournalEntries,
  ProgressDimensions,
  ProgressValues,
  AppSettings,
  ScreenTimeSessions,
  AppCategories,
  ChatMessages,
  WhatsappDigests,
  WhatsappGroups,
  Placements,
])
class AnchorDatabase extends _$AnchorDatabase {
  AnchorDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            // v1 → v2: add ChatMessages, WhatsappDigests, WhatsappGroups tables
            await m.createTable(chatMessages);
            await m.createTable(whatsappDigests);
            await m.createTable(whatsappGroups);
            // v1 → v2: add geminiModel column to AppSettings
            await m.addColumn(appSettings, appSettings.geminiModel);
          }
          if (from < 3) {
            // v2 → v3: add Placements table
            await m.createTable(placements);
          }
        },
      );


  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'anchor_db',
      native: const DriftNativeOptions(
        databaseDirectory: getApplicationSupportDirectory,
      ),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }
}
