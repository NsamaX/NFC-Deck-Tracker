import '../repository/record.dart';

import '../entity/share_record.dart';

class ShareRecordUsecase {
  final RecordRepository recordRepository;

  ShareRecordUsecase({
    required this.recordRepository,
  });

  Future<void> call({
    required String userId,
    required ShareRecordEntity shareRecord,
  }) async {
    await recordRepository.share(userId: userId, shareRecord: shareRecord);
  }
}
