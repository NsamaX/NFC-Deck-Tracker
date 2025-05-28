import '../datasource/local/create_page.dart';
import '../model/page.dart';

class CreatePageRepository {
  final CreatePageLocalDatasource createPageLocalDatasource;

  CreatePageRepository({
    required this.createPageLocalDatasource,
  });

  Future<void> createPage({
    required PageModel page,
  }) async {
    await createPageLocalDatasource.createPage(page: page);
  }
}
