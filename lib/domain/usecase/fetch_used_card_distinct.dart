import 'package:nfc_deck_tracker/data/repository/fetch_used_card_distinct.dart';

import '../entity/card.dart';
import '../mapper/card.dart';

class FetchUsedCardDistinctUsecase {
  final FetchUsedCardDistinctRepository fetchUsedCardDistinctRepository;

  FetchUsedCardDistinctUsecase({
    required this.fetchUsedCardDistinctRepository,
  });

  Future<List<CardEntity>> call() async {
    final cards = await fetchUsedCardDistinctRepository.fetch();
    return cards.map(CardMapper.toEntity).toList();
  }
}
