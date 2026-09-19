import '../../domain/entity/app_settings.dart';
import '../../domain/repository/settings.dart';
import '../datasource/local/settings.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDatasource localDatasource;

  SettingsRepositoryImpl({
    required this.localDatasource,
  });

  @override
  Future<AppSettings> load() => localDatasource.load();

  @override
  Future<void> save(AppSettings settings) => localDatasource.save(settings);
}
