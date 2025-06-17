import '../entity/card_in_deck.dart';

class FilterDeckCardsUsecase {
  List<CardInDeckEntity> call(List<CardInDeckEntity> cards) {
    return cards.where((e) => e.count > 0).toList();
  }
}
