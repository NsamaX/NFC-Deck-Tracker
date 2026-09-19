import '../../domain/repository/card_catalog.dart';
import '../mapper/card.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/.config/game.dart';

import 'package:nfc_deck_tracker/data/datasource/api/@service_factory.dart';
import '../../domain/repository/collection.dart';
import '../../domain/repository/card.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import '../../domain/entity/card.dart';
import '../../domain/entity/collection.dart';
import '../../domain/entity/page.dart';
import '../mapper/page.dart';
import '../datasource/local/page.dart';

class CardCatalogRepositoryImpl implements CardCatalogRepository {
  final PageLocalDatasource pageDatasource;
  final CollectionRepository collectionRepository;
  final CardRepository cardRepository;
  final GameApi gameApi;

  CardCatalogRepositoryImpl({
    required this.pageDatasource,
    required this.collectionRepository,
    required this.cardRepository,
    required this.gameApi,
  });

  Future<List<CardEntity>> fetch({
    required String userId,
    required String collectionId,
    int? batchSize,
  }) async {
    final int effectiveBatchSize = batchSize ?? (kReleaseMode ? 20 : 1);

    final Map<String, CardEntity> cardMap = {};

    final localCards =
        await cardRepository.fetchForLocal(collectionId: collectionId);
    for (final card in localCards) {
      final entity = card;
      cardMap[entity.cardId] = entity;
    }

    final bool isFirstLoad = localCards.isEmpty;
    final bool isSupportedGame = GameConfig.instance.isSupported(collectionId);

    if (isFirstLoad) {
      LoggerUtil.d('[Local] No cards found for $collectionId');

      final existingCollection =
          await collectionRepository.find(collectionId: collectionId);

      if (existingCollection == null) {
        await collectionRepository.createForLocal(
          collection: CollectionEntity(
            collectionId: collectionId,
            name: GameConfig.instance.isSupported(collectionId)
                ? collectionId
                : 'unknow',
            isSynced: isSupportedGame,
          ),
        );
      } else {
        LoggerUtil.d(
            '[Local] Collection already exists, skipping creation in CardCatalogRepositoryImpl');
      }

      await pageDatasource.create(
        page: PageMapper.toModel(
          PageEntity(
            collectionId: collectionId,
            paging: {},
          ),
        ),
      );
    }

    if (isSupportedGame) {
      final Map<String, dynamic> localPageMap =
          await pageDatasource.find(collectionId: collectionId);
      final PagingStrategy pageStrategy =
          ServiceFactory.create(collectionId: collectionId);

      final Map<String, dynamic> pageMap =
          Map<String, dynamic>.from(localPageMap);
      final List<Map<String, dynamic>> pagesToFetch = [];

      if (!kReleaseMode) {
        pagesToFetch.add(pageStrategy.buildPage(current: pageMap, offset: 0));
      } else {
        for (int offset = 0; offset < effectiveBatchSize; offset++) {
          final page = pageStrategy.buildPage(current: pageMap, offset: offset);
          final pageKey = _normalizeKey(page: page);

          if (!pageMap.containsKey(pageKey)) {
            pagesToFetch.add(page);
          }
        }
      }

      for (final page in pagesToFetch) {
        final String pageKey = _normalizeKey(page: page);

        try {
          final apiCards = (await gameApi.fetch(page: page))
              .map(CardMapper.toEntity)
              .toList();

          if (apiCards.isNotEmpty) {
            await cardRepository.save(cards: apiCards);
            for (final card in apiCards) {
              final entity = card;
              cardMap[entity.cardId] = entity;
            }
            LoggerUtil.d(
                '[API] Loaded page: ${jsonEncode(page)} → ${apiCards.length} cards');
          } else {
            LoggerUtil.d('[API] Page has no more cards: ${jsonEncode(page)}');
            pageMap[pageKey] = true;

            await pageDatasource.update(
              page: PageMapper.toModel(
                PageEntity(
                  collectionId: collectionId,
                  paging: pageMap,
                ),
              ),
            );
          }
        } catch (e) {
          LoggerUtil.e('[Error] Failed to load page: ${jsonEncode(page)}\n$e');
        }
      }
    } else if (userId.isNotEmpty) {
      LoggerUtil.d('[Remote] Fetching cards from remote (custom collection)');

      try {
        final remoteCards = await cardRepository.fetchForRemote(
          userId: userId,
          collectionId: collectionId,
        );

        if (remoteCards.isNotEmpty) {
          await cardRepository.save(cards: remoteCards);
          for (final card in remoteCards) {
            final entity = card;
            cardMap[entity.cardId] = entity;
          }
          LoggerUtil.d('[Remote] Cards loaded from remote Firestore');
        } else {
          LoggerUtil.d('[Remote] No cards found in remote');
        }
      } catch (e) {
        LoggerUtil.e(
            '[Error] Failed to fetch remote cards for $collectionId\n$e');
      }
    }

    return cardMap.values.toList();
  }

  String _normalizeKey({
    required Map<String, dynamic> page,
  }) {
    final sorted = Map.fromEntries(
      page.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );

    return base64Url.encode(utf8.encode(json.encode(sorted)));
  }
}
