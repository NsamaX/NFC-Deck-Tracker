import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/datasource/api/_service_factory.dart';
import 'package:nfc_deck_tracker/data/datasource/local/_index.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/_index.dart';
import 'package:nfc_deck_tracker/data/repository/_index.dart';

import 'setup_locator.dart';

Future<void> setupRepository() async {
  try {
    setupCardRepository();
    setupCollectionRepository();
    setupDeckRepository();
    setupLocalRepository();
    setupPageRepository();
    setupRecordRepository();
    setupRoomRepository();
    setupSettingRepository();
    setupUploadImageRepository();

    debugPrint('✔️ Repository registered successfully.');
  } catch (e) {
    debugPrint('❌ Failed to register Repository: $e');
  }
}

// ----------------- Card -----------------

void setupCardRepository() {
  locator.registerLazySingleton(() => CreateCardRepository(
    createCardLocalDatasource: locator<CreateCardLocalDatasource>(),
    createCardRemoteDatasource: locator<CreateCardRemoteDatasource>(),
  ));
  locator.registerLazySingleton(() => DeleteCardRepository(
    deleteCardLocalDatasource: locator<DeleteCardLocalDatasource>(),
    deleteCardRemoteDatasource: locator<DeleteCardRemoteDatasource>(),
  ));
  locator.registerFactoryParam<FetchCardRepository, String, void>((collectionId, _) {
    return FetchCardRepository(
      gameApi: locator<GameApi>(param1: collectionId),
      fetchCardLocalDatasource: locator<FetchCardLocalDatasource>(),
      fetchCardRemoteDatasource: locator<FetchCardRemoteDatasource>(),
    );
  });
  locator.registerLazySingleton(() => FetchUsedCardDistinctRepository(
    fetchUsedCardDistinctLocalDatasource: locator<FetchUsedCardDistinctLocalDatasource>(),
  ));
  locator.registerFactoryParam<FindCardRepository, String, void>((collectionId, _) {
    return FindCardRepository(
      findCardLocalDatasource: locator<FindCardLocalDatasource>(),
      gameApi: locator<GameApi>(param1: collectionId),
    );
  });
  locator.registerLazySingleton(() => SaveCardRepository(
    saveCardLocalDatasource: locator<SaveCardLocalDatasource>(),
  ));
  locator.registerLazySingleton(() => UpdateCardRepository(
    updateCardLocalDatasource: locator<UpdateCardLocalDatasource>(),
    updateCardRemoteDatasource: locator<UpdateCardRemoteDatasource>(),
  ));
}

// ----------------- Collection -----------------

void setupCollectionRepository() {
  locator.registerLazySingleton(() => CreateCollectionRepository(
    createCollectionLocalDatasource: locator<CreateCollectionLocalDatasource>(),
    createCollectionRemoteDatasource: locator<CreateCollectionRemoteDatasource>(),
  ));
  locator.registerLazySingleton(() => DeleteCollectionRepository(
    deleteCollectionLocalDatasource: locator<DeleteCollectionLocalDatasource>(),
    deleteCollectionRemoteDatasource: locator<DeleteCollectionRemoteDatasource>(),
  ));
  locator.registerLazySingleton(() => FetchCollectionRepository(
    fetchCollectionLocalDatasource: locator<FetchCollectionLocalDatasource>(),
    fetchCollectionRemoteDatasource: locator<FetchCollectionRemoteDatasource>(),
  ));
  locator.registerLazySingleton(() => UpdateCollectionRepository(
    updateCollectionLocalDatasource: locator<UpdateCollectionLocalDatasource>(),
    updateCollectionRemoteDatasource: locator<UpdateCollectionRemoteDatasource>(),
  ));
}

// ----------------- Deck -----------------

void setupDeckRepository() {
  locator.registerLazySingleton(() => CreateDeckRepository(
    createDeckLocalDatasource: locator<CreateDeckLocalDatasource>(),
    createDeckRemoteDatasource: locator<CreateDeckRemoteDatasource>(),
  ));
  locator.registerLazySingleton(() => DeleteDeckRepository(
    deleteDeckLocalDatasource: locator<DeleteDeckLocalDatasource>(),
    deleteDeckRemoteDatasource: locator<DeleteDeckRemoteDatasource>(),
  ));
  locator.registerLazySingleton(() => FetchDeckRepository(
    fetchDeckLocalDatasource: locator<FetchDeckLocalDatasource>(),
    fetchDeckRemoteDatasource: locator<FetchDeckRemoteDatasource>(),
  ));
  locator.registerLazySingleton(() => UpdateDeckRepository(
    updateDeckLocalDatasource: locator<UpdateDeckLocalDatasource>(),
    updateDeckRemoteDatasource: locator<UpdateDeckRemoteDatasource>(),
  ));
}

// ----------------- Room -----------------

void setupRoomRepository() {
  locator.registerLazySingleton(() => CloseRoomRepository(
    closeRoomRemoteDatasource: locator<CloseRoomRemoteDatasource>(),
  ));
  locator.registerLazySingleton(() => CreateRoomRepository(
    createRoomRemoteDatasource: locator<CreateRoomRemoteDatasource>(),
  ));
  locator.registerLazySingleton(() => FetchRoomRepository(
    fetchRoomRemoteDatasource: locator<FetchRoomRemoteDatasource>(),
  ));
  locator.registerLazySingleton(() => JoinRoomRepository(
    joinRoomRemoteDatasource: locator<JoinRoomRemoteDatasource>(),
  ));
  locator.registerLazySingleton(() => UpdateRoomRepository(
    updateRoomRemoteDatasource: locator<UpdateRoomRemoteDatasource>(),
  ));
}

// ----------------- Record -----------------

void setupRecordRepository() {
  locator.registerLazySingleton(() => CreateRecordRepository(
    createRecordLocalDatasource: locator<CreateRecordLocalDatasource>(),
    createRecordRemoteDatasource: locator<CreateRecordRemoteDatasource>(),
  ));
  locator.registerLazySingleton(() => DeleteRecordRepository(
    deleteRecordLocalDatasource: locator<DeleteRecordLocalDatasource>(),
    deleteRecordRemoteDatasource: locator<DeleteRecordRemoteDatasource>(),
  ));
  locator.registerLazySingleton(() => FetchRecordRepository(
    fetchRecordLocalDatasource: locator<FetchRecordLocalDatasource>(),
    fetchRecordRemoteDatasource: locator<FetchRecordRemoteDatasource>(),
  ));
  locator.registerLazySingleton(() => UpdateRecordRepository(
    updateRecordLocalDatasource: locator<UpdateRecordLocalDatasource>(),
    updateRecordRemoteDatasource: locator<UpdateRecordRemoteDatasource>(),
  ));
}

// ----------------- Page -----------------

void setupPageRepository() {
  locator.registerLazySingleton(() => CreatePageRepository(
    createPageLocalDatasource: locator<CreatePageLocalDatasource>(),
  ));
  locator.registerLazySingleton(() => FindPageRepository(
    findPageLocalDatasource: locator<FindPageLocalDatasource>(),
  ));
  locator.registerLazySingleton(() => UpdatePageRepository(
    updatePageLocalDatasource: locator<UpdatePageLocalDatasource>(),
  ));
}

// ----------------- Local Clear -----------------

void setupLocalRepository() {
  locator.registerLazySingleton(() => ClearLocalDataSourceRepository(
    clearLocalDatasource: locator<ClearLocalDatasource>(),
  ));
}

// ----------------- Setting -----------------

void setupSettingRepository() {
  locator.registerLazySingleton(() => LoadSettingRepository(
    loadSettingLocalDatasource: locator<LoadSettingLocalDatasource>(),
  ));
  locator.registerLazySingleton(() => SaveSettingRepository(
    saveSettingLocalDatasource: locator<SaveSettingLocalDatasource>(),
  ));
}

// ----------------- Upload Image -----------------

void setupUploadImageRepository() {
  locator.registerLazySingleton(() => UploadImageRepository(
    uploadImageRemoteDatasource: locator<UploadImageRemoteDatasource>(),
  ));
}
