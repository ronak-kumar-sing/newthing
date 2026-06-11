import 'package:drift/drift.dart';

@DataClassName('PlacementApplication')
class Placements extends Table {
  TextColumn get id => text()();
  TextColumn get company => text()();
  TextColumn get role => text()();
  TextColumn get status => text()(); // 'applied', 'interview', 'offer', 'rejected'
  DateTimeColumn get appliedDate => dateTime()();
  TextColumn get nextStep => text().nullable()();
  DateTimeColumn get nextStepDate => dateTime().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
