import '../entity/card_in_deck.dart';
import '../entity/deck.dart';

abstract interface class DeckRepository {
  Future<void> createForLocal({
    required DeckEntity deck,
  });

  Future<bool> createForRemote({
    required String userId,
    required DeckEntity deck,
  });

  Future<bool> deleteForLocal({
    required String deckId,
  });

  Future<bool> deleteForRemote({
    required String userId,
    required String deckId,
  });

  Future<List<CardInDeckEntity>> fetchCardsInDeck({
    required String deckId,
  });

  Future<List<DeckEntity>> fetchForLocal();

  Future<List<DeckEntity>> fetchForRemote({
    required String userId,
  });

  Future<void> updateForLocal({
    required DeckEntity deck,
  });

  Future<bool> updateForRemote({
    required String userId,
    required DeckEntity deck,
  });
}
