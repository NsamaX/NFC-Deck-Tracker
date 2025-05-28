import 'package:flutter/foundation.dart';

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

    if (userId.isNotEmpty && card.imageUrl?.isNotEmpty == true) {
      final uploadedUrl = await uploadImageRepository.uploadCardImage(
        userId: userId,
        imagePath: card.imageUrl!,
      );

      if (uploadedUrl != null) {
        finalImageUrl = uploadedUrl;
      }
    }

    final updatedCard = card.copyWith(imageUrl: finalImageUrl);
    final cardModel = CardMapper.toModel(updatedCard);

    await updateCardRepository.updateLocalCard(card: cardModel);

    if (userId.isNotEmpty) {
      final success = await updateCardRepository.updateRemoteCard(
        userId: userId,
        card: cardModel,
      );

      if (!success) {
        debugPrint('⚠️ Remote update failed, saved as local only');
      }
    }
  }
}
