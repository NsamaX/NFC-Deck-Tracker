import 'package:nfc_deck_tracker/data/repository/clear_user_data.dart';
import 'package:nfc_deck_tracker/data/repository/delete_image.dart';
import 'package:nfc_deck_tracker/data/repository/fetch_used_card_distinct.dart';

import '../mapper/card.dart';

class ClearUserDataUsecase {
  final ClearUserDataRepository clearUserDataRepository;
  final DeleteImageRepository deleteImageRepository;
  final FetchUsedCardDistinctRepository fetchUsedCardDistinctRepository;

  ClearUserDataUsecase({
    required this.clearUserDataRepository,
    required this.deleteImageRepository,
    required this.fetchUsedCardDistinctRepository,
  });

  Future<void> call({
    required bool isGuest,
  }) async {
    final cards = await fetchUsedCardDistinctRepository.fetch();

    if (isGuest && cards.isNotEmpty) {
      final List<String> imageUrls = cards.map(CardMapper.toEntity).toList().map((card) => card.imageUrl!).toList();
      await deleteImageRepository.delete(imageUrls: imageUrls);
    }

    await clearUserDataRepository.clear();
  }
}
