import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'register_bloc.dart';
import 'register_cubit.dart';
import 'register_datasource.dart';
import 'register_repository.dart';
import 'register_service.dart';
import 'register_usecase.dart';

final GetIt locator = GetIt.instance;

Future<void> initServiceLocator() async {
  try {
    LoggerUtil.debugMessage('⚙️ Setting up Service Locator...');

    await registerService();
    await registerDataSource();
    await registerRepository();
    await registerUsecase();
    await registerBloc();
    await registerCubit();

    await locator.allReady();

    LoggerUtil.debugMessage('👌 Service locator register completed successfully.');
  } catch (e) {
    LoggerUtil.debugMessage('❌ Failed to register service locator: $e');
  }
}
