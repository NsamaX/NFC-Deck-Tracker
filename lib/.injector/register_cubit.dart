import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/~index.dart';
import 'package:nfc_deck_tracker/presentation/cubit/~index.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'service_locator.dart';

Future<void> registerCubit() async {
  try {
    _applicationCubit();
    _cardCubit();
    _nfcCubit();
    _readerCubit();
    _recordCubit();

    LoggerUtil.debugMessage('✔️ Cubit registered successfully.');
  } catch (e) {
    LoggerUtil.debugMessage('❌ Failed to register cubit: $e');
  }
}

void _applicationCubit() {
  locator.registerLazySingleton(() => ApplicationCubit(
    clearUserDataUsecase: locator<ClearUserDataUsecase>(),
    initializeSettingUsecase: locator<InitializeSettingUsecase>(),
    updateSettingUsecase: locator<UpdateSettingUsecase>(),
  ));
}

void _cardCubit() {
  locator.registerFactory(() => CardCubit(
    createCardUsecase: locator<CreateCardUsecase>(),
    deleteCardUsecase: locator<DeleteCardUsecase>(),
    updateCardUsecase: locator<UpdateCardUsecase>(),
  ));
}

void _nfcCubit() {
  locator.registerLazySingleton(() => NfcCubit());
}

void _readerCubit() {
  locator.registerFactoryParam<ReaderCubit, String, void>((collectionId, _) {
    return ReaderCubit(
      findCardFromTagUsecase: locator<FindCardFromTagUsecase>(param1: collectionId),
    );
  });
}

void _recordCubit() {
  locator.registerFactoryParam<RecordCubit, String, void>((deckId, _) => RecordCubit(
    deckId: deckId,
    createRecordUsecase: locator<CreateRecordUsecase>(),
    deleteRecordUsecase: locator<DeleteRecordUsecase>(),
    fetchRecordUsecase: locator<FetchRecordUsecase>(),
    updateRecordUsecase: locator<UpdateRecordUsecase>(),
  ));
}
