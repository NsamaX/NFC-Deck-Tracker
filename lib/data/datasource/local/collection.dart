import '../../model/collection.dart';

import 'sqlite_service.dart';

class CollectionLocalDatasource {
  final SQLiteService _sqliteService;

  CollectionLocalDatasource(this._sqliteService);

  Future<void> create({
    required CollectionModel collection,
  }) async {
    await _sqliteService.insert(
      table: 'collections',
      data: collection.toJsonForLocal(),
    );
  }

  Future<bool> delete({
    required String collectionId,
  }) async {
    return await _sqliteService.delete(
      table: 'collections',
      where: 'collectionId = ?',
      whereArgs: [collectionId],
    );
  }

  Future<List<CollectionModel>> fetch() async {
    final result = await _sqliteService.getTable(
      table: 'collections',
    );
    return result.map((row) => CollectionModel.fromJson(row)).toList();
  }

  Future<CollectionModel?> find({
    required String collectionId,
  }) async {
    final result = await _sqliteService.getTable(
      table: 'collections',
      where: 'collectionId = ?',
      whereArgs: [collectionId],
    );

    if (result.isEmpty) return null;

    return CollectionModel.fromJson(result.first);
  }

  Future<void> touch({
    required String collectionId,
  }) async {
    await _sqliteService.update(
      table: 'collections',
      data: {'updatedAt': DateTime.now().toIso8601String()},
      where: 'collectionId = ?',
      whereArgs: [collectionId],
    );
  }

  Future<void> update({
    required CollectionModel collection,
  }) async {
    await _sqliteService.update(
      table: 'collections',
      data: collection.toJsonForLocal(),
      where: 'collectionId = ?',
      whereArgs: [collection.collectionId],
    );
  }
}
