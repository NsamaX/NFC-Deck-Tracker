import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/repository/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/delete_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_deck.dart';
import 'package:nfc_deck_tracker/presentation/bloc/deck/bloc.dart';
import 'package:nfc_deck_tracker/presentation/bloc/error_reporting.dart';

class BrokenDecks extends Fake implements DeckRepository {
  bool broken = true;
  @override
  Future<List<DeckEntity>> fetchForLocal() async {
    if (broken) throw StateError('database closed');
    return const [DeckEntity(deckId: 'd', name: 'D')];
  }
}

void main() {
  test('a failing fetch surfaces as errorMessage and clears on the next load',
      () async {
    final repository = BrokenDecks();
    final bloc = DeckBloc(
      fetchDeckUsecase: FetchDeckUsecase(deckRepository: repository),
      deleteDeckUsecase: DeleteDeckUsecase(deckRepository: repository),
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
}
