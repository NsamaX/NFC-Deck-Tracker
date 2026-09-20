import 'package:uuid/uuid.dart';

import '../service/sync_policy.dart';
import '../repository/card.dart';
import '../repository/collection.dart';
import '../repository/image.dart';

import '../entity/card.dart';

class CreateCardUsecase {
  final CardRepository cardRepository;
  final CollectionRepository collectionRepository;
  final ImageRepository imageRepository;

  CreateCardUsecase({
    required this.cardRepository,
    required this.collectionRepository,
    required this.imageRepository,
  });

  Future<CardEntity> call({
    required String userId,
    required CardEntity card,
  }) async {
    final String cardId = card.cardId.isEmpty ? const Uuid().v4() : card.cardId;

    final uploadedUrl = await imageRepository.upload(imagePath: card.imageUrl!);

    final duplicateCount = await cardRepository.check(
      collectionId: card.collectionId,
      name: card.name,
    );

    final isDuplicate = duplicateCount > 0;
    final newName =
        isDuplicate ? '${card.name} (${duplicateCount})' : card.name;

    final updatedCard = card.copyWith(
      cardId: cardId,
      imageUrl: uploadedUrl,
      name: newName,
    );

    await collectionRepository.touch(
      collectionId: card.collectionId,
    );

    return const SyncPolicy().write(
      userId: userId,
      entity: updatedCard,
      markSynced: (e, synced) => e.copyWith(isSynced: synced),
      remote: (e) => cardRepository.createForRemote(userId: userId, card: e),
      local: (e) => cardRepository.createForLocal(card: e),
    );
  }
}
