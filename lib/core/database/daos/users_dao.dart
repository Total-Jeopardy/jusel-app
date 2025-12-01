import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/users_table.dart';

part 'users_dao.g.dart';

@DriftAccessor(tables: [UsersTable])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(AppDatabase db) : super(db);

  Future<void> insertUser(UsersTableCompanion user) {
    return into(usersTable).insertOnConflictUpdate(user);
  }

  Future<UsersTableData?> getUserById(String id) {
    return (select(
      usersTable,
    )..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  Future<List<UsersTableData>> getAllUsers() {
    return select(usersTable).get();
  }

  Future<int> getUserCount() async {
    final countExp = usersTable.id.count();
    final row =
        await (selectOnly(usersTable)..addColumns([countExp])).getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<bool> updateUser(UsersTableCompanion user) {
    return update(usersTable).replace(user);
  }

  Future<int> deleteUser(String id) {
    return (delete(usersTable)..where((u) => u.id.equals(id))).go();
  }
}
