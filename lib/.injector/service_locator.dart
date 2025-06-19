import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'register_cubit.dart';
import 'register_datasource.dart';
import 'register_repository.dart';
import 'register_service.dart';
import 'register_usecase.dart';

final GetIt locator = GetIt.instance;

Future<void> initServiceLocator() async {
  try {
    LoggerUtil.debugMessage(message: '⚙️ Setting up Service Locator...');

    await registerService();
    await registerDataSource();
    await registerRepository();
    await registerUsecase();
    await registerCubit();

    await locator.allReady();

    LoggerUtil.debugMessage(message: '👌 Service Locator register completed successfully.');
  } catch (e) {
    LoggerUtil.debugMessage(message: '❌ Failed to register Service Locator: $e');
  }
}
