import '../repository/card.dart';

import '../entity/card.dart';

class FetchUsedCardDistinctUsecase {
  final CardRepository cardRepository;

  FetchUsedCardDistinctUsecase({
    required this.cardRepository,
  });

  Future<List<CardEntity>> call() async {
    final cards = await cardRepository.fetchUsedCards();
    return cards;
  }
}
