import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/repository/_index.dart';

import 'package:nfc_deck_tracker/domain/usecase/_index.dart';

import 'setup_locator.dart';

Future<void> setupUsecase() async {
  try {
    setupCardUsecase();
    setupCollectionUsecase();
    setupDeckUsecase();
    setupLocalUsecase();
    setupRecordUsecase();
    setupRoomUsecase();
    setupSettingUsecase();

    debugPrint('✔️ Usecase registered successfully.');
  } catch (e) {
    debugPrint('❌ Failed to register UseCase: $e');
  }
}

// ----------------- Card -----------------

void setupCardUsecase() {
  locator.registerLazySingleton(() => CreateCardUsecase(
    createCardRepository: locator<CreateCardRepository>(),
    uploadImageRepository: locator<UploadImageRepository>(),
  ));
  locator.registerLazySingleton(() => DeleteCardUsecase(
    deleteCardRepository: locator<DeleteCardRepository>(),
  ));
  locator.registerFactoryParam<FetchCardUsecase, String, void>((collectionId, _) {
    return FetchCardUsecase(
      createCollectionRepository: locator<CreateCollectionRepository>(),
      createPageRepository: locator<CreatePageRepository>(),
      fetchCardRepository: locator<FetchCardRepository>(param1: collectionId),
      findPageRepository: locator<FindPageRepository>(),
      saveCardRepository: locator<SaveCardRepository>(),
      updatePageRepository: locator<UpdatePageRepository>(),
    );
  });
  locator.registerLazySingleton(() => FetchUsedCardDistinctUsecase(
    fetchUsedCardDistinctRepository: locator<FetchUsedCardDistinctRepository>(),
  ));
  locator.registerFactoryParam<FindCardFromTagUsecase, String, void>((collectionId, _) {
    return FindCardFromTagUsecase(
      findCardRepository: locator<FindCardRepository>(param1: collectionId),
    );
  });
  locator.registerLazySingleton(() => UpdateCardUsecase(
    updateCardRepository: locator<UpdateCardRepository>(),
    uploadImageRepository: locator<UploadImageRepository>(),
  ));
}

// ----------------- Collection -----------------

void setupCollectionUsecase() {
  locator.registerLazySingleton(() => CreateCollectionUsecase(
    createCollectionRepository: locator<CreateCollectionRepository>(),
  ));
  locator.registerLazySingleton(() => DeleteCollectionUsecase(
    deleteCollectionRepository: locator<DeleteCollectionRepository>(),
  ));
  locator.registerLazySingleton(() => FetchCollectionUsecase(
    createCollectionRepository: locator<CreateCollectionRepository>(),
    deleteCollectionRepository: locator<DeleteCollectionRepository>(),
    fetchCollectionRepository: locator<FetchCollectionRepository>(),
    updateCollectionRepository: locator<UpdateCollectionRepository>(),
  ));
  locator.registerLazySingleton(() => UpdateCollectionUsecase(
    updateCollectionRepository: locator<UpdateCollectionRepository>(),
  ));
}

// ----------------- Deck -----------------

void setupDeckUsecase() {
  locator.registerLazySingleton(() => CreateDeckUsecase(
    createDeckRepository: locator<CreateDeckRepository>(),
  ));
  locator.registerLazySingleton(() => DeleteDeckUsecase(
    deleteDeckRepository: locator<DeleteDeckRepository>(),
  ));
  locator.registerLazySingleton(() => FetchDeckUsecase(
    createDeckRepository: locator<CreateDeckRepository>(),
    deleteDeckRepository: locator<DeleteDeckRepository>(),
    fetchDeckRepository: locator<FetchDeckRepository>(),
    updateDeckRepository: locator<UpdateDeckRepository>(),
  ));
  locator.registerLazySingleton(() => FilterDeckCardsUsecase());
  locator.registerLazySingleton(() => GenerateShareDeckClipboardUsecase());
  locator.registerLazySingleton(() => TrackCardInteractionUsecase());
  locator.registerLazySingleton(() => UpdateDeckCardCountUsecase());
  locator.registerLazySingleton(() => UpdateDeckUsecase(
    updateDeckRepository: locator<UpdateDeckRepository>(),
  ));
}

// ----------------- Local Clear -----------------

void setupLocalUsecase() {
  locator.registerLazySingleton(() => ClearLocalDataSourceUsecase(
    clearLocalDataSourceRepository: locator<ClearLocalDataSourceRepository>(),
  ));
}

// ----------------- Record -----------------

void setupRecordUsecase() {
  locator.registerLazySingleton(() => CalculateUsageCardStatsUsecase());
  locator.registerLazySingleton(() => CreateRecordUsecase(
    createRecordRepository: locator<CreateRecordRepository>(),
  ));
  locator.registerLazySingleton(() => DeleteRecordUsecase(
    deleteRecordRepository: locator<DeleteRecordRepository>(),
  ));
  locator.registerLazySingleton(() => FetchRecordUsecase(
    createRecordRepository: locator<CreateRecordRepository>(),
    deleteRecordRepository: locator<DeleteRecordRepository>(),
    fetchRecordRepository: locator<FetchRecordRepository>(),
    updateRecordRepository: locator<UpdateRecordRepository>(),
  ));
  locator.registerLazySingleton(() => UpdateRecordUsecase(
    updateRecordRepository: locator<UpdateRecordRepository>(),
  ));
}

// ----------------- Room -----------------

void setupRoomUsecase() {
  locator.registerLazySingleton(() => CloseRoomUsecase(
    closeRoomRepository: locator<CloseRoomRepository>(),
  ));
  locator.registerLazySingleton(() => CreateRoomUsecase(
    createRoomRepository: locator<CreateRoomRepository>(),
  ));
  locator.registerLazySingleton(() => JoinRoomUsecase(
    joinRoomRepository: locator<JoinRoomRepository>(),
  ));
  locator.registerLazySingleton(() => FetchRoomUsecase(
    fetchRoomRepository: locator<FetchRoomRepository>(),
  ));
  locator.registerLazySingleton(() => UpdateRoomUsecase(
    updateRoomRepository: locator<UpdateRoomRepository>(),
  ));
}

// ----------------- Setting -----------------

void setupSettingUsecase() {
  locator.registerLazySingleton(() => InitializeSettingUsecase(
    loadSettingRepository: locator<LoadSettingRepository>(),
    saveSettingRepository: locator<SaveSettingRepository>(),
  ));
  locator.registerLazySingleton(() => UpdateSettingUsecase(
    saveSettingRepository: locator<SaveSettingRepository>(),
  ));
}
