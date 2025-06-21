import 'package:uuid/uuid.dart';

import 'package:nfc_deck_tracker/data/repository/check_duplicate_name.dart';
import 'package:nfc_deck_tracker/data/repository/create_card.dart';
import 'package:nfc_deck_tracker/data/repository/update_collection_date.dart';
import 'package:nfc_deck_tracker/data/repository/upload_image.dart';

import '../entity/card.dart';
import '../mapper/card.dart';

class CreateCardUsecase {
  final CheckCardDuplicateNameRepository checkCardDuplicateNameRepository;
  final CreateCardRepository createCardRepository;
  final UpdateCollectionDateRepository updateCollectionDateRepository;
  final UploadImageRepository uploadImageRepository;

  CreateCardUsecase({
    required this.checkCardDuplicateNameRepository,
    required this.createCardRepository,
    required this.updateCollectionDateRepository,
    required this.uploadImageRepository,
  });

  Future<void> call({
    required String userId,
    required CardEntity card,
  }) async {
    final String cardId = const Uuid().v4();
    String imageUrl = card.imageUrl ?? '';

    if (userId.isNotEmpty) {
      final uploadedUrl = await uploadImageRepository.upload(
        userId: userId,
        imagePath: card.imageUrl!,
      );

      if (uploadedUrl != null) {
        imageUrl = uploadedUrl;
      }
    }

    final duplicateCount = await checkCardDuplicateNameRepository.check(
      collectionId: card.collectionId!,
      name: card.name!,
    );

    final isDuplicate = duplicateCount > 0;
    final newName = isDuplicate ? '${card.name} [${duplicateCount}]' : card.name;

    final updatedCard = card.copyWith(
      cardId: cardId,
      imageUrl: imageUrl,
      name: newName,
    );

    bool synced = false;
    if (userId.isNotEmpty) {
      final success = await createCardRepository.createForRemote(
        userId: userId,
        card: CardMapper.toModel(
          updatedCard.copyWith(isSynced: true),
        ),
      );

      if (success) synced = true;
    }

    await updateCollectionDateRepository.update(
      collectionId: card.collectionId!,
    );

    final finalEntity = updatedCard.copyWith(isSynced: synced);
    final cardModel = CardMapper.toModel(finalEntity);
    await createCardRepository.createForLocal(card: cardModel);
  }
}
