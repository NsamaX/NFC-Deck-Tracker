import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:nfc_deck_tracker/data/datasource/local/database_service.dart';
import 'package:nfc_deck_tracker/data/datasource/local/sqlite_service.dart';

Future<SQLiteService> openTestDatabase() async {
  sqfliteFfiInit();
  await databaseFactoryFfiNoIsolate.deleteDatabase(inMemoryDatabasePath);
  final sql = SQLiteService(
    databaseService: DatabaseService(
      factory: databaseFactoryFfiNoIsolate,
      path: inMemoryDatabasePath,
    ),
  );
  await sql.getDatabase();
  return sql;
}
