import 'package:nfc_deck_tracker/data/repository/import_record.dart';

import '../entity/share_record.dart';
import '../mapper/share_record.dart';

class ImportRecordUsecase {
  final ImportRecordRepository importRecordRepository;

  ImportRecordUsecase({
    required this.importRecordRepository,
  });

  Future<ShareRecordEntity> call({
    required String userId,
  }) async {
    final shareRecord = await importRecordRepository.import(userId: userId);
    return ShareRecordMapper.toEntity(shareRecord);
  }
}
