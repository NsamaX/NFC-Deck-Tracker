import '../datasource/local/update_page.dart';
import '../model/page.dart';

class UpdatePageRepository {
  final UpdatePageLocalDatasource updatePageLocalDatasource;

  UpdatePageRepository({
    required this.updatePageLocalDatasource,
  });

  Future<void> updatePage({
    required PageModel page,
  }) async {
    await updatePageLocalDatasource.updatePage(page: page);
  }
}
