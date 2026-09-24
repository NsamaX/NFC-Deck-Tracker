import '../service/clock.dart';
import '../service/sync_policy.dart';
import '../repository/card.dart';
import '../repository/image.dart';

import '../entity/card.dart';

class UpdateCardUsecase {
  final CardRepository cardRepository;
  final ImageRepository imageRepository;
  final Clock clock;

  UpdateCardUsecase({
    required this.cardRepository,
    required this.imageRepository,
    this.clock = const Clock(),
  });

  Future<void> call({
    required String userId,
    required CardEntity card,
    required String oldImageUrl,
  }) async {
    String? finalImageUrl;
    final DateTime now = clock.now();

    final newImagePath = card.imageUrl;
    if (newImagePath != null &&
        newImagePath.isNotEmpty &&
        newImagePath != oldImageUrl) {
      finalImageUrl = await imageRepository.update(
          oldImageUrl: oldImageUrl, newImagePath: newImagePath);
    }

    final updatedCard = card.copyWith(
      imageUrl: finalImageUrl ?? card.imageUrl,
      updatedAt: now,
    );

    await const SyncPolicy().write(
      userId: userId,
      entity: updatedCard,
      markSynced: (e, synced) => e.copyWith(isSynced: synced),
      remote: (e) => cardRepository.updateForRemote(userId: userId, card: e),
      local: (e) => cardRepository.updateForLocal(card: e),
    );
  }
}
