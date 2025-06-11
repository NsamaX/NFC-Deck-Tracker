import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/.config/game.dart';

import 'package:nfc_deck_tracker/data/datasource/api/@service_factory.dart';
import 'package:nfc_deck_tracker/data/model/card.dart';
import 'package:nfc_deck_tracker/data/model/deck.dart';
import 'package:nfc_deck_tracker/data/repository/fetch_card_in_deck.dart';
import 'package:nfc_deck_tracker/data/repository/fetch_card.dart';
import 'package:nfc_deck_tracker/data/repository/update_deck.dart';

import '../entity/deck.dart';
import '../mapper/card.dart';

class FetchCardInDeckUsecase {
  final FetchCardInDeckRepository fetchCardInDeckRepository;
  final FetchCardRepository fetchCardRepository;
  final UpdateDeckRepository updateDeckRepository;

  FetchCardInDeckUsecase({
    required this.fetchCardInDeckRepository,
    required this.fetchCardRepository,
    required this.updateDeckRepository,
  });

  Future<List<CardInDeckEntity>> call({
    required String userId,
    required String deckId,
    required String deckName,
    required String collectionId,
  }) async {
    final localCardModels = await fetchCardInDeckRepository.fetchLocalDeck(deckId: deckId);

    List<CardModel> remoteCards = [];

    if (Game.isSupported(collectionId)) {
      try {
        final gameApi = ServiceFactory.create<GameApi>(collectionId: collectionId);
        for (final model in localCardModels) {
          try {
            final apiCard = await gameApi.findCard(cardId: model.card.cardId);
            remoteCards.add(apiCard);
          } catch (_) {
            debugPrint("⚠️ ไม่พบการ์ด ${model.card.cardId} ใน GameApi");
          }
        }
      } catch (_) {
        debugPrint("❌ GameApi ไม่พร้อมสำหรับ $collectionId");
      }
    } else {
      try {
        remoteCards = await fetchCardRepository.fetchRemoteCard(
          userId: userId,
          collectionId: collectionId,
        );
      } catch (_) {
        debugPrint("⚠️ ไม่สามารถโหลดการ์ดจาก remote collection: $collectionId");
      }
    }

    final List<CardInDeckModel> updatedCards = [];

    for (final local in localCardModels) {
      final match = remoteCards.firstWhere(
        (r) => r.cardId == local.card.cardId,
        orElse: () => local.card,
      );

      updatedCards.add(CardInDeckModel(
        card: match,
        count: local.count,
      ));
    }

    final syncDeck = DeckModel(
      deckId: deckId,
      name: deckName,
      cards: updatedCards,
      isSynced: true,
      updatedAt: DateTime.now(),
    );

    await updateDeckRepository.updateLocalDeck(deck: syncDeck);

    return syncDeck.cards.map((c) => CardInDeckEntity(card: CardMapper.toEntity(c.card), count: c.count)).toList();
  }
}
// import 'package:flutter/foundation.dart';

// import 'package:nfc_deck_tracker/.config/game.dart';

// import 'package:nfc_deck_tracker/data/datasource/api/@service_factory.dart';
// import 'package:nfc_deck_tracker/data/model/card.dart';
// import 'package:nfc_deck_tracker/data/model/deck.dart';
// import 'package:nfc_deck_tracker/data/repository/create_card.dart';
// import 'package:nfc_deck_tracker/data/repository/create_card_in_deck.dart';
// import 'package:nfc_deck_tracker/data/repository/fetch_card_in_deck.dart';
// import 'package:nfc_deck_tracker/data/repository/fetch_card.dart';
// import 'package:nfc_deck_tracker/data/repository/update_deck.dart';

// import '../entity/deck.dart';
// import '../mapper/card.dart';

// class FetchCardInDeckUsecase {
//   final CreateCardRepository createCardRepository;
//   final CreateCardInDeckRepository createCardInDeckRepository;
//   final FetchCardInDeckRepository fetchCardInDeckRepository;
//   final FetchCardRepository fetchCardRepository;
//   final UpdateDeckRepository updateDeckRepository;

//   FetchCardInDeckUsecase({
//     required this.createCardRepository,
//     required this.createCardInDeckRepository,
//     required this.fetchCardInDeckRepository,
//     required this.fetchCardRepository,
//     required this.updateDeckRepository,
//   });

//   Future<List<CardInDeckEntity>> call({
//     required String userId,
//     required DeckEntity deck,
//   }) async {
//     final String? deckId = deck.deckId;
//     final String? deckName = deck.name;

//     if (deckId == null || deckName == null) return [];

//     final String? collectionId = deck.cards?.isNotEmpty == true
//         ? deck.cards!.first.card.collectionId
//         : null;

//     if (collectionId == null) return [];

//     // 1. ดึงข้อมูล local
//     final localCardLinks = await fetchCardInDeckRepository.fetchLocalDeck(deckId: deckId);
//     final localMap = {
//       for (final c in localCardLinks)
//         '${c.card.collectionId}-${c.card.cardId}': c
//     };

//     final List<CardInDeckModel> syncedCardLinks = [...localCardLinks];

//     // 2. ถ้ามี userId แสดงว่าซิงค์กับ remote ได้
//     if (userId.isNotEmpty) {
//       try {
//         final remoteCardLinks = await fetchCardInDeckRepository.fetchRemoteDeck(
//           userId: userId,
//           deckId: deckId,
//         );

//         final remoteMap = {
//           for (final c in remoteCardLinks)
//             '${c.card.collectionId}-${c.card.cardId}': c
//         };

//         bool hasChanges = false;

//         for (final key in remoteMap.keys) {
//           final remote = remoteMap[key]!;
//           final local = localMap[key];

//           if (local == null || local.count != remote.count) {
//             hasChanges = true;
//           }
//         }

//         if (hasChanges) {
//           await createCardInDeckRepository.createCardInDeck(
//             deck: DeckModel(
//               deckId: deckId,
//               name: deckName,
//               cards: remoteCardLinks,
//               isSynced: true,
//               updatedAt: DateTime.now(),
//             ),
//           );

//           syncedCardLinks
//             ..clear()
//             ..addAll(remoteCardLinks);

//           await updateDeckRepository.updateLocalDeck(
//             deck: DeckModel(
//               deckId: deckId,
//               name: deckName,
//               cards: remoteCardLinks,
//               isSynced: true,
//               updatedAt: DateTime.now(),
//             ),
//           );
//         }
//       } catch (e) {
//         debugPrint('⚠️ Failed to sync remote deck: $e');
//       }
//     }

//     // 3. ดึงการ์ดจาก local
//     final allCards = await fetchCardRepository.fetchLocalCard(collectionId: collectionId);
//     final cardMap = {
//       for (final c in allCards) '${c.collectionId}-${c.cardId}': c
//     };

//     // 4. รวมข้อมูลเป็น CardInDeckEntity (โหลดการ์ดจาก API ถ้าไม่พบใน local)
//     final result = <CardInDeckEntity>[];

//     for (final link in syncedCardLinks) {
//       final cardId = link.card.cardId;
//       final collectionId = link.card.collectionId;
//       final key = '$collectionId-$cardId';

//       CardModel? matchedCard = cardMap[key];

//       if (matchedCard != null) {
//         result.add(
//           CardInDeckEntity(
//             card: CardMapper.toEntity(matchedCard),
//             count: link.count,
//           ),
//         );
//       } else if (Game.isSupported(collectionId)) {
//         try {
//           final GameApi api = ServiceFactory.create<GameApi>(collectionId: collectionId);
//           matchedCard = await api.findCard(cardId: cardId);

//           await createCardRepository.createLocalCard(card: matchedCard);
//           cardMap[key] = matchedCard;
//           debugPrint('📡 Loaded supported card from API: $cardId');

//           result.add(
//             CardInDeckEntity(
//               card: CardMapper.toEntity(matchedCard),
//               count: link.count,
//             ),
//           );
//         } catch (e) {
//           debugPrint('⚠️ Failed to fetch supported card from API: $cardId — $e');
//         }
//       }

//       // 5. ถ้าการ์ดไม่เจอใน local และเป็น collection ผู้ใช้เอง → ดึงจาก remote Firestore
//       else if (!Game.isSupported(collectionId) && userId.isNotEmpty) {
//         try {
//           final remoteCards = await fetchCardRepository.fetchRemoteCard(
//             userId: userId,
//             collectionId: collectionId,
//           );

//           if (remoteCards.isNotEmpty) {
//             for (final card in remoteCards) {
//               await createCardRepository.createLocalCard(card: card); // หรือแบบ batch ถ้ามี
//               final key = '${card.collectionId}-${card.cardId}';
//               cardMap[key] = card;
//             }

//             matchedCard = cardMap[key];
//             debugPrint('📥 Loaded user card from remote: $cardId');
//           }
//         } catch (e) {
//           debugPrint('⚠️ Failed to load user card from remote: $cardId — $e');
//         }
//       }
//     }

//     return result;
//   }
// }
