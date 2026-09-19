import '../domain/repository/nfc.dart';
import '../data/repository/nfc.dart';
import '../domain/repository/device.dart';
import '../data/repository/device.dart';
import '../domain/repository/session.dart';
import '../data/repository/session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../.config/runtime.dart';
import 'package:nfc_deck_tracker/data/datasource/api/@service_factory.dart';
import 'package:nfc_deck_tracker/data/datasource/local/~index.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/~index.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/@supabase_service.dart';
import 'service_locator.dart';
import '../data/repository/card.dart';
import '../domain/repository/card.dart';
import '../data/repository/collection.dart';
import '../domain/repository/collection.dart';
import '../data/repository/deck.dart';
import '../domain/repository/deck.dart';
import '../data/repository/record.dart';
import '../domain/repository/record.dart';
import '../data/repository/image.dart';
import '../domain/repository/image.dart';
import '../data/repository/settings.dart';
import '../domain/repository/settings.dart';
import '../data/repository/local_data.dart';
import '../domain/repository/local_data.dart';
import '../data/repository/card_catalog.dart';
import '../domain/repository/card_catalog.dart';

Future<void> registerRepository() async {
  locator.registerLazySingleton<SessionRepository>(() => RuntimeConfig.guestMode
      ? GuestSessionRepository()
      : FirebaseSessionRepository(
          auth: locator<FirebaseAuth>(), googleSignIn: GoogleSignIn()));
  locator.registerLazySingleton<DeviceRepository>(() => DeviceRepositoryImpl());
  locator.registerLazySingleton<NfcRepository>(() => NfcRepositoryImpl());
  locator.registerLazySingleton<CardRepository>(() => CardRepositoryImpl(
        checkCardDuplicateNameLocalDatasource:
            locator<CheckCardDuplicateNameLocalDatasource>(),
        createCardLocalDatasource: locator<CreateCardLocalDatasource>(),
        createCardRemoteDatasource: locator<CreateCardRemoteDatasource>(),
        deleteCardLocalDatasource: locator<DeleteCardLocalDatasource>(),
        deleteCardRemoteDatasource: locator<DeleteCardRemoteDatasource>(),
        fetchCardLocalDatasource: locator<FetchCardLocalDatasource>(),
        fetchCardRemoteDatasource: locator<FetchCardRemoteDatasource>(),
        fetchUsedCardDistinctLocalDatasource:
            locator<FetchUsedCardDistinctLocalDatasource>(),
        findCardLocalDatasource: locator<FindCardLocalDatasource>(),
        saveCardLocalDatasource: locator<SaveCardLocalDatasource>(),
        updateCardLocalDatasource: locator<UpdateCardLocalDatasource>(),
        updateCardRemoteDatasource: locator<UpdateCardRemoteDatasource>(),
      ));
  locator.registerLazySingleton<CollectionRepository>(() =>
      CollectionRepositoryImpl(
        createCollectionLocalDatasource:
            locator<CreateCollectionLocalDatasource>(),
        createCollectionRemoteDatasource:
            locator<CreateCollectionRemoteDatasource>(),
        deleteCollectionLocalDatasource:
            locator<DeleteCollectionLocalDatasource>(),
        deleteCollectionRemoteDatasource:
            locator<DeleteCollectionRemoteDatasource>(),
        fetchCollectionLocalDatasource:
            locator<FetchCollectionLocalDatasource>(),
        fetchCollectionRemoteDatasource:
            locator<FetchCollectionRemoteDatasource>(),
        findCollectionLocalDatasource: locator<FindCollectionLocalDatasource>(),
        updateCollectionDateLocalDatasource:
            locator<UpdateCollectionDateLocalDatasource>(),
        updateCollectionLocalDatasource:
            locator<UpdateCollectionLocalDatasource>(),
        updateCollectionRemoteDatasource:
            locator<UpdateCollectionRemoteDatasource>(),
      ));
  locator.registerLazySingleton<DeckRepository>(() => DeckRepositoryImpl(
        createDeckLocalDatasource: locator<CreateDeckLocalDatasource>(),
        createDeckRemoteDatasource: locator<CreateDeckRemoteDatasource>(),
        deleteDeckLocalDatasource: locator<DeleteDeckLocalDatasource>(),
        deleteDeckRemoteDatasource: locator<DeleteDeckRemoteDatasource>(),
        fetchCardInDeckLocalDatasource:
            locator<FetchCardInDeckLocalDatasource>(),
        fetchDeckLocalDatasource: locator<FetchDeckLocalDatasource>(),
        fetchDeckRemoteDatasource: locator<FetchDeckRemoteDatasource>(),
        updateDeckLocalDatasource: locator<UpdateDeckLocalDatasource>(),
        updateDeckRemoteDatasource: locator<UpdateDeckRemoteDatasource>(),
      ));
  locator.registerLazySingleton<RecordRepository>(() => RecordRepositoryImpl(
        createRecordLocalDatasource: locator<CreateRecordLocalDatasource>(),
        createRecordRemoteDatasource: locator<CreateRecordRemoteDatasource>(),
        deleteRecordLocalDatasource: locator<DeleteRecordLocalDatasource>(),
        deleteRecordRemoteDatasource: locator<DeleteRecordRemoteDatasource>(),
        fetchRecordLocalDatasource: locator<FetchRecordLocalDatasource>(),
        fetchRecordRemoteDatasource: locator<FetchRecordRemoteDatasource>(),
        importRecordRemoteDatasource: locator<ImportRecordRemoteDatasource>(),
        shareRecordRemoteDatasource: locator<ShareRecordRemoteDatasource>(),
        updateRecordLocalDatasource: locator<UpdateRecordLocalDatasource>(),
        updateRecordRemoteDatasource: locator<UpdateRecordRemoteDatasource>(),
      ));
  locator.registerLazySingleton<ImageRepository>(() => ImageRepositoryImpl(
        supabaseService: locator<SupabaseService>(),
      ));
  locator
      .registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(
            loadSettingLocalDatasource: locator<LoadSettingLocalDatasource>(),
            updateSettingLocalDatasource:
                locator<UpdateSettingLocalDatasource>(),
          ));
  locator
      .registerLazySingleton<LocalDataRepository>(() => LocalDataRepositoryImpl(
            clearUserDataLocalDatasource:
                locator<ClearUserDataLocalDatasource>(),
          ));
  locator.registerFactoryParam<CardCatalogRepository, String, void>(
      (collectionId, _) => CardCatalogRepositoryImpl(
            cardRepository: locator<CardRepository>(),
            collectionRepository: locator<CollectionRepository>(),
            gameApi: locator<GameApi>(param1: collectionId),
            createPageLocalDatasource: locator<CreatePageLocalDatasource>(),
            findPageLocalDatasource: locator<FindPageLocalDatasource>(),
            updatePageLocalDatasource: locator<UpdatePageLocalDatasource>(),
          ));
}
