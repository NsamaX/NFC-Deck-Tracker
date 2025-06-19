import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/~index.dart';
import 'package:nfc_deck_tracker/presentation/cubit/~index.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'service_locator.dart';

Future<void> registerCubit() async {
  try {
    _applicationCubit();
    _cardCubit();
    _collectionCubit();
    _deckCubit();
    _drawerCubit();
    _nfcCubit();
    _pinColorCubit();
    _readerCubit();
    _recordCubit();
    _roomCubit();
    _searchCubit();
    _trackerCubit();
    _usageCardCubit();

    LoggerUtil.debugMessage('✔️ Cubit registered successfully.');
  } catch (e) {
    LoggerUtil.debugMessage('❌ Failed to register Cubit: $e');
  }
}

void _applicationCubit() {
  locator.registerLazySingleton(() => ApplicationCubit(
    clearUserDataUsecase: locator<ClearUserDataUsecase>(),
    initializeSettingUsecase: locator<InitializeSettingUsecase>(),
    updateSettingUsecase: locator<UpdateSettingUsecase>(),
  ));
}

void _cardCubit() {
  locator.registerFactory(() => CardCubit(
    createCardUsecase: locator<CreateCardUsecase>(),
    deleteCardUsecase: locator<DeleteCardUsecase>(),
    updateCardUsecase: locator<UpdateCardUsecase>(),
  ));
}

void _collectionCubit() {
  locator.registerLazySingleton(() => CollectionCubit(
    createCollectionUsecase: locator<CreateCollectionUsecase>(),
    deleteCollectionUsecase: locator<DeleteCollectionUsecase>(),
    fetchCollectionUsecase: locator<FetchCollectionUsecase>(),
    fetchUsedCardDistinctUsecase: locator<FetchUsedCardDistinctUsecase>(),
  ));
}

void _deckCubit() {
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

void _drawerCubit() {
  locator.registerFactory(() => DrawerCubit());
}

void _nfcCubit() {
  locator.registerLazySingleton(() => NfcCubit());
}

void _pinColorCubit() {
  locator.registerFactory(() => PinColorCubit());
}

void _readerCubit() {
  locator.registerFactoryParam<ReaderCubit, String, void>((collectionId, _) {
    return ReaderCubit(
      findCardFromTagUsecase: locator<FindCardFromTagUsecase>(param1: collectionId),
    );
  });
}

void _recordCubit() {
  locator.registerFactoryParam<RecordCubit, String, void>((deckId, _) => RecordCubit(
    deckId: deckId,
    createRecordUsecase: locator<CreateRecordUsecase>(),
    deleteRecordUsecase: locator<DeleteRecordUsecase>(),
    fetchRecordUsecase: locator<FetchRecordUsecase>(),
    updateRecordUsecase: locator<UpdateRecordUsecase>(),
  ));
}

void _roomCubit() {
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

void _searchCubit() {
  locator.registerFactoryParam<SearchCubit, String, void>((collectionId, _) => SearchCubit(
    fetchCardUsecase: locator<FetchCardUsecase>(param1: collectionId),
  ));
}

void _trackerCubit() {
  locator.registerFactoryParam<TrackerCubit, DeckEntity, void>((deck, _) => TrackerCubit(
    deck: deck,
    trackCardInteractionUsecase: locator<TrackCardInteractionUsecase>(),
  ));
}

void _usageCardCubit() {
  locator.registerFactory(() => UsageCardCubit(
    calculateUsageCardStatsUsecase: locator<CalculateUsageCardStatsUsecase>(),
  ));
}
