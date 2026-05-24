import 'package:drift/drift.dart';
import 'connection/connection_stub.dart'
    if (dart.library.js_interop) 'connection/connection_web.dart'
    if (dart.library.io) 'connection/connection_native.dart';

part 'app_database.g.dart';

class Habits extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get description => text().nullable()();
  IntColumn get iconCodePoint => integer()();
  IntColumn get colorHex => integer()();
  BoolColumn get isLifelong => boolean().withDefault(const Constant(true))();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
}

class HabitCompletions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get habitId => integer().references(Habits, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get completedDate => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {habitId, completedDate}
      ];
}

@DriftDatabase(tables: [Habits, HabitCompletions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connect());

  @override
  int get schemaVersion => 1;
}
