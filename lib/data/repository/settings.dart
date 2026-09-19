import '../../domain/repository/settings.dart';
import '../datasource/local/settings.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDatasource localDatasource;

  SettingsRepositoryImpl({
    required this.localDatasource,
  });

  @override
  Future<dynamic> load({
    required String key,
  }) async {
    return await localDatasource.load(key: key);
  }

  @override
  Future<void> update({
    required String key,
    required dynamic value,
  }) async {
    await localDatasource.update(key: key, value: value);
  }
}
