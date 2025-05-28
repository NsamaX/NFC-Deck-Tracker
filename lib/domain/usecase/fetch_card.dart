import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/.game_config/game_constant.dart';

import 'package:nfc_deck_tracker/data/datasource/api/_service_factory.dart';
import 'package:nfc_deck_tracker/data/model/collection.dart';
import 'package:nfc_deck_tracker/data/model/page.dart';
import 'package:nfc_deck_tracker/data/repository/create_collection.dart';
import 'package:nfc_deck_tracker/data/repository/create_page.dart';
import 'package:nfc_deck_tracker/data/repository/fetch_card.dart';
import 'package:nfc_deck_tracker/data/repository/find_page.dart';
import 'package:nfc_deck_tracker/data/repository/save_card.dart';
import 'package:nfc_deck_tracker/data/repository/update_page.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import '../entity/card.dart';
import '../mapper/card.dart';

class FetchCardUsecase {
  final CreateCollectionRepository createCollectionRepository;
  final CreatePageRepository createPageRepository;
  final FetchCardRepository fetchCardRepository;
  final FindPageRepository findPageRepository;
  final SaveCardRepository saveCardRepository;
  final UpdatePageRepository updatePageRepository;

  FetchCardUsecase({
    required this.createCollectionRepository,
    required this.createPageRepository,
    required this.fetchCardRepository,
    required this.findPageRepository,
    required this.saveCardRepository,
    required this.updatePageRepository,
  });

  Future<List<CardEntity>> call({
    required String userId,
    required String collectionId,
    required String collectionName,
    int? batchSize,
  }) async {
    final int effectiveBatchSize = batchSize ?? (kReleaseMode ? 5 : 1);

    final localCards = await fetchCardRepository.fetchLocalCard(
      collectionId: collectionId,
    );

    final bool isFirstLoad = localCards.isEmpty;
    final bool isSupportedGame = GameConstant.isSupported(collectionId);

    if (isFirstLoad) {
      LoggerUtil.addMessage(message: '[Local] No cards found for $collectionId');

      await createCollectionRepository.createLocalCollection(
        collection: CollectionModel(
          collectionId: collectionId,
          name: collectionName,
          isSynced: isSupportedGame,
          updatedAt: DateTime.now(),
        ),
      );

      await createPageRepository.createPage(
        page: PageModel(
          collectionId: collectionId,
          paging: {},
        ),
      );
    } else {
      LoggerUtil.addMessage(message: '[Local] Found ${localCards.length} cards for $collectionId');
    }

    if (isSupportedGame) {
      final Map<String, dynamic> localPageMap = await findPageRepository.findPage(
        collectionId: collectionId,
      );

      final PagingStrategy pageStrategy = ServiceFactory.create(collectionId: collectionId);

      final Map<String, dynamic> pageMap = Map<String, dynamic>.from(localPageMap);
      final List<Map<String, dynamic>> pagesToFetch = [];

      if (!kReleaseMode) {
        final page = pageStrategy.buildPage(current: pageMap, offset: 0);
        pagesToFetch.add(page);
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
          LoggerUtil.addMessage(message: '[API] Fetching page: ${jsonEncode(page)}');

          final cards = await fetchCardRepository.fetchApiCard(page: page);
          LoggerUtil.addMessage(message: '🃏 ${cards.length} cards loaded from API');

          if (cards.isNotEmpty) {
            await saveCardRepository.saveCard(cards: cards);
          }

          if (cards.isEmpty) {
            LoggerUtil.addMessage(message: '[Page] Reached last page → updating paging info');

            pageMap[pageKey] = true;

            await updatePageRepository.updatePage(
              page: PageModel(
                collectionId: collectionId,
                paging: pageMap,
              ),
            );
          }
        } catch (e) {
          LoggerUtil.addMessage(message: '[Error] Failed to load page: ${jsonEncode(page)}\n$e');
        }
      }

      LoggerUtil.flushMessages();
    } else if (userId.isNotEmpty) {
      LoggerUtil.addMessage(message: '[Remote] Fetching custom collection from remote');

      try {
        final remoteCards = await fetchCardRepository.fetchRemoteCard(
          userId: userId,
          collectionId: collectionId,
        );

        if (remoteCards.isNotEmpty) {
          await saveCardRepository.saveCard(cards: remoteCards);
          LoggerUtil.addMessage(message: '🃏 ${remoteCards.length} cards loaded from remote Firestore');
        } else {
          LoggerUtil.addMessage(message: 'ℹ️ No cards found in remote');
        }
      } catch (e) {
        LoggerUtil.addMessage(message: '[Error] Failed to fetch remote cards for $collectionId\n$e');
      }

      LoggerUtil.flushMessages();

      final updated = await fetchCardRepository.fetchLocalCard(
        collectionId: collectionId,
      );

      return updated.map(CardMapper.toEntity).toList();
    }

    final updatedCards = await fetchCardRepository.fetchLocalCard(
      collectionId: collectionId,
    );

    return updatedCards.map(CardMapper.toEntity).toList();
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
