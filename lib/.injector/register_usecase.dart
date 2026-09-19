import '../domain/repository/nfc.dart';
import '../domain/usecase/nfc_session.dart';
import '../domain/repository/device.dart';
import '../domain/usecase/device.dart';
import '../domain/repository/session.dart';
import '../domain/usecase/session.dart';
import 'package:flutter/foundation.dart';

import '../domain/repository/~index.dart';
import '../.config/app.dart';
import '../util/domain_logger.dart';
import 'package:nfc_deck_tracker/domain/usecase/~index.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'service_locator.dart';

Future<void> registerUsecase() async {
  try {
    locator.registerLazySingleton(
        () => NfcSessionUsecase(locator<NfcRepository>()));
    locator.registerLazySingleton(
        () => DeviceUsecase(locator<DeviceRepository>()));
    locator.registerLazySingleton(
        () => SessionUsecase(locator<SessionRepository>()));
    _cardUsecase();
    _collectionUsecase();
    _deckUsecase();
    _localUsecase();
    _recordUsecase();
    _settingUsecase();

    LoggerUtil.buffer('Usecase registered successfully.');
  } catch (e) {
    LoggerUtil.buffer('Failed to register usecase: $e');
  }
}

void _cardUsecase() {
  locator.registerLazySingleton(() => CreateCardUsecase(
        cardRepository: locator<CardRepository>(),
        collectionRepository: locator<CollectionRepository>(),
        imageRepository: locator<ImageRepository>(),
      ));
  locator.registerLazySingleton(() => DeleteCardUsecase(
        cardRepository: locator<CardRepository>(),
        imageRepository: locator<ImageRepository>(),
      ));
  locator
      .registerFactoryParam<FetchCardUsecase, String, void>((collectionId, _) {
    return FetchCardUsecase(
      repository: locator<CardCatalogRepository>(param1: collectionId),
    );
  });
  locator.registerLazySingleton(() => FetchUsedCardDistinctUsecase(
        cardRepository: locator<CardRepository>(),
      ));
  locator.registerFactoryParam<FindCardFromTagUsecase, String, void>(
      (collectionId, _) {
    return FindCardFromTagUsecase(
      cardRepository: locator<CardRepository>(),
    );
  });
  locator.registerLazySingleton(() => UpdateCardUsecase(
        cardRepository: locator<CardRepository>(),
        imageRepository: locator<ImageRepository>(),
      ));
}

void _collectionUsecase() {
  locator.registerLazySingleton(() => CreateCollectionUsecase(
        collectionRepository: locator<CollectionRepository>(),
      ));
  locator.registerLazySingleton(() => DeleteCollectionUsecase(
        collectionRepository: locator<CollectionRepository>(),
      ));
  locator.registerLazySingleton(() => FetchCollectionUsecase(
        logger: const AppDomainLogger(),
        collectionRepository: locator<CollectionRepository>(),
      ));
  locator.registerLazySingleton(() => UpdateCollectionUsecase(
        collectionRepository: locator<CollectionRepository>(),
      ));
}

void _deckUsecase() {
  locator.registerLazySingleton(() => CreateDeckUsecase(
        deckRepository: locator<DeckRepository>(),
      ));
  locator.registerLazySingleton(() => DeleteDeckUsecase(
        deckRepository: locator<DeckRepository>(),
      ));
  locator.registerLazySingleton(() => FetchCardInDeckUsecase(
        deckRepository: locator<DeckRepository>(),
      ));
  locator.registerLazySingleton(() => FetchDeckUsecase(
        logger: const AppDomainLogger(),
        deckRepository: locator<DeckRepository>(),
      ));
  locator.registerLazySingleton(() => GenerateShareDeckClipboardUsecase());
  locator.registerLazySingleton(() => TrackingInteractionUsecase());
  locator.registerLazySingleton(() => UpdateCardInDeckUsecase());
  locator.registerLazySingleton(() => UpdateDeckUsecase(
        deckRepository: locator<DeckRepository>(),
      ));
}

void _localUsecase() {
  locator.registerLazySingleton(() => ClearUserDataUsecase(
        localDataRepository: locator<LocalDataRepository>(),
        imageRepository: locator<ImageRepository>(),
        cardRepository: locator<CardRepository>(),
      ));
}

void _recordUsecase() {
  locator.registerLazySingleton(() => CalculateUsageCardUsecase());
  locator.registerLazySingleton(() => CreateRecordUsecase(
        recordRepository: locator<RecordRepository>(),
      ));
  locator.registerLazySingleton(() => DeleteRecordUsecase(
        recordRepository: locator<RecordRepository>(),
      ));
  locator.registerLazySingleton(() => FetchRecordUsecase(
        logger: const AppDomainLogger(),
        recordRepository: locator<RecordRepository>(),
      ));
  locator.registerLazySingleton(() => GetCardFromRecordUsecase());
  locator.registerLazySingleton(() => ImportRecordUsecase(
        recordRepository: locator<RecordRepository>(),
      ));
  locator.registerLazySingleton(() => ShareRecordUsecase(
        recordRepository: locator<RecordRepository>(),
      ));
  locator.registerLazySingleton(() => UpdateRecordUsecase(
        recordRepository: locator<RecordRepository>(),
      ));
}

void _settingUsecase() {
  locator.registerLazySingleton(() => InitSettingUsecase(
        ignoreDefaultWriteKeys: AppConfig.ignoreDefaultWriteKeys,
        logger: const AppDomainLogger(),
        settingsRepository: locator<SettingsRepository>(),
      ));
  locator.registerLazySingleton(() => UpdateSettingUsecase(
        settingsRepository: locator<SettingsRepository>(),
      ));
}
