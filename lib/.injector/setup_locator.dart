import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'setup_cubit.dart';
import 'setup_database.dart';
import 'setup_datasource.dart';
import 'setup_firestore.dart';
import 'setup_misc.dart';
import 'setup_repository.dart';
import 'setup_shared_preferences.dart';
import 'setup_sqlite.dart';
import 'setup_usecase.dart';

final GetIt locator = GetIt.instance;

Future<void> setupLocator() async {
  try {
    LoggerUtil.debugMessage(message: '⚙️ Setting up Service Locator...');

    await setupDatabase();
    await setupSqlite();
    await setupFirestore();
    await setupSharedPreferences();
    await setupDataSource();
    await setupRepository();
    await setupUsecase();
    await setupCubit();
    await setupMisc();

    await locator.allReady();

    LoggerUtil.debugMessage(message: '👌 Service Locator setup completed successfully.');
  } catch (e) {
    LoggerUtil.debugMessage(message: '❌ Failed to setup Service Locator: $e');
  }
}
