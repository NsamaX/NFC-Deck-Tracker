import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

import 'setup_locator.dart';

Future<void> setupMisc() async {
  try {
    if (!locator.isRegistered<FirebaseAuth>()) {
      locator.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    }

    if (!locator.isRegistered<FirebaseFirestore>()) {
      locator.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
    }

    locator.registerLazySingleton<RouteObserver<ModalRoute>>(() => RouteObserver<ModalRoute>());

    LoggerUtil.debugMessage(message: '✔️ Miscellaneous services registered successfully.');
  } catch (e) {
    LoggerUtil.debugMessage(message: '❌ Failed to register Miscellaneous services: $e');
  }
}
