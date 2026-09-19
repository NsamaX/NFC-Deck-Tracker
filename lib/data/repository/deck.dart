import '../../domain/entity/card_in_deck.dart';
import '../../domain/entity/deck.dart';
import '../../domain/repository/deck.dart';
import '../datasource/local/create_deck.dart';
import '../datasource/local/delete_deck.dart';
import '../datasource/local/fetch_card_in_deck.dart';
import '../datasource/local/fetch_deck.dart';
import '../datasource/local/update_deck.dart';
import '../datasource/remote/create_deck.dart';
import '../datasource/remote/delete_deck.dart';
import '../datasource/remote/fetch_deck.dart';
import '../datasource/remote/update_deck.dart';
import '../mapper/card_in_deck.dart';
import '../mapper/deck.dart';

class DeckRepositoryImpl implements DeckRepository {
  final CreateDeckLocalDatasource createDeckLocalDatasource;
  final CreateDeckRemoteDatasource createDeckRemoteDatasource;
  final DeleteDeckLocalDatasource deleteDeckLocalDatasource;
  final DeleteDeckRemoteDatasource deleteDeckRemoteDatasource;
  final FetchCardInDeckLocalDatasource fetchCardInDeckLocalDatasource;
  final FetchDeckLocalDatasource fetchDeckLocalDatasource;
  final FetchDeckRemoteDatasource fetchDeckRemoteDatasource;
  final UpdateDeckLocalDatasource updateDeckLocalDatasource;
  final UpdateDeckRemoteDatasource updateDeckRemoteDatasource;

  DeckRepositoryImpl({
    required this.createDeckLocalDatasource,
    required this.createDeckRemoteDatasource,
    required this.deleteDeckLocalDatasource,
    required this.deleteDeckRemoteDatasource,
    required this.fetchCardInDeckLocalDatasource,
    required this.fetchDeckLocalDatasource,
    required this.fetchDeckRemoteDatasource,
    required this.updateDeckLocalDatasource,
    required this.updateDeckRemoteDatasource,
  });

  @override
  Future<void> createForLocal({
    required DeckEntity deck,
  }) async {
    await createDeckLocalDatasource.create(deck: DeckMapper.toModel(deck));
  }

  @override
  Future<bool> createForRemote({
    required String userId,
    required DeckEntity deck,
  }) async {
    return await createDeckRemoteDatasource.create(
        userId: userId, deck: DeckMapper.toModel(deck));
  }

  @override
  Future<bool> deleteForLocal({
    required String deckId,
  }) async {
    return await deleteDeckLocalDatasource.delete(deckId: deckId);
  }

  @override
  Future<bool> deleteForRemote({
    required String userId,
    required String deckId,
  }) async {
    return await deleteDeckRemoteDatasource.delete(
        userId: userId, deckId: deckId);
  }

  @override
  Future<List<CardInDeckEntity>> fetchCardsInDeck({
    required String deckId,
  }) async {
    return (await fetchCardInDeckLocalDatasource.fetch(deckId: deckId))
        .map(CardInDeckMapper.toEntity)
        .toList();
  }

  @override
  Future<List<DeckEntity>> fetchForLocal() async {
    return (await fetchDeckLocalDatasource.fetch())
        .map(DeckMapper.toEntity)
        .toList();
  }

  @override
  Future<List<DeckEntity>> fetchForRemote({
    required String userId,
  }) async {
    return (await fetchDeckRemoteDatasource.fetch(userId: userId))
        .map(DeckMapper.toEntity)
        .toList();
  }

  @override
  Future<void> updateForLocal({
    required DeckEntity deck,
  }) async {
    await updateDeckLocalDatasource.update(deck: DeckMapper.toModel(deck));
  }

  @override
  Future<bool> updateForRemote({
    required String userId,
    required DeckEntity deck,
  }) async {
    return await updateDeckRemoteDatasource.update(
        userId: userId, deck: DeckMapper.toModel(deck));
  }
}
