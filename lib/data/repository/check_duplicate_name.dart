import '../datasource/local/check_duplicate_name.dart';

class CheckDuplicateNameRepository {
  final CheckDuplicateNameLocalDatasource checkDuplicateNameLocalDatasource;

  CheckDuplicateNameRepository({
    required this.checkDuplicateNameLocalDatasource,
  });

  Future<int> check({
    required String collectionId,
    required String name,
  }) async {
    return await checkDuplicateNameLocalDatasource.check(collectionId: collectionId, name: name);
  }
}
