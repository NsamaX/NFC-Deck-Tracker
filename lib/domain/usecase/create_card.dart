import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:nfc_deck_tracker/data/repository/create_card.dart';
import 'package:nfc_deck_tracker/data/repository/upload_image.dart';

import '../entity/card.dart';
import '../mapper/card.dart';

class CreateCardUsecase {
  final CreateCardRepository createCardRepository;
  final UploadImageRepository uploadImageRepository;

  CreateCardUsecase({
    required this.createCardRepository,
    required this.uploadImageRepository,
  });

  Future<void> call({
    required String userId,
    required CardEntity card,
  }) async {
    final String cardId = card.cardId ?? const Uuid().v4();
    String finalImageUrl = card.imageUrl ?? '';

    if (userId.isNotEmpty && card.imageUrl?.isNotEmpty == true) {
      final uploadedUrl = await uploadImageRepository.uploadCardImage(
        userId: userId,
        imagePath: card.imageUrl!,
      );

      if (uploadedUrl != null) {
        finalImageUrl = uploadedUrl;
      }
    }
    final updatedCard = card.copyWith(
      cardId: cardId,
      imageUrl: finalImageUrl,
    );

    final cardModel = CardMapper.toModel(updatedCard);

    if (userId.isNotEmpty) {
      final success = await createCardRepository.createRemoteCard(
        userId: userId,
        card: cardModel,
      );

      if (!success) {
        debugPrint('⚠️ Remote create failed, will not save locally');
        return;
      }
    }

    await createCardRepository.createLocalCard(card: cardModel);
  }
}
