import '../entity/deck.dart';

class FilterDeckCardsUsecase {
  List<CardInDeckEntity> call(List<CardInDeckEntity> cards) {
    return cards.where((e) => e.count > 0).toList();
  }
}
