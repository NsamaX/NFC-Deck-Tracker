import '../datasource/local/find_page.dart';

class FindPageRepository {
  final FindPageLocalDatasource findPageLocalDatasource;

  FindPageRepository({
    required this.findPageLocalDatasource,
  });

  Future<Map<String, dynamic>> find({
    required String collectionId,
  }) async {
    return await findPageLocalDatasource.find(collectionId: collectionId);
  }
}
