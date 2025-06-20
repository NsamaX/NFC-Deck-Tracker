import 'package:nfc_deck_tracker/data/repository/update_card.dart';
import 'package:nfc_deck_tracker/data/repository/upload_image.dart';

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
