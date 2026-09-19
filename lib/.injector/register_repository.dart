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
        localDatasource: locator<CardLocalDatasource>(),
        remoteDatasource: locator<CardRemoteDatasource>(),
      ));
  locator.registerLazySingleton<CollectionRepository>(
      () => CollectionRepositoryImpl(
            localDatasource: locator<CollectionLocalDatasource>(),
            remoteDatasource: locator<CollectionRemoteDatasource>(),
          ));
  locator.registerLazySingleton<DeckRepository>(() => DeckRepositoryImpl(
        localDatasource: locator<DeckLocalDatasource>(),
        remoteDatasource: locator<DeckRemoteDatasource>(),
      ));
  locator.registerLazySingleton<RecordRepository>(() => RecordRepositoryImpl(
        localDatasource: locator<RecordLocalDatasource>(),
        remoteDatasource: locator<RecordRemoteDatasource>(),
      ));
  locator.registerLazySingleton<ImageRepository>(() => ImageRepositoryImpl(
        supabaseService: locator<SupabaseService>(),
      ));
  locator
      .registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(
            localDatasource: locator<SettingsLocalDatasource>(),
          ));
  locator
      .registerLazySingleton<LocalDataRepository>(() => LocalDataRepositoryImpl(
            localDatasource: locator<UserDataLocalDatasource>(),
          ));
  locator.registerFactoryParam<CardCatalogRepository, String, void>(
      (collectionId, _) => CardCatalogRepositoryImpl(
            cardRepository: locator<CardRepository>(),
            collectionRepository: locator<CollectionRepository>(),
            gameApi: locator<GameApi>(param1: collectionId),
            pageDatasource: locator<PageLocalDatasource>(),
          ));
}
