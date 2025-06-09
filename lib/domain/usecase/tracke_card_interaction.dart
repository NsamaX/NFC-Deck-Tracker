import 'package:nfc_deck_tracker/util/player_action.dart';

import '../entity/deck.dart';
import '../entity/data.dart';
import '../entity/tag.dart';

class TrackCardInteractionResult {
  final DeckEntity updatedDeck;
  final DataEntity? newLog;
  final String? errorKey;

  TrackCardInteractionResult({
    required this.updatedDeck,
    required this.newLog,
    this.errorKey,
  });
}

class TrackCardInteractionUsecase {
  TrackCardInteractionResult call({
    required DeckEntity deck,
    required List<DataEntity> logs,
    required TagEntity tag,
  }) {
    final cardIndex = deck.cards?.indexWhere(
      (c) =>
          c.card.cardId == tag.cardId &&
          c.card.collectionId == tag.collectionId,
    );

    if (cardIndex == null || cardIndex == -1) {
      return TrackCardInteractionResult(
        updatedDeck: deck,
        newLog: null,
        errorKey: 'page_deck_tracker.snack_bar_not_part_of_current_deck',
      );
    }

    final cardInDeck = deck.cards![cardIndex];
    final previousLogs = logs.where((log) => log.tagId == tag.tagId).toList();

    PlayerAction nextAction;
    int newCount = cardInDeck.count;

    if (previousLogs.isEmpty) {
      if (newCount < 1) {
        return TrackCardInteractionResult(
          updatedDeck: deck,
          newLog: null,
        );
      }
      nextAction = PlayerAction.take;
      newCount -= 1;
    } else {
      final lastAction = previousLogs.last.playerAction;

      if (lastAction == PlayerAction.take) {
        nextAction = PlayerAction.give;
        newCount += 1;
      } else if (lastAction == PlayerAction.give) {
        if (newCount < 1) {
          return TrackCardInteractionResult(
            updatedDeck: deck,
            newLog: null,
          );
        }
        nextAction = PlayerAction.take;
        newCount -= 1;
      } else {
        return TrackCardInteractionResult(updatedDeck: deck, newLog: null);
      }
    }

    final updatedCard = cardInDeck.copyWith(count: newCount);
    final updatedCards = [
      updatedCard,
      ...deck.cards!.where(
        (c) =>
            c.card.cardId != tag.cardId ||
            c.card.collectionId != tag.collectionId,
      ),
    ];

    final location = (nextAction == PlayerAction.take) ? 'deck' : 'hand';
    final newLog = DataEntity(
      tagId: tag.tagId,
      collectionId: tag.collectionId,
      cardId: tag.cardId,
      location: location,
      playerAction: nextAction,
      timestamp: DateTime.now(),
    );

    return TrackCardInteractionResult(
      updatedDeck: deck.copyWith(cards: updatedCards),
      newLog: newLog,
    );
  }
}
