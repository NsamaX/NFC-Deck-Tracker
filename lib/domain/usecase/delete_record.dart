import '../repository/record.dart';

class DeleteRecordUsecase {
  final RecordRepository recordRepository;

  DeleteRecordUsecase({
    required this.recordRepository,
  });

  Future<void> call({
    required String userId,
    required String recordId,
  }) async {
    await recordRepository.deleteForLocal(recordId: recordId);

    if (userId.isNotEmpty) {
      await recordRepository.deleteForRemote(
        userId: userId,
        recordId: recordId,
      );
    }
  }
}
