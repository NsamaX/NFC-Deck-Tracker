import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/~index.dart';
import 'package:nfc_deck_tracker/presentation/bloc/~index.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'service_locator.dart';

Future<void> registerBloc() async {
  try {
    _applicationBloc();
    _browseCardBloc();
    _cardBloc();
    _collectionBloc();
    _deckBloc();
    _drawerBloc();
    _nfcBloc();
    _pinCardBloc();
    _readerBloc();
    _recordBloc();
    _trackerBloc();
    _usageCardBloc();

    LoggerUtil.buffer('✔️ Bloc registered successfully.');
  } catch (e) {
    LoggerUtil.buffer('❌ Failed to register bloc: $e');
  }
}

void _applicationBloc() {
  locator.registerLazySingleton(() => ApplicationBloc(
    clearUserDataUsecase: locator<ClearUserDataUsecase>(),
    initSettingUsecase: locator<InitSettingUsecase>(),
    updateSettingUsecase: locator<UpdateSettingUsecase>(),
  ));
}

void _browseCardBloc() {
  locator.registerFactoryParam<BrowseCardBloc, String, void>((collectionId, _) => BrowseCardBloc(
    deleteCardUsecase: locator<DeleteCardUsecase>(),
    fetchCardUsecase: locator<FetchCardUsecase>(param1: collectionId),
  ));
}

void _cardBloc() {
  locator.registerFactory(() => CardBloc(
    createCardUsecase: locator<CreateCardUsecase>(),
    updateCardUsecase: locator<UpdateCardUsecase>(),
  ));
}

void _collectionBloc() {
  locator.registerLazySingleton(() => CollectionBloc(
    createCollectionUsecase: locator<CreateCollectionUsecase>(),
    deleteCollectionUsecase: locator<DeleteCollectionUsecase>(),
    fetchCollectionUsecase: locator<FetchCollectionUsecase>(),
    fetchDeckUsecase: locator<FetchDeckUsecase>(),
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

void _nfcBloc() {
  locator.registerLazySingleton(() => NfcBloc());
}

void _pinCardBloc() {
  locator.registerFactory(() => PinCardBloc());
}

void _readerBloc() {
  locator.registerFactoryParam<ReaderBloc, String, void>((collectionId, _) {
    return ReaderBloc(
      findCardFromTagUsecase: locator<FindCardFromTagUsecase>(param1: collectionId),
    );
  });
}

void _recordBloc() {
  locator.registerFactoryParam<RecordBloc, String, void>((deckId, _) => RecordBloc(
    deckId: deckId,
    createRecordUsecase: locator<CreateRecordUsecase>(),
    deleteRecordUsecase: locator<DeleteRecordUsecase>(),
    fetchRecordUsecase: locator<FetchRecordUsecase>(),
    getCardFromRecordUsecase: locator<GetCardFromRecordUsecase>(),
    importRecordUsecase: locator<ImportRecordUsecase>(),
    shareRecordUsecase: locator<ShareRecordUsecase>(),
    updateRecordUsecase: locator<UpdateRecordUsecase>(),
  ));
}

void _trackerBloc() {
  locator.registerFactoryParam<TrackerBloc, DeckEntity, void>((deck, _) => TrackerBloc(
    deck: deck,
    trackingInteractionUsecase: locator<TrackingInteractionUsecase>(),
  ));
}

void _usageCardBloc() {
  locator.registerFactory(() => UsageCardBloc(
    calculateUsageCardUsecase: locator<CalculateUsageCardUsecase>(),
  ));
}
