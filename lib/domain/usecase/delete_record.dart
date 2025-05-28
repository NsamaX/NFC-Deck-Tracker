import 'package:flutter/foundation.dart';

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
    await deleteRecordRepository.deleteLocalRecord(recordId: recordId);

    if (userId.isNotEmpty) {
      final remoteSuccess = await deleteRecordRepository.deleteRemoteRecord(
        userId: userId,
        recordId: recordId,
      );

      if (!remoteSuccess) {
        debugPrint('⚠️ Remote delete failed, local already removed');
      }
    }
  }
}
