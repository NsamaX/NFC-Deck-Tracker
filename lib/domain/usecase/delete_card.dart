import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/repository/delete_card.dart';

import '../entity/card.dart';
import '../mapper/card.dart';

class DeleteCardUsecase {
  final DeleteCardRepository deleteCardRepository;

  DeleteCardUsecase({
    required this.deleteCardRepository,
  });

  Future<void> call({
    required String userId,
    required CardEntity card,
  }) async {
    final cardModel = CardMapper.toModel(card);
    await deleteCardRepository.deleteLocalCard(card: cardModel);

    if (userId.isNotEmpty) {
      final remoteSuccess = await deleteCardRepository.deleteRemoteCard(
        userId: userId,
        card: cardModel,
      );

      if (!remoteSuccess) {
        debugPrint('⚠️ Remote delete failed, local already removed');
      }
    }
  }
}
