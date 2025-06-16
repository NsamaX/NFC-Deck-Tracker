import '../datasource/local/check_duplicate_name.dart';

class CheckDuplicateNameRepository {
  final CheckDuplicateNameLocalDatasource checkDuplicateNameLocalDatasource;

  CheckDuplicateNameRepository({
    required this.checkDuplicateNameLocalDatasource,
  });

  Future<int> countDuplicateCardNames({
    required String collectionId,
    required String name,
  }) async {
    return await checkDuplicateNameLocalDatasource.countDuplicateCardNames(collectionId: collectionId, name: name);
  }
}
