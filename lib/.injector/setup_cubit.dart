import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/_index.dart';

import 'package:nfc_deck_tracker/presentation/cubit/_index.dart';

import 'setup_locator.dart';

Future<void> setupCubit() async {
  try {
    setupApplicationCubit();
    setupCardCubit();
    setupCollectionCubit();
    setupDeckCubit();
    setupDrawerCubit();
    setupNfcCubit();
    setupPinColorCubit();
    setupReaderCubit();
    setupRecordCubit();
    setupSearchCubit();
    setupTrackerCubit();
    setupUsageCardCubit();

    debugPrint('✔️ Cubit registered successfully.');
  } catch (e) {
    debugPrint('❌ Failed to register Cubit: $e');
  }
}

void setupApplicationCubit() {
  locator.registerLazySingleton(() => ApplicationCubit(
    initializeSettingUsecase: locator<InitializeSettingUsecase>(),
    updateSettingUsecase: locator<UpdateSettingUsecase>(),
  ));
}

void setupCardCubit() {
  locator.registerLazySingleton(() => CardCubit(
    createCardUsecase: locator<CreateCardUsecase>(),
    deleteCardUsecase: locator<DeleteCardUsecase>(),
    updateCardUsecase: locator<UpdateCardUsecase>(),
  ));
}

void setupCollectionCubit() {
  locator.registerLazySingleton(() => CollectionCubit(
    createCollectionUsecase: locator<CreateCollectionUsecase>(),
    deleteCollectionUsecase: locator<DeleteCollectionUsecase>(),
    fetchCollectionUsecase: locator<FetchCollectionUsecase>(),
    fetchUsedCardDistinctUsecase: locator<FetchUsedCardDistinctUsecase>(),
  ));
}

void setupDeckCubit() {
  locator.registerLazySingleton(() => DeckCubit(
    createDeckUsecase: locator<CreateDeckUsecase>(),
    deleteDeckUsecase: locator<DeleteDeckUsecase>(),
    fetchDeckUsecase: locator<FetchDeckUsecase>(),
    filterDeckCardsUsecase: locator<FilterDeckCardsUsecase>(),
    generateShareDeckClipboardUsecase: locator<GenerateShareDeckClipboardUsecase>(),
    updateDeckCardCountUsecase: locator<UpdateDeckCardCountUsecase>(),
    updateDeckUsecase: locator<UpdateDeckUsecase>(),
  ));
}

void setupDrawerCubit() {
  locator.registerFactory(() => DrawerCubit());
}

void setupNfcCubit() {
  locator.registerLazySingleton(() => NfcCubit());
}

void setupPinColorCubit() {
  locator.registerLazySingleton(() => PinColorCubit());
}

void setupReaderCubit() {
  locator.registerFactoryParam<ReaderCubit, String, void>((collectionId, _) {
    return ReaderCubit(
      findCardFromTagUsecase: locator<FindCardFromTagUsecase>(param1: collectionId),
    );
  });
}

void setupRecordCubit() {
  locator.registerFactoryParam<RecordCubit, String, void>((deckId, _) => RecordCubit(
    deckId: deckId,
    createRecordUsecase: locator<CreateRecordUsecase>(),
    deleteRecordUsecase: locator<DeleteRecordUsecase>(),
    fetchRecordUsecase: locator<FetchRecordUsecase>(),
    updateRecordUsecase: locator<UpdateRecordUsecase>(),
  ));
}

void setupSearchCubit() {
  locator.registerFactoryParam<SearchCubit, String, void>((collectionId, _) => SearchCubit(
    fetchCardUsecase: locator<FetchCardUsecase>(param1: collectionId),
  ));
}

void setupTrackerCubit() {
  locator.registerFactoryParam<TrackerCubit, DeckEntity, void>((deck, _) => TrackerCubit(
    deck: deck,
    trackCardInteractionUsecase: locator<TrackCardInteractionUsecase>(),
  ));
}

void setupUsageCardCubit() {
  locator.registerLazySingleton(() => UsageCardCubit(
    calculateUsageCardStatsUsecase: locator<CalculateUsageCardStatsUsecase>(),
  ));
}
