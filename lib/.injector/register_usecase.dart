import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/repository/~index.dart';
import 'package:nfc_deck_tracker/domain/usecase/~index.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'service_locator.dart';

Future<void> registerUsecase() async {
  try {
    _cardUsecase();
    _collectionUsecase();
    _deckUsecase();
    _localUsecase();
    _recordUsecase();
    _settingUsecase();

    LoggerUtil.buffer('✔️ Usecase registered successfully.');
  } catch (e) {
    LoggerUtil.buffer('❌ Failed to register usecase: $e');
  }
}

void _cardUsecase() {
  locator.registerLazySingleton(() => CreateCardUsecase(
    checkCardDuplicateNameRepository: locator<CheckCardDuplicateNameRepository>(),
    createCardRepository: locator<CreateCardRepository>(),
    updateCollectionDateRepository: locator<UpdateCollectionDateRepository>(),
    uploadImageRepository: locator<UploadImageRepository>(),
  ));
  locator.registerLazySingleton(() => DeleteCardUsecase(
    deleteCardRepository: locator<DeleteCardRepository>(),
    deleteImageRepository: locator<DeleteImageRepository>(),
  ));
  locator.registerFactoryParam<FetchCardUsecase, String, void>((collectionId, _) {
    return FetchCardUsecase(
      createCollectionRepository: locator<CreateCollectionRepository>(),
      createPageRepository: locator<CreatePageRepository>(),
      fetchCardRepository: locator<FetchCardRepository>(param1: collectionId),
      findCollectionRepository: locator<FindCollectionRepository>(),
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
    updateImageRepository: locator<UpdateImageRepository>(),
    uploadImageRepository: locator<UploadImageRepository>(),
  ));
}

void _collectionUsecase() {
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

void _deckUsecase() {
  locator.registerLazySingleton(() => CreateDeckUsecase(
    createDeckRepository: locator<CreateDeckRepository>(),
  ));
  locator.registerLazySingleton(() => DeleteDeckUsecase(
    deleteDeckRepository: locator<DeleteDeckRepository>(),
  ));
  locator.registerLazySingleton(() => FetchCardInDeckUsecase(
    fetchCardInDeckRepository: locator<FetchCardInDeckRepository>(),
  ));
  locator.registerLazySingleton(() => FetchDeckUsecase(
    createDeckRepository: locator<CreateDeckRepository>(),
    deleteDeckRepository: locator<DeleteDeckRepository>(),
    fetchDeckRepository: locator<FetchDeckRepository>(),
    updateDeckRepository: locator<UpdateDeckRepository>(),
  ));
  locator.registerLazySingleton(() => GenerateShareDeckClipboardUsecase());
  locator.registerLazySingleton(() => TrackingInteractionUsecase());
  locator.registerLazySingleton(() => UpdateCardInDeckUsecase());
  locator.registerLazySingleton(() => UpdateDeckUsecase(
    updateDeckRepository: locator<UpdateDeckRepository>(),
  ));
}

void _localUsecase() {
  locator.registerLazySingleton(() => ClearUserDataUsecase(
    clearUserDataRepository: locator<ClearUserDataRepository>(),
    deleteImageRepository: locator<DeleteImageRepository>(),
    fetchUsedCardDistinctRepository: locator<FetchUsedCardDistinctRepository>(),
  ));
}

void _recordUsecase() {
  locator.registerLazySingleton(() => CalculateUsageCardUsecase());
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
  locator.registerLazySingleton(() => GetCardFromRecordUsecase());
  locator.registerLazySingleton(() => ImportRecordUsecase(
    importRecordRepository: locator<ImportRecordRepository>(),
  ));
  locator.registerLazySingleton(() => ShareRecordUsecase(
    shareRecordRepository: locator<ShareRecordRepository>(),
  ));
  locator.registerLazySingleton(() => UpdateRecordUsecase(
    updateRecordRepository: locator<UpdateRecordRepository>(),
  ));
}

void _settingUsecase() {
  locator.registerLazySingleton(() => InitSettingUsecase(
    loadSettingRepository: locator<LoadSettingRepository>(),
    updateSettingRepository: locator<UpdateSettingRepository>(),
  ));
  locator.registerLazySingleton(() => UpdateSettingUsecase(
    updateSettingRepository: locator<UpdateSettingRepository>(),
  ));
}
