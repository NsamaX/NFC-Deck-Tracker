import '_sqlite_service.dart';

import '../../model/collection.dart';

class FetchCollectionLocalDatasource {
  final SQLiteService _sqliteService;

  FetchCollectionLocalDatasource(this._sqliteService);

  Future<List<CollectionModel>> fetchCollection() async {
    final result = await _sqliteService.getTable(
      table: 'collections',
    );
    return result.map((row) => CollectionModel.fromJson(row)).toList();
  }
}
