import '../entity/card.dart';
import '../entity/deck.dart';

class UpdateDeckCardCountUsecase {
  List<CardInDeckEntity> addCard({
    required List<CardInDeckEntity> current,
    required CardEntity card,
    required int quantity,
  }) {
    final index = current.indexWhere((e) => e.card.cardId == card.cardId);
    final updated = [...current];

    if (index != -1) {
      final old = updated[index];
      updated[index] = CardInDeckEntity(card: old.card, count: old.count + quantity);
    } else {
      updated.add(CardInDeckEntity(card: card, count: quantity));
    }

    return updated;
  }

  List<CardInDeckEntity> removeCard({
    required List<CardInDeckEntity> current,
    required CardEntity card,
  }) {
    final index = current.indexWhere((e) => e.card.cardId == card.cardId);
    final updated = [...current];

    if (index != -1) {
      final old = updated[index];
      final newCount = old.count - 1;

      if (newCount > 0) {
        updated[index] = CardInDeckEntity(card: old.card, count: newCount);
      } else {
        updated.removeAt(index);
      }
    }

    return updated;
  }
}
