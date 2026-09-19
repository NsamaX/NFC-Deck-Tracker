import '../entity/card.dart';
import '../entity/nfc_result.dart';

abstract interface class NfcRepository {
  Future<bool> isAvailable();
  Future<void> start(
      {CardEntity? card, required void Function(NfcResult) onResult});
  Future<void> stop();
}
