import '../../domain/entity/card.dart';
import '../../domain/repository/card.dart';
import '../datasource/api/service_factory.dart';
import '../datasource/api/game_api.dart';
import '../mapper/card.dart';
import '../datasource/local/card.dart';
import '../datasource/remote/card.dart';

class CardRepositoryImpl implements CardRepository {
  final CardLocalDatasource localDatasource;
  final CardRemoteDatasource remoteDatasource;

  CardRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
  });

  @override
  Future<int> check({
    required String collectionId,
    required String name,
  }) async {
    return await localDatasource.countByName(
        collectionId: collectionId, name: name);
  }

  @override
  Future<void> createForLocal({
    required CardEntity card,
  }) async {
    await localDatasource.create(card: CardMapper.toModel(card));
  }

  @override
  Future<bool> createForRemote({
    required String userId,
    required CardEntity card,
  }) async {
    return await remoteDatasource.create(
        userId: userId, card: CardMapper.toModel(card));
  }

  @override
  Future<void> deleteForLocal({
    required String collectionId,
    required String cardId,
  }) async {
    await localDatasource.delete(collectionId: collectionId, cardId: cardId);
  }

  @override
  Future<bool> deleteForRemote({
    required String userId,
    required String collectionId,
    required String cardId,
  }) async {
    return await remoteDatasource.delete(
        userId: userId, collectionId: collectionId, cardId: cardId);
  }

  @override
  Future<List<CardEntity>> fetchForLocal({
    required String collectionId,
  }) async {
    return (await localDatasource.fetch(collectionId: collectionId))
        .map(CardMapper.toEntity)
        .toList();
  }

  @override
  Future<List<CardEntity>> fetchForRemote({
    required String userId,
    required String collectionId,
  }) async {
    return (await remoteDatasource.fetch(
            userId: userId, collectionId: collectionId))
        .map(CardMapper.toEntity)
        .toList();
  }

  @override
  Future<List<CardEntity>> fetchUsedCards() async {
    return (await localDatasource.fetchUsedDistinct())
        .map(CardMapper.toEntity)
        .toList();
  }

  @override
  Future<CardEntity?> findForApi({
    required String collectionId,
    required String cardId,
  }) async {
    final GameApi gameApi = ServiceFactory.create(collectionId: collectionId);
    final model = await gameApi.find(cardId: cardId);
    return model == null ? null : CardMapper.toEntity(model);
  }

  @override
  Future<CardEntity?> findForLocal({
    required String collectionId,
    required String cardId,
  }) async {
    final model =
        await localDatasource.find(collectionId: collectionId, cardId: cardId);
    return model == null ? null : CardMapper.toEntity(model);
  }

  @override
  Future<void> save({
    required List<CardEntity> cards,
  }) async {
    await localDatasource.save(cards: cards.map(CardMapper.toModel).toList());
  }

  @override
  Future<void> updateForLocal({
    required CardEntity card,
  }) async {
    await localDatasource.update(card: CardMapper.toModel(card));
  }

  @override
  Future<bool> updateForRemote({
    required String userId,
    required CardEntity card,
  }) async {
    return await remoteDatasource.update(
        userId: userId, card: CardMapper.toModel(card));
  }
}
