import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/~index.dart';
import 'package:nfc_deck_tracker/presentation/bloc/~index.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'service_locator.dart';

Future<void> registerBloc() async {
  try {
    _browseCardBloc();
    _collectionBloc();
    _deckBloc();
    _drawerBloc();
    _pinCardBloc();
    _roomBloc();
    _searchCardBloc();
    _usageCardBloc();

    LoggerUtil.debugMessage('✔️ Bloc registered successfully.');
  } catch (e) {
    LoggerUtil.debugMessage('❌ Failed to register bloc: $e');
  }
}

void _browseCardBloc() {
  locator.registerFactoryParam<BrowseCardBloc, String, void>((collectionId, _) => BrowseCardBloc(
    fetchCardUsecase: locator<FetchCardUsecase>(param1: collectionId),
  ));
}

void _collectionBloc() {
  locator.registerLazySingleton(() => CollectionBloc(
    createCollectionUsecase: locator<CreateCollectionUsecase>(),
    deleteCollectionUsecase: locator<DeleteCollectionUsecase>(),
    fetchCollectionUsecase: locator<FetchCollectionUsecase>(),
    fetchUsedCardDistinctUsecase: locator<FetchUsedCardDistinctUsecase>(),
  ));
}

void _deckBloc() {
  locator.registerLazySingleton(() => DeckBloc(
    createDeckUsecase: locator<CreateDeckUsecase>(),
    deleteDeckUsecase: locator<DeleteDeckUsecase>(),
    fetchCardInDeckUsecase: locator<FetchCardInDeckUsecase>(),
    fetchDeckUsecase: locator<FetchDeckUsecase>(),
    generateShareDeckClipboardUsecase: locator<GenerateShareDeckClipboardUsecase>(),
    updateCardInDeckUsecase: locator<UpdateCardInDeckUsecase>(),
    updateDeckUsecase: locator<UpdateDeckUsecase>(),
  ));
}

void _drawerBloc() {
  locator.registerFactory(() => DrawerBloc());
}

void _pinCardBloc() {
  locator.registerFactory(() => PinCardBloc());
}

void _roomBloc() {
  locator.registerFactoryParam<RoomBloc, DeckEntity, void>((deck, _) {
    return RoomBloc(
      deck: deck,
      closeRoomUsecase: locator<CloseRoomUsecase>(),
      createRoomUsecase: locator<CreateRoomUsecase>(),
      fetchRoomUsecase: locator<FetchRoomUsecase>(),
      joinRoomUsecase: locator<JoinRoomUsecase>(),
      updateRoomUsecase: locator<UpdateRoomUsecase>(),
    );
  });
}

void _trackerBloc() {
  locator.registerFactoryParam<TrackerCubit, DeckEntity, void>((deck, _) => TrackerBloc(
    deck: deck,
    trackCardInteractionUsecase: locator<TrackCardInteractionUsecase>(),
  ));
}

void _usageCardBloc() {
  locator.registerFactory(() => UsageCardBloc(
    calculateUsageCardStatsUsecase: locator<CalculateUsageCardStatsUsecase>(),
  ));
}
