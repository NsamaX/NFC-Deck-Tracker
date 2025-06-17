import 'package:nfc_deck_tracker/data/repository/clear_local_datasource.dart';

class ClearUserDataUsecase {
  final ClearUserDataRepository clearUserDataRepository;

  ClearUserDataUsecase({
    required this.clearUserDataRepository,
  });

  Future<void> call() async {
    await clearUserDataRepository.clear();
  }
}
