import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/datasource/api/@service_factory.dart';
import 'package:nfc_deck_tracker/data/datasource/local/~index.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/@supabase_service.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/~index.dart';
import 'package:nfc_deck_tracker/data/repository/~index.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'service_locator.dart';

Future<void> registerRepository() async {
  try {
    _cardRepository();
    _cloudImageRepository();
    _collectionRepository();
    _deckRepository();
    _localRepository();
    _pageRepository();
    _recordRepository();
    _settingRepository();

    LoggerUtil.buffer('✔️ Repository registered successfully.');
  } catch (e) {
    LoggerUtil.buffer('❌ Failed to register repository: $e');
  }
}

void _cardRepository() {
  locator.registerLazySingleton(() => CheckCardDuplicateNameRepository(
    checkCardDuplicateNameLocalDatasource: locator<CheckCardDuplicateNameLocalDatasource>(),
  ));
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

void _cloudImageRepository() {
  locator.registerLazySingleton(() => DeleteImageRepository(
    supabaseService: locator<SupabaseService>(),
  ));
  locator.registerLazySingleton(() => UpdateImageRepository(
    supabaseService: locator<SupabaseService>(),
  ));
  locator.registerLazySingleton(() => UploadImageRepository(
    supabaseService: locator<SupabaseService>(),
  ));
}

void _collectionRepository() {
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
  locator.registerLazySingleton(() => FindCollectionRepository(
    findCollectionLocalDatasource: locator<FindCollectionLocalDatasource>(),
  ));
  locator.registerLazySingleton(() => UpdateCollectionDateRepository(
    updateCollectionDateLocalDatasource: locator<UpdateCollectionDateLocalDatasource>(),
  ));
  locator.registerLazySingleton(() => UpdateCollectionRepository(
    updateCollectionLocalDatasource: locator<UpdateCollectionLocalDatasource>(),
    updateCollectionRemoteDatasource: locator<UpdateCollectionRemoteDatasource>(),
  ));
}

void _deckRepository() {
  locator.registerLazySingleton(() => CreateDeckRepository(
    createDeckLocalDatasource: locator<CreateDeckLocalDatasource>(),
    createDeckRemoteDatasource: locator<CreateDeckRemoteDatasource>(),
  ));
  locator.registerLazySingleton(() => DeleteDeckRepository(
    deleteDeckLocalDatasource: locator<DeleteDeckLocalDatasource>(),
    deleteDeckRemoteDatasource: locator<DeleteDeckRemoteDatasource>(),
  ));
  locator.registerLazySingleton(() => FetchCardInDeckRepository(
    fetchCardInDeckLocalDatasource: locator<FetchCardInDeckLocalDatasource>(),
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

void _recordRepository() {
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
  locator.registerLazySingleton(() => ImportRecordRepository(
    importRecordRemoteDatasource: locator<ImportRecordRemoteDatasource>(),
  ));
  locator.registerLazySingleton(() => ShareRecordRepository(
    shareRecordRemoteDatasource: locator<ShareRecordRemoteDatasource>(),
  ));
  locator.registerLazySingleton(() => UpdateRecordRepository(
    updateRecordLocalDatasource: locator<UpdateRecordLocalDatasource>(),
    updateRecordRemoteDatasource: locator<UpdateRecordRemoteDatasource>(),
  ));
}

void _pageRepository() {
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

void _localRepository() {
  locator.registerLazySingleton(() => ClearUserDataRepository(
    clearUserDataLocalDatasource: locator<ClearUserDataLocalDatasource>(),
  ));
}

void _settingRepository() {
  locator.registerLazySingleton(() => LoadSettingRepository(
    loadSettingLocalDatasource: locator<LoadSettingLocalDatasource>(),
  ));
  locator.registerLazySingleton(() => UpdateSettingRepository(
    updateSettingLocalDatasource: locator<UpdateSettingLocalDatasource>(),
  ));
}
