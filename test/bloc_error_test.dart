import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/tag.dart';
import 'package:nfc_deck_tracker/domain/repository/card.dart';
import 'package:nfc_deck_tracker/domain/repository/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/delete_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/find_card_from_tag.dart';
import 'package:nfc_deck_tracker/presentation/bloc/deck/bloc.dart';
import 'package:nfc_deck_tracker/presentation/bloc/error_reporting.dart';
import 'package:nfc_deck_tracker/presentation/bloc/reader/bloc.dart';
import 'support/pending_deletes.dart';

class BrokenDecks extends Fake implements DeckRepository {
  bool broken = true;
  @override
  Future<List<DeckEntity>> fetchForLocal() async {
    if (broken) throw StateError('database closed');
    return const [DeckEntity(deckId: 'd', name: 'D')];
  }
}

class MissingCards extends Fake implements CardRepository {
  @override
  Future<CardEntity?> findForLocal(
          {required String collectionId, required String cardId}) async =>
      null;
  @override
  Future<CardEntity?> findForApi(
          {required String collectionId, required String cardId}) async =>
      null;
}

void main() {
  test('a failing fetch surfaces as errorMessage and clears on the next load',
      () async {
    final repository = BrokenDecks();
    final bloc = DeckBloc(
      fetchDeckUsecase: FetchDeckUsecase(
          pendingDeletes: MemoryPendingDeletes(), deckRepository: repository),
      deleteDeckUsecase: DeleteDeckUsecase(
          pendingDeletes: MemoryPendingDeletes(), deckRepository: repository),
    );

    bloc.add(const FetchDeckEvent(userId: ''));
    await bloc.stream.firstWhere((s) => s.errorMessage.isNotEmpty);
    expect(bloc.state.errorMessage, ErrorKeys.load);
    expect(bloc.state.isLoading, isFalse);

    repository.broken = false;
    bloc.add(const FetchDeckEvent(userId: ''));
    await bloc.stream.firstWhere((s) => s.decks.isNotEmpty);
    expect(bloc.state.errorMessage, isEmpty);
    await bloc.close();
  });

  test('a card missing from the API reaches the reader as a warning', () async {
    final bloc = ReaderBloc(
        findCardFromTagUsecase:
            FindCardFromTagUsecase(cardRepository: MissingCards()));
    addTearDown(bloc.close);

    bloc.add(const ReadTagEvent(
        tag: TagEntity(tagId: 't', cardId: 'c', collectionId: 'game')));
    await bloc.stream.firstWhere((s) => !s.isLoading);
    expect(bloc.state.warningMessage, 'nfc_snack_bar.error_card_not_found');
    expect(bloc.state.errorMessage, isEmpty);
  });
}
