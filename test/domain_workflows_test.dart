import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/tag.dart';
import 'package:nfc_deck_tracker/domain/repository/deck.dart';
import 'package:nfc_deck_tracker/domain/repository/card.dart';
import 'package:nfc_deck_tracker/domain/repository/settings.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/delete_deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/find_card_from_tag.dart';
import 'package:nfc_deck_tracker/domain/usecase/init_setting.dart';

class MemoryDecks extends Fake implements DeckRepository {
  final local = <String, DeckEntity>{};
  final remote = <String, DeckEntity>{};
  bool remoteSucceeds = true;
  int remoteCalls = 0;
  @override
  Future<void> createForLocal({required DeckEntity deck}) async =>
      local[deck.deckId!] = deck;
  @override
  Future<bool> createForRemote(
      {required String userId, required DeckEntity deck}) async {
    remoteCalls++;
    if (remoteSucceeds) remote[deck.deckId!] = deck;
    return remoteSucceeds;
  }

  @override
  Future<List<DeckEntity>> fetchForLocal() async => local.values.toList();
  @override
  Future<List<DeckEntity>> fetchForRemote({required String userId}) async {
    remoteCalls++;
    return remote.values.toList();
  }

  @override
  Future<void> updateForLocal({required DeckEntity deck}) =>
      createForLocal(deck: deck);
  @override
  Future<bool> updateForRemote(
          {required String userId, required DeckEntity deck}) =>
      createForRemote(userId: userId, deck: deck);
  @override
  Future<bool> deleteForLocal({required String deckId}) async =>
      local.remove(deckId) != null;
  @override
  Future<bool> deleteForRemote(
      {required String userId, required String deckId}) async {
    remoteCalls++;
    return remote.remove(deckId) != null;
  }
}

class MemoryCards extends Fake implements CardRepository {
  CardEntity? local;
  CardEntity? api;
  int apiCalls = 0;
  @override
  Future<CardEntity?> findForLocal(
          {required String collectionId, required String cardId}) async =>
      local;
  @override
  Future<CardEntity?> findForApi(
      {required String collectionId, required String cardId}) async {
    apiCalls++;
    return api;
  }
}

class MemorySettings implements SettingsRepository {
  final values = <String, dynamic>{'locale': 'ja'};
  @override
  Future<dynamic> load({required String key}) async => values[key];
  @override
  Future<void> update({required String key, required dynamic value}) async =>
      values[key] = value;
}

void main() {
  test('Guest can create, read, update and delete a deck through domain ports',
      () async {
    final repository = MemoryDecks();
    await CreateDeckUsecase(deckRepository: repository)(
        userId: '', deck: const DeckEntity(name: 'First', cards: []));
    final decks =
        await FetchDeckUsecase(deckRepository: repository)(userId: '');
    expect(decks.single.deckId, isNotEmpty);
    expect(decks.single.isSynced, isFalse);
    await UpdateDeckUsecase(deckRepository: repository)(
        userId: '', deck: decks.single.copyWith(name: 'Renamed'));
    expect(repository.local.values.single.name, 'Renamed');
    expect(repository.local.values.single.updatedAt, isNotNull);
    await DeleteDeckUsecase(deckRepository: repository)(
        userId: '', deckId: decks.single.deckId!);
    expect(repository.local, isEmpty);
    expect(repository.remoteCalls, 0);
  });

  for (final succeeds in [true, false]) {
    test('creating online preserves the remote sync result: $succeeds',
        () async {
      final repository = MemoryDecks()..remoteSucceeds = succeeds;
      await CreateDeckUsecase(deckRepository: repository)(
          userId: 'user', deck: const DeckEntity(name: 'Online', cards: []));
      expect(repository.local.values.single.isSynced, succeeds);
      expect(repository.remoteCalls, 1);
      expect(repository.remote.isNotEmpty, succeeds);
    });
  }

  test('remote decks import through the same entity port', () async {
    final repository = MemoryDecks();
    final deck = DeckEntity(
        deckId: 'remote',
        name: 'Shared',
        cards: const [],
        isSynced: true,
        updatedAt: DateTime(2025));
    repository.remote['remote'] = deck;
    expect(await FetchDeckUsecase(deckRepository: repository)(userId: 'user'),
        [deck]);
    expect(repository.local['remote'], deck);
  });

  const tag = TagEntity(tagId: 'tag', cardId: 'card', collectionId: 'game');
  test('tag lookup prefers local data without calling the API', () async {
    final cards = MemoryCards()
      ..local = const CardEntity(cardId: 'card', collectionId: 'game');
    expect(
        await FindCardFromTagUsecase(cardRepository: cards)(tag), cards.local);
    expect(cards.apiCalls, 0);
  });
  test('tag lookup falls back to the API when local data is missing', () async {
    final cards = MemoryCards()
      ..api = const CardEntity(cardId: 'card', collectionId: 'game');
    expect(await FindCardFromTagUsecase(cardRepository: cards)(tag), cards.api);
    expect(cards.apiCalls, 1);
  });
  test('invalid tag fails before accessing repositories', () async {
    final lookup = FindCardFromTagUsecase(cardRepository: MemoryCards());
    await expectLater(
        lookup(const TagEntity(tagId: 'tag', cardId: '', collectionId: '')),
        throwsException);
  });
  test('settings preserve stored values and honor injected default exclusions',
      () async {
    final repository = MemorySettings();
    final values = await InitSettingUsecase(
        settingsRepository: repository, ignoreDefaultWriteKeys: ['guestId'])(
      {'locale': 'th', 'isDark': true, 'guestId': null},
    );
    expect(values, {'locale': 'ja', 'isDark': true});
    expect(repository.values.containsKey('guestId'), isFalse);
  });
}
