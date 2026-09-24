import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/index.dart';
import 'package:nfc_deck_tracker/presentation/bloc/index.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'locator.dart';

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
    _trackerBloc();

    LoggerUtil.buffer('Bloc registered successfully.');
  } catch (e) {
    LoggerUtil.buffer('Failed to register bloc: $e');
    rethrow;
  }
}

void _applicationBloc() {
  locator.registerLazySingleton(() => ApplicationBloc(
        clearUserDataUsecase: locator<ClearUserDataUsecase>(),
        initSettingUsecase: locator<InitSettingUsecase>(),
        updateSettingUsecase: locator<UpdateSettingUsecase>(),
        sessionUsecase: locator<SessionUsecase>(),
        deviceUsecase: locator<DeviceUsecase>(),
      ));
}

void _browseCardBloc() {
  locator.registerFactoryParam<BrowseCardBloc, String, void>(
      (collectionId, _) => BrowseCardBloc(
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
        fetchDeckUsecase: locator<FetchDeckUsecase>(),
        deleteDeckUsecase: locator<DeleteDeckUsecase>(),
      ));
  locator.registerLazySingleton(() => DeckBuilderBloc(
        createDeckUsecase: locator<CreateDeckUsecase>(),
        updateDeckUsecase: locator<UpdateDeckUsecase>(),
        fetchCardInDeckUsecase: locator<FetchCardInDeckUsecase>(),
        updateCardInDeckUsecase: locator<UpdateCardInDeckUsecase>(),
        generateShareDeckClipboardUsecase:
            locator<GenerateShareDeckClipboardUsecase>(),
      ));
}

void _drawerBloc() {
  locator.registerFactory(() => DrawerBloc());
}

void _nfcBloc() {
  locator.registerLazySingleton(
      () => NfcBloc(session: locator<NfcSessionUsecase>()));
}

void _pinCardBloc() {
  locator.registerFactory(() => PinCardBloc());
}

void _readerBloc() {
  locator.registerFactoryParam<ReaderBloc, String, void>((collectionId, _) {
    return ReaderBloc(
      findCardFromTagUsecase:
          locator<FindCardFromTagUsecase>(param1: collectionId),
    );
  });
}


void _trackerBloc() {
  locator.registerFactoryParam<TrackerBloc, DeckEntity, void>(
      (deck, _) => TrackerBloc(
            deck: deck,
            trackingInteractionUsecase: locator<TrackingInteractionUsecase>(),
            calculateUsageCardUsecase: locator<CalculateUsageCardUsecase>(),
            summarizeRecordUsecase: locator<SummarizeRecordUsecase>(),
            getCardFromRecordUsecase: locator<GetCardFromRecordUsecase>(),
            fetchRecordUsecase: locator<FetchRecordUsecase>(),
            createRecordUsecase: locator<CreateRecordUsecase>(),
            deleteRecordUsecase: locator<DeleteRecordUsecase>(),
            importRecordUsecase: locator<ImportRecordUsecase>(),
            shareRecordUsecase: locator<ShareRecordUsecase>(),
          ));
}

