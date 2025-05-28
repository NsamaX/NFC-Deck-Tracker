import '../datasource/local/clear_local_datasource.dart';

class ClearLocalDataSourceRepository {
  final ClearLocalDatasource clearLocalDatasource;

  ClearLocalDataSourceRepository({
    required this.clearLocalDatasource,
  });

  Future<void> clear() async {
    await clearLocalDatasource.clear();
  }
}
