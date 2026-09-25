import '../domain/repository/nfc.dart';
import '../domain/usecase/nfc_session.dart';
import '../domain/repository/device.dart';
import '../domain/usecase/device.dart';
import '../domain/repository/session.dart';
import '../domain/usecase/session.dart';
import 'package:flutter/foundation.dart';

import '../domain/repository/index.dart';
import '../.config/app.dart';
import '../util/domain_logger.dart';
import 'package:nfc_deck_tracker/domain/usecase/index.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'locator.dart';

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
    rethrow;
  }
}

void _cardUsecase() {
  locator.registerLazySingleton(() => CreateCardUsecase(
        cardRepository: locator<CardRepository>(),
        collectionRepository: locator<CollectionRepository>(),
        imageRepository: locator<ImageRepository>(),
      ));
  locator.registerLazySingleton(() => DeleteCardUsecase(
        pendingDeletes: locator<PendingDeleteRepository>(),
        cardRepository: locator<CardRepository>(),
        imageRepository: locator<ImageRepository>(),
      ));
  locator.registerLazySingleton(() => FetchCardUsecase(
        repository: locator<CardCatalogRepository>(),
      ));
  locator.registerLazySingleton(() => FetchUsedCardDistinctUsecase(
        cardRepository: locator<CardRepository>(),
      ));
  locator.registerLazySingleton(() => FindCardFromTagUsecase(
        cardRepository: locator<CardRepository>(),
      ));
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
        pendingDeletes: locator<PendingDeleteRepository>(),
        collectionRepository: locator<CollectionRepository>(),
      ));
  locator.registerLazySingleton(() => FetchCollectionUsecase(
        pendingDeletes: locator<PendingDeleteRepository>(),
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
        pendingDeletes: locator<PendingDeleteRepository>(),
        deckRepository: locator<DeckRepository>(),
      ));
  locator.registerLazySingleton(() => FetchCardInDeckUsecase(
        deckRepository: locator<DeckRepository>(),
      ));
  locator.registerLazySingleton(() => FetchDeckUsecase(
        pendingDeletes: locator<PendingDeleteRepository>(),
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
  locator.registerLazySingleton(() => const SummarizeRecordUsecase());
  locator.registerLazySingleton(() => CreateRecordUsecase(
        recordRepository: locator<RecordRepository>(),
      ));
  locator.registerLazySingleton(() => DeleteRecordUsecase(
        pendingDeletes: locator<PendingDeleteRepository>(),
        recordRepository: locator<RecordRepository>(),
      ));
  locator.registerLazySingleton(() => FetchRecordUsecase(
        pendingDeletes: locator<PendingDeleteRepository>(),
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
        settingsRepository: locator<SettingsRepository>(),
      ));
  locator.registerLazySingleton(() => UpdateSettingUsecase(
        settingsRepository: locator<SettingsRepository>(),
      ));
}
