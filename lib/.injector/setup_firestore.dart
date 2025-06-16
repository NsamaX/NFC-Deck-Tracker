import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/datasource/remote/@firestore_service.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'setup_locator.dart';

Future<void> setupFirestore() async {
  try {
    locator.registerLazySingleton(() => FirestoreService(
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
    ));

    LoggerUtil.debugMessage(message: '✔️ Firestore registered successfully.');
  } catch (e) {
    LoggerUtil.debugMessage(message: '❌ Failed to register Firestore: $e');
  }
}
