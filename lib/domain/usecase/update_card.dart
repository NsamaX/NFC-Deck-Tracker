import '../repository/card.dart';
import '../repository/image.dart';

import '../entity/card.dart';

class UpdateCardUsecase {
  final CardRepository cardRepository;
  final ImageRepository imageRepository;

  UpdateCardUsecase({
    required this.cardRepository,
    required this.imageRepository,
  });

  Future<void> call({
    required String userId,
    required CardEntity card,
    required String oldImageUrl,
  }) async {
    String? finalImageUrl;
    final DateTime now = DateTime.now();

    if (oldImageUrl != card.imageUrl) {
      finalImageUrl = await imageRepository.update(
          oldImageUrl: oldImageUrl, newImagePath: card.imageUrl!);
    }

    final updatedCard = card.copyWith(
      imageUrl: finalImageUrl ?? card.imageUrl,
      updatedAt: now,
    );

    bool synced = false;
    if (userId.isNotEmpty) {
      final success = await cardRepository.updateForRemote(
        userId: userId,
        card: updatedCard.copyWith(isSynced: true),
      );

      if (success) synced = true;
    }

    final finalEntity = updatedCard.copyWith(isSynced: synced);
    final cardToSave = finalEntity;
    await cardRepository.updateForLocal(card: cardToSave);
  }
}
