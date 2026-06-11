import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/placement_table.dart';

part 'placement_dao.g.dart';

@DriftAccessor(tables: [Placements])
class PlacementDao extends DatabaseAccessor<AnchorDatabase> with _$PlacementDaoMixin {
  PlacementDao(super.db);

  Stream<List<PlacementApplication>> watchAllApplications() {
    return select(placements).watch();
  }

  Future<List<PlacementApplication>> getAllApplications() {
    return select(placements).get();
  }

  Future<void> insertApplication(PlacementApplication app) {
    return into(placements).insert(app, mode: InsertMode.insertOrReplace);
  }

  Future<void> updateApplication(PlacementApplication app) {
    return update(placements).replace(app);
  }

  Future<void> deleteApplication(String id) {
    return (delete(placements)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> updateStatus(String id, String status) async {
    final query = update(placements)..where((tbl) => tbl.id.equals(id));
    await query.write(PlacementsCompanion(
      status: Value(status),
    ));
  }
}
