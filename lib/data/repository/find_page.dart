import '../datasource/local/find_page.dart';

class FindPageRepository {
  final FindPageLocalDatasource findPageLocalDatasource;

  FindPageRepository({
    required this.findPageLocalDatasource,
  });

  Future<Map<String, dynamic>> findPage({
    required String collectionId,
  }) async {
    return await findPageLocalDatasource.findPage(collectionId: collectionId);
  }
}
