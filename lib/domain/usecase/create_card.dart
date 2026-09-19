import 'package:uuid/uuid.dart';

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

  Future<void> call({
    required String userId,
    required CardEntity card,
  }) async {
    final String cardId = const Uuid().v4();

    final uploadedUrl = await imageRepository.upload(imagePath: card.imageUrl!);

    final duplicateCount = await cardRepository.check(
      collectionId: card.collectionId!,
      name: card.name!,
    );

    final isDuplicate = duplicateCount > 0;
    final newName =
        isDuplicate ? '${card.name} (${duplicateCount})' : card.name;

    final updatedCard = card.copyWith(
      cardId: cardId,
      imageUrl: uploadedUrl,
      name: newName,
    );

    bool synced = false;
    final success = await cardRepository.createForRemote(
      userId: userId,
      card: updatedCard.copyWith(isSynced: true),
    );

    if (success) synced = true;

    await collectionRepository.touch(
      collectionId: card.collectionId!,
    );

    final finalEntity = updatedCard.copyWith(isSynced: synced);
    final cardToSave = finalEntity;
    await cardRepository.createForLocal(card: cardToSave);
  }
}
