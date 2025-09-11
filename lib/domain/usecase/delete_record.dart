import 'package:nfc_deck_tracker/data/repository/delete_record.dart';

class DeleteRecordUsecase {
  final DeleteRecordRepository deleteRecordRepository;

  DeleteRecordUsecase({
    required this.deleteRecordRepository,
  });

  Future<void> call({
    required String userId,
    required String recordId,
  }) async {
    await deleteRecordRepository.deleteForLocal(recordId: recordId);

    if (userId.isNotEmpty) {
      await deleteRecordRepository.deleteForRemote(
        userId: userId,
        recordId: recordId,
      );
    }
  }
}
