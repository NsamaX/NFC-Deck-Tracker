import '../../domain/entity/card.dart';
import '../../domain/repository/card.dart';
import '../datasource/api/@service_factory.dart';
import '../datasource/local/check_card_duplicate_name.dart';
import '../datasource/local/create_card.dart';
import '../datasource/local/delete_card.dart';
import '../datasource/local/fetch_card.dart';
import '../datasource/local/fetch_used_card_distinct.dart';
import '../datasource/local/find_card.dart';
import '../datasource/local/save_card.dart';
import '../datasource/local/update_card.dart';
import '../datasource/remote/create_card.dart';
import '../datasource/remote/delete_card.dart';
import '../datasource/remote/fetch_card.dart';
import '../datasource/remote/update_card.dart';
import '../mapper/card.dart';

class CardRepositoryImpl implements CardRepository {
  final CheckCardDuplicateNameLocalDatasource
      checkCardDuplicateNameLocalDatasource;
  final CreateCardLocalDatasource createCardLocalDatasource;
  final CreateCardRemoteDatasource createCardRemoteDatasource;
  final DeleteCardLocalDatasource deleteCardLocalDatasource;
  final DeleteCardRemoteDatasource deleteCardRemoteDatasource;
  final FetchCardLocalDatasource fetchCardLocalDatasource;
  final FetchCardRemoteDatasource fetchCardRemoteDatasource;
  final FetchUsedCardDistinctLocalDatasource
      fetchUsedCardDistinctLocalDatasource;
  final FindCardLocalDatasource findCardLocalDatasource;
  final SaveCardLocalDatasource saveCardLocalDatasource;
  final UpdateCardLocalDatasource updateCardLocalDatasource;
  final UpdateCardRemoteDatasource updateCardRemoteDatasource;

  CardRepositoryImpl({
    required this.checkCardDuplicateNameLocalDatasource,
    required this.createCardLocalDatasource,
    required this.createCardRemoteDatasource,
    required this.deleteCardLocalDatasource,
    required this.deleteCardRemoteDatasource,
    required this.fetchCardLocalDatasource,
    required this.fetchCardRemoteDatasource,
    required this.fetchUsedCardDistinctLocalDatasource,
    required this.findCardLocalDatasource,
    required this.saveCardLocalDatasource,
    required this.updateCardLocalDatasource,
    required this.updateCardRemoteDatasource,
  });

  @override
  Future<int> check({
    required String collectionId,
    required String name,
  }) async {
    return await checkCardDuplicateNameLocalDatasource.check(
        collectionId: collectionId, name: name);
  }

  @override
  Future<void> createForLocal({
    required CardEntity card,
  }) async {
    await createCardLocalDatasource.create(card: CardMapper.toModel(card));
  }

  @override
  Future<bool> createForRemote({
    required String userId,
    required CardEntity card,
  }) async {
    return await createCardRemoteDatasource.create(
        userId: userId, card: CardMapper.toModel(card));
  }

  @override
  Future<void> deleteForLocal({
    required String collectionId,
    required String cardId,
  }) async {
    await deleteCardLocalDatasource.delete(
        collectionId: collectionId, cardId: cardId);
  }

  @override
  Future<bool> deleteForRemote({
    required String userId,
    required String collectionId,
    required String cardId,
  }) async {
    return await deleteCardRemoteDatasource.delete(
        userId: userId, collectionId: collectionId, cardId: cardId);
  }

  @override
  Future<List<CardEntity>> fetchForLocal({
    required String collectionId,
  }) async {
    return (await fetchCardLocalDatasource.fetch(collectionId: collectionId))
        .map(CardMapper.toEntity)
        .toList();
  }

  @override
  Future<List<CardEntity>> fetchForRemote({
    required String userId,
    required String collectionId,
  }) async {
    return (await fetchCardRemoteDatasource.fetch(
            userId: userId, collectionId: collectionId))
        .map(CardMapper.toEntity)
        .toList();
  }

  @override
  Future<List<CardEntity>> fetchUsedCards() async {
    return (await fetchUsedCardDistinctLocalDatasource.fetch())
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
    final model = await findCardLocalDatasource.find(
        collectionId: collectionId, cardId: cardId);
    return model == null ? null : CardMapper.toEntity(model);
  }

  @override
  Future<void> save({
    required List<CardEntity> cards,
  }) async {
    await saveCardLocalDatasource.save(
        cards: cards.map(CardMapper.toModel).toList());
  }

  @override
  Future<void> updateForLocal({
    required CardEntity card,
  }) async {
    await updateCardLocalDatasource.update(card: CardMapper.toModel(card));
  }

  @override
  Future<bool> updateForRemote({
    required String userId,
    required CardEntity card,
  }) async {
    return await updateCardRemoteDatasource.update(
        userId: userId, card: CardMapper.toModel(card));
  }
}
