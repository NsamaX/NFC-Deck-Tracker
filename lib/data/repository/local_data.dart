import '../../domain/repository/local_data.dart';
import '../datasource/local/user_data.dart';

class LocalDataRepositoryImpl implements LocalDataRepository {
  final UserDataLocalDatasource localDatasource;

  LocalDataRepositoryImpl({
    required this.localDatasource,
  });

  @override
  Future<void> clear() async {
    await localDatasource.clear();
  }
}
