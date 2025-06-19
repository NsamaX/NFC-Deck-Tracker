import 'package:uuid/uuid.dart';

import 'package:nfc_deck_tracker/data/repository/check_duplicate_name.dart';
import 'package:nfc_deck_tracker/data/repository/create_card.dart';
import 'package:nfc_deck_tracker/data/repository/upload_image.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import '../entity/card.dart';
import '../mapper/card.dart';

class CreateCardUsecase {
  final CheckDuplicateNameRepository checkDuplicateNameRepository;
  final CreateCardRepository createCardRepository;
  final UploadImageRepository uploadImageRepository;

  CreateCardUsecase({
    required this.checkDuplicateNameRepository,
    required this.createCardRepository,
    required this.uploadImageRepository,
  });

  Future<void> call({
    required String userId,
    required CardEntity card,
  }) async {
    final String cardId = const Uuid().v4();
    final DateTime now = DateTime.now();
    String finalImageUrl = card.imageUrl ?? '';

    if (userId.isNotEmpty && card.imageUrl?.isNotEmpty == true) {
      final uploadedUrl = await uploadImageRepository.upload(
        userId: userId,
        imagePath: card.imageUrl!,
      );

      if (uploadedUrl != null) {
        finalImageUrl = uploadedUrl;
      }
    }

    final duplicateCount = await checkDuplicateNameRepository.check(
      collectionId: card.collectionId!,
      name: card.name!,
    );

    final isDuplicate = duplicateCount > 0;
    final newName = isDuplicate ? '${card.name} [${duplicateCount}]' : card.name;

    final updatedCard = card.copyWith(
      cardId: cardId,
      imageUrl: finalImageUrl,
      name: newName,
      updatedAt: now,
    );

    bool synced = false;
    if (userId.isNotEmpty) {
      final remoteSuccess = await createCardRepository.createForRemote(
        userId: userId,
        card: CardMapper.toModel(
          updatedCard.copyWith(isSynced: true),
        ),
      );

      if (remoteSuccess) {
        synced = true;
      } else {
        LoggerUtil.debugMessage('⚠️ Remote create failed, will fallback to local-only');
      }
    }

    final finalEntity = updatedCard.copyWith(isSynced: synced);
    final cardModel = CardMapper.toModel(finalEntity);
    await createCardRepository.createForLocal(card: cardModel);
  }
}
