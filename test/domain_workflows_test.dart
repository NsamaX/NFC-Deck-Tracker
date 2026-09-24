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
import 'package:nfc_deck_tracker/domain/entity/app_settings.dart';
import 'package:nfc_deck_tracker/domain/usecase/init_setting.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_setting.dart';
import 'package:nfc_deck_tracker/domain/value/card_lookup_failure.dart';
import 'package:nfc_deck_tracker/domain/value/remote_unavailable.dart';

class MemoryDecks extends Fake implements DeckRepository {
  final local = <String, DeckEntity>{};
  final remote = <String, DeckEntity>{};
  bool remoteSucceeds = true;
  bool remoteReadable = true;
  int remoteCalls = 0;
  @override
  Future<void> createForLocal({required DeckEntity deck}) async =>
      local[deck.deckId] = deck;
  @override
  Future<bool> createForRemote(
      {required String userId, required DeckEntity deck}) async {
    remoteCalls++;
    if (remoteSucceeds) remote[deck.deckId] = deck;
    return remoteSucceeds;
  }

  @override
  Future<List<DeckEntity>> fetchForLocal() async => local.values.toList();
  @override
  Future<List<DeckEntity>> fetchForRemote({required String userId}) async {
    remoteCalls++;
    if (!remoteReadable) throw const RemoteUnavailableException('offline');
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
  bool apiFails = false;
  int apiCalls = 0;
  @override
  Future<CardEntity?> findForLocal(
          {required String collectionId, required String cardId}) async =>
      local;
  @override
  Future<CardEntity?> findForApi(
      {required String collectionId, required String cardId}) async {
    apiCalls++;
    if (apiFails) throw UnsupportedError('no API for $collectionId');
    return api;
  }
}

class UnreachableCards extends MemoryCards {
  @override
  Future<CardEntity?> findForApi(
          {required String collectionId, required String cardId}) =>
      throw const RemoteUnavailableException('offline');
}

class MemorySettings implements SettingsRepository {
  AppSettings stored = const AppSettings(locale: 'ja');
  @override
  Future<AppSettings> load() async => stored;
  @override
  Future<void> save(AppSettings settings) async => stored = settings;
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
        userId: '', deckId: decks.single.deckId);
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
  test('a failed remote read keeps synced local decks instead of deleting them',
      () async {
    final repository = MemoryDecks()..remoteReadable = false;
    final synced = DeckEntity(
        deckId: 'kept',
        name: 'Kept',
        isSynced: true,
        updatedAt: DateTime(2024));
    repository.local['kept'] = synced;
    final decks =
        await FetchDeckUsecase(deckRepository: repository)(userId: 'u');
    expect(decks, [synced]);
    expect(repository.local['kept'], synced);
  });

  test('an empty remote still removes synced decks that were deleted remotely',
      () async {
    final repository = MemoryDecks();
    repository.local['gone'] = DeckEntity(
        deckId: 'gone',
        name: 'Gone',
        isSynced: true,
        updatedAt: DateTime(2024));
    final decks =
        await FetchDeckUsecase(deckRepository: repository)(userId: 'u');
    expect(decks, isEmpty);
    expect(repository.local, isEmpty);
  });

  test('an unsynced local deck uploaded during fetch is kept, not deleted',
      () async {
    final repository = MemoryDecks();
    repository.local['offline'] = DeckEntity(
        deckId: 'offline',
        name: 'Made offline',
        isSynced: false,
        updatedAt: DateTime(2024));
    final decks =
        await FetchDeckUsecase(deckRepository: repository)(userId: 'u');
    expect(decks.single.deckId, 'offline');
    expect(decks.single.isSynced, isTrue);
    expect(repository.remote.containsKey('offline'), isTrue);
    expect(repository.local['offline']!.isSynced, isTrue);
  });

  test('creating a deck returns the saved entity with a generated id',
      () async {
    final repository = MemoryDecks();
    final saved = await CreateDeckUsecase(deckRepository: repository)(
        userId: '', deck: const DeckEntity(name: 'New'));
    expect(saved.deckId, isNotEmpty);
    expect(repository.local[saved.deckId], saved);
    final kept = await CreateDeckUsecase(deckRepository: repository)(
        userId: '', deck: const DeckEntity(deckId: 'given', name: 'Given'));
    expect(kept.deckId, 'given');
  });

  test('a newer local deck is pushed to remote during fetch', () async {
    final repository = MemoryDecks();
    final old = DeckEntity(
        deckId: 'd', name: 'Old', isSynced: true, updatedAt: DateTime(2024, 1));
    repository.remote['d'] = old;
    repository.local['d'] =
        old.copyWith(name: 'New', updatedAt: DateTime(2024, 2));
    await FetchDeckUsecase(deckRepository: repository)(userId: 'u');
    expect(repository.remote['d']!.name, 'New');
  });

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
  Matcher failsWith(CardLookupFailure failure) => throwsA(
      isA<CardLookupException>().having((e) => e.failure, 'failure', failure));
  test('invalid tag fails before accessing repositories', () async {
    final cards = MemoryCards();
    await expectLater(
        FindCardFromTagUsecase(cardRepository: cards)(
            const TagEntity(tagId: 'tag', cardId: '', collectionId: '')),
        failsWith(CardLookupFailure.invalidTag));
    expect(cards.apiCalls, 0);
  });
  test('tag lookup reports a card missing from the API as not found', () async {
    await expectLater(
        FindCardFromTagUsecase(cardRepository: MemoryCards())(tag),
        failsWith(CardLookupFailure.cardNotFound));
  });
  test('tag lookup reports an unreachable API as unavailable', () async {
    final cards = UnreachableCards();
    await expectLater(FindCardFromTagUsecase(cardRepository: cards)(tag),
        failsWith(CardLookupFailure.unavailable));
  });
  test('tag lookup reports a failing API as an unsupported game', () async {
    await expectLater(
        FindCardFromTagUsecase(cardRepository: MemoryCards()..apiFails = true)(
            tag),
        failsWith(CardLookupFailure.gameNotSupported));
  });
  test('settings load stored values and can clear the guest id', () async {
    final repository = MemorySettings()
      ..stored = const AppSettings(locale: 'ja', guestId: 'g1');
    final settings = await InitSettingUsecase(settingsRepository: repository)();
    expect(settings.locale, 'ja');
    expect(settings.isGuest, isTrue);
    await UpdateSettingUsecase(settingsRepository: repository)(
        settings.copyWith(clearGuestId: true));
    expect(repository.stored.guestId, isNull);
    expect(repository.stored.locale, 'ja');
  });
}
