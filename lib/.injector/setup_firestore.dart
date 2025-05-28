import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import 'package:nfc_deck_tracker/data/datasource/remote/_firestore_service.dart';

import 'setup_locator.dart';

Future<void> setupFirestore() async {
  try {
    locator.registerLazySingleton(() => FirestoreService(
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
    ));

    debugPrint('✔️ Firestore registered successfully.');
  } catch (e) {
    debugPrint('❌ Failed to register Firestore: $e');
  }
}
