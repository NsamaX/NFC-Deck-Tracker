import 'package:nfc_deck_tracker/data/repository/clear_local_datasource.dart';

class ClearLocalDataSourceUsecase {
  final ClearLocalDataSourceRepository clearLocalDataSourceRepository;

  ClearLocalDataSourceUsecase({
    required this.clearLocalDataSourceRepository,
  });

  Future<void> call() async {
    await clearLocalDataSourceRepository.clear();
  }
}
