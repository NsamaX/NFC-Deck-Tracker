import '../datasource/local/clear_user_data.dart';

class ClearUserDataRepository {
  final ClearUserDataLocalDatasource clearUserDataLocalDatasource;

  ClearUserDataRepository({
    required this.clearUserDataLocalDatasource,
  });

  Future<void> clear() async {
    await clearUserDataLocalDatasource.clear();
  }
}
