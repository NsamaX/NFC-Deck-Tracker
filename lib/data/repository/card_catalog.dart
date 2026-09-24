import 'package:nfc_deck_tracker/.config/game.dart';
import 'package:nfc_deck_tracker/util/logger.dart';

import '../../domain/entity/card.dart';
import '../../domain/entity/collection.dart';
import '../../domain/repository/card.dart';
import '../../domain/repository/card_catalog.dart';
import '../../domain/repository/collection.dart';
import '../../domain/service/sync_policy.dart';
import '../datasource/api/game_api.dart';
import '../datasource/api/game_api_registry.dart';
import '../datasource/local/page.dart';
import '../mapper/card.dart';
import '../model/page.dart';

class CardCatalogRepositoryImpl implements CardCatalogRepository {
  final PageLocalDatasource pageDatasource;
  final CollectionRepository collectionRepository;
  final CardRepository cardRepository;
  final GameApiRegistry apis;
  final int defaultBatchSize;
  final bool Function(String collectionId) _isBuiltIn;

  CardCatalogRepositoryImpl({
    required this.pageDatasource,
    required this.collectionRepository,
    required this.cardRepository,
    required this.apis,
    required this.defaultBatchSize,
    bool Function(String collectionId)? isBuiltIn,
  }) : _isBuiltIn = isBuiltIn ?? ((id) => GameConfig.instance.isSupported(id));

  @override
  Future<List<CardEntity>> fetch({
    required String userId,
    required String collectionId,
    int? batchSize,
  }) async {
    final isBuiltIn = _isBuiltIn(collectionId);
    await _ensureCollection(collectionId, isBuiltIn: isBuiltIn);

    if (!isBuiltIn) {
      return _syncCustomCards(userId: userId, collectionId: collectionId);
    }

    await _loadNextPages(
      collectionId: collectionId,
      batchSize: batchSize ?? defaultBatchSize,
    );
    return cardRepository.fetchForLocal(collectionId: collectionId);
  }

  Future<void> _ensureCollection(
    String collectionId, {
    required bool isBuiltIn,
  }) async {
    if (await collectionRepository.find(collectionId: collectionId) != null) {
      return;
    }
    await collectionRepository.createForLocal(
      collection: CollectionEntity(
        collectionId: collectionId,
        name: isBuiltIn ? collectionId : CollectionEntity.unknownName,
        isSynced: isBuiltIn,
      ),
    );
  }

  Future<void> _loadNextPages({
    required String collectionId,
    required int batchSize,
  }) async {
    final state = await pageDatasource.find(collectionId: collectionId);
    if (state['exhausted'] == true) return;
    final api = apis.forCollection(collectionId);
    if (api == null) return;

    var cursor = Map<String, dynamic>.from(state['cursor'] as Map? ?? {});
    var exhausted = false;
    var loaded = 0;

    for (; loaded < batchSize; loaded++) {
      final CardPage page;
      try {
        page = await api.fetch(cursor);
      } catch (e) {
        LoggerUtil.e('[API] Failed to load $collectionId page $cursor: $e');
        break;
      }
      if (page.cards.isNotEmpty) {
        await cardRepository.save(
            cards: page.cards.map(CardMapper.toEntity).toList());
      }
      final next = page.next;
      if (next == null) {
        exhausted = true;
        loaded++;
        break;
      }
      cursor = next;
    }

    if (loaded == 0) return;
    await pageDatasource.save(
      page: PageModel(
        collectionId: collectionId,
        paging: {'cursor': cursor, 'exhausted': exhausted},
      ),
    );
  }

  Future<List<CardEntity>> _syncCustomCards({
    required String userId,
    required String collectionId,
  }) async {
    return const SyncPolicy().reconcile<CardEntity>(
      userId: userId,
      local: await cardRepository.fetchForLocal(collectionId: collectionId),
      fetchRemote: () => cardRepository.fetchForRemote(
          userId: userId, collectionId: collectionId),
      target: SyncTarget<CardEntity>(
        id: (e) => e.cardId,
        updatedAt: (e) => e.updatedAt,
        isSynced: (e) => e.isSynced,
        markSynced: (e, value) => e.copyWith(isSynced: value),
        createLocal: (e) => cardRepository.createForLocal(card: e),
        updateLocal: (e) => cardRepository.updateForLocal(card: e),
        deleteLocal: (e) async {
          await cardRepository.deleteForLocal(
              collectionId: e.collectionId, cardId: e.cardId);
          return true;
        },
        createRemote: (e) =>
            cardRepository.createForRemote(userId: userId, card: e),
        updateRemote: (e) =>
            cardRepository.updateForRemote(userId: userId, card: e),
      ),
    );
  }
}
