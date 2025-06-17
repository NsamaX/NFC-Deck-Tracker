import '../entity/card.dart';
import '../entity/card_in_deck.dart';

class UpdateDeckCardCountUsecase {
  List<CardInDeckEntity> addCard({
    required List<CardInDeckEntity> current,
    required CardEntity card,
    required int quantity,
  }) {
    if (quantity <= 0) return current;

    final updated = [...current];
    final index = updated.indexWhere((e) => e.card.cardId == card.cardId);

    if (index != -1) {
      final existing = updated[index];
      updated[index] = CardInDeckEntity(
        card: existing.card,
        count: existing.count + quantity,
      );
    } else {
      updated.add(CardInDeckEntity(card: card, count: quantity));
    }

    return updated;
  }

  List<CardInDeckEntity> removeCard({
    required List<CardInDeckEntity> current,
    required CardEntity card,
  }) {
    final updated = [...current];
    final index = updated.indexWhere((e) => e.card.cardId == card.cardId);

    if (index != -1) {
      final existing = updated[index];
      final newCount = existing.count - 1;

      if (newCount > 0) {
        updated[index] = CardInDeckEntity(
          card: existing.card,
          count: newCount,
        );
      } else {
        updated.removeAt(index);
      }
    }

    return updated;
  }
}
