import '../datasource/local/create_page.dart';
import '../model/page.dart';

class CreatePageRepository {
  final CreatePageLocalDatasource createPageLocalDatasource;

  CreatePageRepository({
    required this.createPageLocalDatasource,
  });

  Future<void> create({
    required PageModel page,
  }) async {
    await createPageLocalDatasource.create(page: page);
  }
}
