import '../../domain/entity/card_in_deck.dart';
import '../../domain/entity/deck.dart';
import '../../domain/repository/deck.dart';
import '../mapper/card_in_deck.dart';
import '../mapper/deck.dart';
import '../datasource/local/deck.dart';
import '../datasource/remote/deck.dart';

class DeckRepositoryImpl implements DeckRepository {
  final DeckLocalDatasource localDatasource;
  final DeckRemoteDatasource remoteDatasource;

  DeckRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
  });

  @override
  Future<void> createForLocal({
    required DeckEntity deck,
  }) async {
    await localDatasource.create(deck: DeckMapper.toModel(deck));
  }

  @override
  Future<bool> createForRemote({
    required String userId,
    required DeckEntity deck,
  }) async {
    return await remoteDatasource.create(
        userId: userId, deck: DeckMapper.toModel(deck));
  }

  @override
  Future<bool> deleteForLocal({
    required String deckId,
  }) async {
    return await localDatasource.delete(deckId: deckId);
  }

  @override
  Future<bool> deleteForRemote({
    required String userId,
    required String deckId,
  }) async {
    return await remoteDatasource.delete(userId: userId, deckId: deckId);
  }

  @override
  Future<List<CardInDeckEntity>> fetchCardsInDeck({
    required String deckId,
  }) async {
    return (await localDatasource.fetchCardsInDeck(deckId: deckId))
        .map(CardInDeckMapper.toEntity)
        .toList();
  }

  @override
  Future<List<DeckEntity>> fetchForLocal() async {
    return (await localDatasource.fetch()).map(DeckMapper.toEntity).toList();
  }

  @override
  Future<List<DeckEntity>> fetchForRemote({
    required String userId,
  }) async {
    return (await remoteDatasource.fetch(userId: userId))
        .map(DeckMapper.toEntity)
        .toList();
  }

  @override
  Future<void> updateForLocal({
    required DeckEntity deck,
  }) async {
    await localDatasource.update(deck: DeckMapper.toModel(deck));
  }

  @override
  Future<bool> updateForRemote({
    required String userId,
    required DeckEntity deck,
  }) async {
    return await remoteDatasource.update(
        userId: userId, deck: DeckMapper.toModel(deck));
  }
}
