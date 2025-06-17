import '../datasource/local/update_page.dart';
import '../model/page.dart';

class UpdatePageRepository {
  final UpdatePageLocalDatasource updatePageLocalDatasource;

  UpdatePageRepository({
    required this.updatePageLocalDatasource,
  });

  Future<void> update({
    required PageModel page,
  }) async {
    await updatePageLocalDatasource.update(page: page);
  }
}
