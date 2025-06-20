import 'package:nfc_deck_tracker/data/repository/clear_user_data.dart';

class ClearUserDataUsecase {
  final ClearUserDataRepository clearUserDataRepository;

  ClearUserDataUsecase({
    required this.clearUserDataRepository,
  });

  Future<void> call() async {
    await clearUserDataRepository.clear();
  }
}
