import '../entity/card.dart';
import '../entity/nfc_result.dart';
import '../repository/nfc.dart';

class NfcSessionUsecase {
  final NfcRepository repository;
  NfcSessionUsecase(this.repository);
  Future<bool> isAvailable() => repository.isAvailable();
  Future<void> start(
          {CardEntity? card, required void Function(NfcResult) onResult}) =>
      repository.start(card: card, onResult: onResult);
  Future<void> stop() => repository.stop();
}
