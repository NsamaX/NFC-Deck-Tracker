import 'package:uuid/uuid.dart';

import 'package:nfc_deck_tracker/data/repository/check_duplicate_name.dart';
import 'package:nfc_deck_tracker/data/repository/create_card.dart';
import 'package:nfc_deck_tracker/data/repository/upload_image.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import '../entity/card.dart';
import '../mapper/card.dart';

class CreateCardUsecase {
  final CheckDuplicateNameRepository checkDuplicateNameRepository;
  final CreateCardRepository createCardRepository;
  final UploadImageRepository uploadImageRepository;

  CreateCardUsecase({
    required this.checkDuplicateNameRepository,
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

    final duplicateCount = await checkDuplicateNameRepository.countDuplicateCardNames(
      collectionId: card.collectionId!,
      name: card.name!,
    );

    final isDuplicate = duplicateCount > 0;
    final newName = isDuplicate ? '${card.name} [${duplicateCount + 1}]' : card.name;

    final updatedCard = card.copyWith(
      cardId: cardId,
      imageUrl: finalImageUrl,
      name: newName,
    );

    final cardModel = CardMapper.toModel(updatedCard);

    if (userId.isNotEmpty) {
      final success = await createCardRepository.createRemoteCard(
        userId: userId,
        card: cardModel,
      );

      if (!success) {
        LoggerUtil.debugMessage(message: '⚠️ Remote create failed, will not save locally');
        return;
      }
    }

    await createCardRepository.createLocalCard(card: cardModel);
  }
}
