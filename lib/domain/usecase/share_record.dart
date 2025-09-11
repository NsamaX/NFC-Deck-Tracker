import 'package:nfc_deck_tracker/data/repository/share_record.dart';

import '../entity/share_record.dart';
import '../mapper/share_record.dart';

class ShareRecordUsecase {
  final ShareRecordRepository shareRecordRepository;

  ShareRecordUsecase({
    required this.shareRecordRepository,
  });

  Future<void> call({
    required String userId,
    required ShareRecordEntity shareRecord,
  }) async {
    await shareRecordRepository.share(userId: userId, shareRecord: ShareRecordMapper.toModel(shareRecord));
  }
}
