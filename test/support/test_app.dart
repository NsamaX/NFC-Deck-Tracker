import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/.config/api.dart';
import 'package:nfc_deck_tracker/.config/game.dart';
import 'package:nfc_deck_tracker/data/repository/session.dart';
import 'package:nfc_deck_tracker/domain/entity/app_settings.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/card_in_deck.dart';
import 'package:nfc_deck_tracker/domain/entity/collection.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/nfc_result.dart';
import 'package:nfc_deck_tracker/domain/entity/record.dart';
import 'package:nfc_deck_tracker/domain/entity/selected_image.dart';
import 'package:nfc_deck_tracker/domain/entity/share_record.dart';
import 'package:nfc_deck_tracker/domain/repository/card.dart';
import 'package:nfc_deck_tracker/domain/repository/card_catalog.dart';
import 'package:nfc_deck_tracker/domain/repository/collection.dart';
import 'package:nfc_deck_tracker/domain/repository/deck.dart';
import 'package:nfc_deck_tracker/domain/repository/device.dart';
import 'package:nfc_deck_tracker/domain/repository/image.dart';
import 'package:nfc_deck_tracker/domain/repository/local_data.dart';
import 'package:nfc_deck_tracker/domain/repository/nfc.dart';
import 'package:nfc_deck_tracker/domain/repository/record.dart';
import 'package:nfc_deck_tracker/domain/repository/settings.dart';
import 'package:nfc_deck_tracker/domain/usecase/index.dart';
import 'package:nfc_deck_tracker/presentation/bloc/index.dart';
import 'package:nfc_deck_tracker/presentation/dependencies.dart';
import 'package:nfc_deck_tracker/presentation/locale/language_manager.dart';
import 'package:nfc_deck_tracker/presentation/locale/localization.dart';
import 'package:nfc_deck_tracker/presentation/route/generator.dart';
import 'package:nfc_deck_tracker/presentation/theme/theme.dart';
import 'package:nfc_deck_tracker/presentation/widget/notification/app_error_banner.dart';

class MemoryDecks extends Fake implements DeckRepository {
  final local = <String, DeckEntity>{};
  @override
  Future<void> createForLocal({required DeckEntity deck}) async =>
      local[deck.deckId] = deck;
  @override
  Future<void> updateForLocal({required DeckEntity deck}) async =>
      local[deck.deckId] = deck;
  @override
  Future<bool> deleteForLocal({required String deckId}) async =>
      local.remove(deckId) != null;
  @override
  Future<List<DeckEntity>> fetchForLocal() async => local.values.toList();
  @override
  Future<List<CardInDeckEntity>> fetchCardsInDeck(
          {required String deckId}) async =>
      local[deckId]?.cards ?? [];
}

class MemoryCards extends Fake implements CardRepository {
  final local = <String, CardEntity>{};
  @override
  Future<void> createForLocal({required CardEntity card}) async =>
      local[card.cardId] = card;
  @override
  Future<void> updateForLocal({required CardEntity card}) async =>
      local[card.cardId] = card;
  @override
  Future<void> deleteForLocal(
          {required String collectionId, required String cardId}) async =>
      local.remove(cardId);
  @override
  Future<List<CardEntity>> fetchForLocal(
          {required String collectionId}) async =>
      local.values.where((c) => c.collectionId == collectionId).toList();
  @override
  Future<List<CardEntity>> fetchUsedCards() async => local.values.toList();
  @override
  Future<int> check(
          {required String collectionId, required String name}) async =>
      0;
  @override
  Future<CardEntity?> findForLocal(
          {required String collectionId, required String cardId}) async =>
      local[cardId];
}

class MemoryCollections extends Fake implements CollectionRepository {
  final local = <String, CollectionEntity>{};
  @override
  Future<void> createForLocal({required CollectionEntity collection}) async =>
      local[collection.collectionId] = collection;
  @override
  Future<void> updateForLocal({required CollectionEntity collection}) async =>
      local[collection.collectionId] = collection;
  @override
  Future<bool> deleteForLocal({required String collectionId}) async =>
      local.remove(collectionId) != null;
  @override
  Future<List<CollectionEntity>> fetchForLocal() async => local.values.toList();
  @override
  Future<CollectionEntity?> find({required String collectionId}) async =>
      local[collectionId];
  @override
  Future<void> touch({required String collectionId}) async {}
}

class MemoryRecords extends Fake implements RecordRepository {
  final local = <String, RecordEntity>{};
  @override
  Future<void> createForLocal({required RecordEntity record}) async =>
      local[record.recordId] = record;
  @override
  Future<void> updateForLocal({required RecordEntity record}) async =>
      local[record.recordId] = record;
  @override
  Future<bool> deleteForLocal({required String recordId}) async =>
      local.remove(recordId) != null;
  @override
  Future<List<RecordEntity>> fetchForLocal({required String deckId}) async =>
      local.values.where((r) => r.deckId == deckId).toList();
  @override
  Future<ShareRecordEntity?> import({required String userId}) async => null;
}

class MemorySettings implements SettingsRepository {
  AppSettings stored;
  MemorySettings(this.stored);
  @override
  Future<AppSettings> load() async => stored;
  @override
  Future<void> save(AppSettings settings) async => stored = settings;
}

class LocalCatalog implements CardCatalogRepository {
  final MemoryCards cards;
  LocalCatalog(this.cards);
  @override
  Future<List<CardEntity>> fetch(
          {required String userId,
          required String collectionId,
          int? batchSize}) =>
      cards.fetchForLocal(collectionId: collectionId);
}

class FakeDevice implements DeviceRepository {
  String nextImagePath = '/tmp/picked.png';
  @override
  Stream<bool> get connectivityChanges => Stream.value(true);
  @override
  Future<String> appVersion() async => '1.0.0-test';
  @override
  Future<SelectedImage> selectCardImage() async =>
      SelectedImage(status: ImageSelectionStatus.selected, path: nextImagePath);
}

class NoNfc implements NfcRepository {
  @override
  Future<bool> isAvailable() async => false;
  @override
  Future<void> start(
      {CardEntity? card, required void Function(NfcResult) onResult}) async {}
  @override
  Future<void> stop() async {}
}

class PassThroughImages implements ImageRepository {
  @override
  Future<bool> delete({required List<String> imageUrls}) async => true;
  @override
  Future<String?> update(
          {required String oldImageUrl, required String newImagePath}) async =>
      newImagePath;
  @override
  Future<String?> upload({required String imagePath}) async => imagePath;
}

class NoLocalData implements LocalDataRepository {
  @override
  Future<void> clear() async {}
}

class TestWorld {
  final decks = MemoryDecks();
  final cards = MemoryCards();
  final collections = MemoryCollections();
  final records = MemoryRecords();
  final settings = MemorySettings(
      const AppSettings(guestId: 'guest', showNfcTutorial: false));
  final device = FakeDevice();
  final nfc = NoNfc();
  final images = PassThroughImages();

  late final PresentationDependencies dependencies;
  final createdBlocs = <BlocBase<dynamic>>[];

  T _track<T extends BlocBase<dynamic>>(T bloc) {
    createdBlocs.add(bloc);
    return bloc;
  }

  TestWorld() {
    final session = SessionUsecase(GuestSessionRepository());
    final deviceUsecase = DeviceUsecase(device);
    dependencies = PresentationDependencies(
      nfcBloc: NfcBloc(session: NfcSessionUsecase(nfc)),
      deckBloc: DeckBloc(
        fetchDeckUsecase: FetchDeckUsecase(deckRepository: decks),
        deleteDeckUsecase: DeleteDeckUsecase(deckRepository: decks),
      ),
      deckBuilderBloc: DeckBuilderBloc(
        createDeckUsecase: CreateDeckUsecase(deckRepository: decks),
        updateDeckUsecase: UpdateDeckUsecase(deckRepository: decks),
        fetchCardInDeckUsecase: FetchCardInDeckUsecase(deckRepository: decks),
        updateCardInDeckUsecase: UpdateCardInDeckUsecase(),
        generateShareDeckClipboardUsecase: GenerateShareDeckClipboardUsecase(),
      ),
      session: session,
      device: deviceUsecase,
      applicationBloc: ApplicationBloc(
        clearUserDataUsecase: ClearUserDataUsecase(
          localDataRepository: NoLocalData(),
          imageRepository: images,
          cardRepository: cards,
        ),
        initSettingUsecase: InitSettingUsecase(settingsRepository: settings),
        updateSettingUsecase:
            UpdateSettingUsecase(settingsRepository: settings),
        sessionUsecase: session,
        deviceUsecase: deviceUsecase,
      ),
      collectionBloc: CollectionBloc(
        createCollectionUsecase:
            CreateCollectionUsecase(collectionRepository: collections),
        deleteCollectionUsecase:
            DeleteCollectionUsecase(collectionRepository: collections),
        fetchCollectionUsecase:
            FetchCollectionUsecase(collectionRepository: collections),
        fetchDeckUsecase: FetchDeckUsecase(deckRepository: decks),
        fetchUsedCardDistinctUsecase:
            FetchUsedCardDistinctUsecase(cardRepository: cards),
      ),
      routeObserver: RouteObserver<ModalRoute>(),
      createCardBloc: () => _track(CardBloc(
        createCardUsecase: CreateCardUsecase(
          cardRepository: cards,
          collectionRepository: collections,
          imageRepository: images,
        ),
        updateCardUsecase:
            UpdateCardUsecase(cardRepository: cards, imageRepository: images),
      )),
      createDrawerBloc: () => _track(DrawerBloc()),
      createPinCardBloc: () => _track(PinCardBloc()),
      createBrowseCardBloc: (collectionId) => _track(BrowseCardBloc(
        deleteCardUsecase:
            DeleteCardUsecase(cardRepository: cards, imageRepository: images),
        fetchCardUsecase: FetchCardUsecase(repository: LocalCatalog(cards)),
      )),
      createReaderBloc: (collectionId) => _track(ReaderBloc(
        findCardFromTagUsecase: FindCardFromTagUsecase(cardRepository: cards),
      )),
      createTrackerBloc: (deck) => _track(TrackerBloc(
        deck: deck,
        trackingInteractionUsecase: TrackingInteractionUsecase(),
        calculateUsageCardUsecase: CalculateUsageCardUsecase(),
        summarizeRecordUsecase: const SummarizeRecordUsecase(),
        getCardFromRecordUsecase: GetCardFromRecordUsecase(),
        fetchRecordUsecase: FetchRecordUsecase(recordRepository: records),
        createRecordUsecase: CreateRecordUsecase(recordRepository: records),
        deleteRecordUsecase: DeleteRecordUsecase(recordRepository: records),
        importRecordUsecase: ImportRecordUsecase(recordRepository: records),
        shareRecordUsecase: ShareRecordUsecase(recordRepository: records),
      )),
    );
  }

  Future<void> pump(WidgetTester tester, {required String initialRoute}) async {
    addTearDown(() => tester.runAsync(dispose));
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    dependencies.applicationBloc.add(InitApplicationEvent());
    await tester.pumpWidget(PresentationScope(
      dependencies: dependencies,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: dependencies.nfcBloc),
          BlocProvider.value(value: dependencies.deckBloc),
          BlocProvider.value(value: dependencies.deckBuilderBloc),
          BlocProvider.value(value: dependencies.applicationBloc),
        ],
        child: MaterialApp(
          theme: AppThemes.light,
          locale: const Locale('en'),
          supportedLocales: const [Locale('en')],
          localizationsDelegates: const [
            _PreloadedLocalizationDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: initialRoute,
          onGenerateRoute: RouteGenerator.generateRoute,
          navigatorObservers: [dependencies.routeObserver],
          builder: (context, child) =>
              AppErrorBanner(child: child ?? const SizedBox.shrink()),
        ),
      ),
    ));
    await settle(tester);
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> dispose() async {
    await dependencies.nfcBloc.close();
    await dependencies.deckBloc.close();
    await dependencies.deckBuilderBloc.close();
    await dependencies.applicationBloc.close();
    await dependencies.collectionBloc.close();
  }
}

late final AppLocalization _english;

class _PreloadedLocalizationDelegate
    extends LocalizationsDelegate<AppLocalization> {
  const _PreloadedLocalizationDelegate();
  @override
  bool isSupported(Locale locale) => true;
  @override
  Future<AppLocalization> load(Locale locale) => SynchronousFuture(_english);
  @override
  bool shouldReload(covariant LocalizationsDelegate old) => false;
}

Future<void> initTestConfig() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await ApiConfig.load('development');
  GameConfig.load('development');
  await LanguageManager.initialize();
  _english = AppLocalization(const Locale('en'));
  await _english.load();
}
