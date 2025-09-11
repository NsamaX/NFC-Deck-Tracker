import 'package:nfc_deck_tracker/data/repository/update_card.dart';
import 'package:nfc_deck_tracker/data/repository/update_image.dart';
import 'package:nfc_deck_tracker/data/repository/upload_image.dart';

import '../entity/card.dart';
import '../mapper/card.dart';

class UpdateCardUsecase {
  final UpdateCardRepository updateCardRepository;
  final UpdateImageRepository updateImageRepository;
  final UploadImageRepository uploadImageRepository;

  UpdateCardUsecase({
    required this.updateCardRepository,
    required this.updateImageRepository,
    required this.uploadImageRepository,
  });

  Future<void> call({
    required String userId,
    required CardEntity card,
    required String oldImageUrl,
  }) async {
    String? finalImageUrl;
    final DateTime now = DateTime.now();

    if (oldImageUrl != card.imageUrl) {
      finalImageUrl = await updateImageRepository.update(oldImageUrl: oldImageUrl, newImagePath: card.imageUrl!);
    }

    final updatedCard = card.copyWith(
      imageUrl: finalImageUrl ?? card.imageUrl,
      updatedAt: now,
    );

    bool synced = false;
    if (userId.isNotEmpty) {
      final success = await updateCardRepository.updateForRemote(
        userId: userId,
        card: CardMapper.toModel(
          updatedCard.copyWith(isSynced: true),
        ),
      );

      if (success) synced = true;
    }

    final finalEntity = updatedCard.copyWith(isSynced: synced);
    final cardModel = CardMapper.toModel(finalEntity);
    await updateCardRepository.updateForLocal(card: cardModel);
  }
}
