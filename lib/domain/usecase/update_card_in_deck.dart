import '../entity/card.dart';
import '../entity/card_in_deck.dart';

class UpdateCardInDeckUsecase {
  List<CardInDeckEntity> call({
    required List<CardInDeckEntity> cardInDeck,
    required CardEntity card,
    required int quantity,
  }) {
    final updated = [...cardInDeck];
    final index = updated.indexWhere((e) => e.card.cardId == card.cardId);
    final currentCount = index != -1 ? updated[index].count : 0;
    final newCount = currentCount + quantity;

    if (index != -1) {
      if (newCount < 1) {
        updated.removeAt(index);
      } else {
        updated[index] = CardInDeckEntity(card: card, count: newCount);
      }
    } else {
      if (newCount > 0) {
        updated.add(CardInDeckEntity(card: card, count: newCount));
      }
    }

    return updated;
  }
}
