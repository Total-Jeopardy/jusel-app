import 'package:drift/drift.dart';

class UsersTable extends Table {
  TextColumn get id => text()(); // Firebase UID
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get email => text()();
  TextColumn get role => text()(); // boss or apprentice
  TextColumn get bossId => text().nullable()(); // null for boss accounts, boss UID for apprentices
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
