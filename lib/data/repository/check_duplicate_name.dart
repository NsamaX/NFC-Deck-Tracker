import '../datasource/local/check_card_duplicate_name.dart';

class CheckCardDuplicateNameRepository {
  final CheckCardDuplicateNameLocalDatasource checkCardDuplicateNameLocalDatasource;

  CheckCardDuplicateNameRepository({
    required this.checkCardDuplicateNameLocalDatasource,
  });

  Future<int> check({
    required String collectionId,
    required String name,
  }) async {
    return await checkCardDuplicateNameLocalDatasource.check(collectionId: collectionId, name: name);
  }
}
