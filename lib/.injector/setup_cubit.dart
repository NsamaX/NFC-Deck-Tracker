import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/~index.dart';

import 'package:nfc_deck_tracker/presentation/cubit/~index.dart';

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
    setupRoomCubit();
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
    clearLocalDataSourceUsecase: locator<ClearLocalDataSourceUsecase>(),
    initializeSettingUsecase: locator<InitializeSettingUsecase>(),
    updateSettingUsecase: locator<UpdateSettingUsecase>(),
  ));
}

void setupCardCubit() {
  locator.registerFactory(() => CardCubit(
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
  locator.registerFactory(() => PinColorCubit());
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

void setupRoomCubit() {
  locator.registerFactoryParam<RoomCubit, DeckEntity, void>((deck, _) {
    return RoomCubit(
      deck: deck,
      closeRoomUsecase: locator<CloseRoomUsecase>(),
      createRoomUsecase: locator<CreateRoomUsecase>(),
      fetchRoomUsecase: locator<FetchRoomUsecase>(),
      joinRoomUsecase: locator<JoinRoomUsecase>(),
      updateRoomUsecase: locator<UpdateRoomUsecase>(),
    );
  });
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
  locator.registerFactory(() => UsageCardCubit(
    calculateUsageCardStatsUsecase: locator<CalculateUsageCardStatsUsecase>(),
  ));
}
