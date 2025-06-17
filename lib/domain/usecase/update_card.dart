import 'package:nfc_deck_tracker/data/repository/update_card.dart';
import 'package:nfc_deck_tracker/data/repository/upload_image.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import '../entity/card.dart';
import '../mapper/card.dart';

class UpdateCardUsecase {
  final UpdateCardRepository updateCardRepository;
  final UploadImageRepository uploadImageRepository;

  UpdateCardUsecase({
    required this.updateCardRepository,
    required this.uploadImageRepository,
  });

  Future<void> call({
    required String userId,
    required CardEntity card,
  }) async {
    String? finalImageUrl = card.imageUrl;
    final DateTime now = DateTime.now();

    if (userId.isNotEmpty && card.imageUrl?.isNotEmpty == true) {
      final uploadedUrl = await uploadImageRepository.upload(
        userId: userId,
        imagePath: card.imageUrl!,
      );

      if (uploadedUrl != null) {
        finalImageUrl = uploadedUrl;
      }
    }

    final updatedCard = card.copyWith(
      imageUrl: finalImageUrl,
      updatedAt: now,
    );

    bool synced = false;
    if (userId.isNotEmpty) {
      final remoteSuccess = await updateCardRepository.updateForRemote(
        userId: userId,
        card: CardMapper.toModel(
          updatedCard.copyWith(isSynced: true),
        ),
      );

      if (remoteSuccess) {
        synced = true;
      } else {
        LoggerUtil.debugMessage(message: '⚠️ Remote update failed, will fallback to local-only');
      }
    }

    final finalEntity = updatedCard.copyWith(isSynced: synced);
    final cardModel = CardMapper.toModel(finalEntity);
    await updateCardRepository.updateForLocal(card: cardModel);
  }
}
