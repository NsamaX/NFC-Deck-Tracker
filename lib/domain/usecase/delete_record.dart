import 'package:nfc_deck_tracker/data/repository/delete_record.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

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
      final remoteSuccess = await deleteRecordRepository.deleteForRemote(
        userId: userId,
        recordId: recordId,
      );

      if (!remoteSuccess) {
        LoggerUtil.debugMessage(message: '⚠️ Remote delete failed, local already removed');
      }
    }
  }
}
