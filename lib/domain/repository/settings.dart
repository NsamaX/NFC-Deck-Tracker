abstract interface class SettingsRepository {
  Future<dynamic> load({
    required String key,
  });

  Future<void> update({
    required String key,
    required dynamic value,
  });
}
