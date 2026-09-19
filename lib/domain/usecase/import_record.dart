import '../repository/record.dart';

import '../entity/share_record.dart';

class ImportRecordUsecase {
  final RecordRepository recordRepository;

  ImportRecordUsecase({
    required this.recordRepository,
  });

  Future<ShareRecordEntity?> call({
    required String userId,
  }) async {
    final shareRecord = await recordRepository.import(userId: userId);
    return shareRecord;
  }
}
