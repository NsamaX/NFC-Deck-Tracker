import '../../domain/repository/local_data.dart';
import '../datasource/local/clear_user_data.dart';

class LocalDataRepositoryImpl implements LocalDataRepository {
  final ClearUserDataLocalDatasource clearUserDataLocalDatasource;

  LocalDataRepositoryImpl({
    required this.clearUserDataLocalDatasource,
  });

  @override
  Future<void> clear() async {
    await clearUserDataLocalDatasource.clear();
  }
}
