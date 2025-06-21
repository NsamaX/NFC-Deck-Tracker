import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/usecase/~index.dart';
import 'package:nfc_deck_tracker/presentation/bloc/~index.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'service_locator.dart';

Future<void> registerBloc() async {
  try {
    _browseCardBloc();
    _deckBloc();

    LoggerUtil.debugMessage('✔️ Bloc registered successfully.');
  } catch (e) {
    LoggerUtil.debugMessage('❌ Failed to register bloc: $e');
  }
}

void _browseCardBloc() {
  locator.registerFactoryParam<BrowseCardBloc, String, void>((collectionId, _) => BrowseCardBloc(
    fetchCardUsecase: locator<FetchCardUsecase>(param1: collectionId),
  ));
}

void _deckBloc() {
  locator.registerLazySingleton(() => DeckBloc(
    createDeckUsecase: locator<CreateDeckUsecase>(),
    deleteDeckUsecase: locator<DeleteDeckUsecase>(),
    fetchCardInDeckUsecase: locator<FetchCardInDeckUsecase>(),
    fetchDeckUsecase: locator<FetchDeckUsecase>(),
    generateShareDeckClipboardUsecase: locator<GenerateShareDeckClipboardUsecase>(),
    updateCardInDeckUsecase: locator<UpdateCardInDeckUsecase>(),
    updateDeckUsecase: locator<UpdateDeckUsecase>(),
  ));
}
