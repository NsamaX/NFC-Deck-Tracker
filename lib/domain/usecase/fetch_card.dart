import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/.config/game.dart';

import 'package:nfc_deck_tracker/data/datasource/api/@service_factory.dart';
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

    final localCards = await fetchCardRepository.fetchLocalCard(collectionId: collectionId);
    final combinedCards = [...localCards];

    final bool isFirstLoad = localCards.isEmpty;
    final bool isSupportedGame = Game.isSupported(game: collectionId);

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
      LoggerUtil.addMessage(message: '[Local] Cards loaded from local database');
    }

    if (isSupportedGame) {
      final Map<String, dynamic> localPageMap = await findPageRepository.findPage(collectionId: collectionId);
      final PagingStrategy pageStrategy = ServiceFactory.create(collectionId: collectionId);

      final Map<String, dynamic> pageMap = Map<String, dynamic>.from(localPageMap);
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
          final apiCards = await fetchCardRepository.fetchApiCard(page: page);

          if (apiCards.isNotEmpty) {
            await saveCardRepository.saveCard(cards: apiCards);
            combinedCards.addAll(apiCards);
            LoggerUtil.addMessage(message: '[API] Loaded page: ${jsonEncode(page)} → ${apiCards.length} cards');
          } else {
            LoggerUtil.addMessage(message: '[API] Page has no more cards: ${jsonEncode(page)}');
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
      LoggerUtil.addMessage(message: '[Remote] Fetching cards from remote (custom collection)');

      try {
        final remoteCards = await fetchCardRepository.fetchRemoteCard(
          userId: userId,
          collectionId: collectionId,
        );

        if (remoteCards.isNotEmpty) {
          await saveCardRepository.saveCard(cards: remoteCards);
          combinedCards.addAll(remoteCards);
          LoggerUtil.addMessage(message: '[Remote] Cards loaded from remote Firestore');
        } else {
          LoggerUtil.addMessage(message: '[Remote] No cards found in remote');
        }
      } catch (e) {
        LoggerUtil.addMessage(message: '[Error] Failed to fetch remote cards for $collectionId\n$e');
      }

      LoggerUtil.flushMessages();
    }

    return combinedCards.map(CardMapper.toEntity).toList();
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
