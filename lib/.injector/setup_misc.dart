import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'setup_locator.dart';

import 'package:firebase_auth/firebase_auth.dart';

Future<void> setupMisc() async {
  try {
    if (!locator.isRegistered<FirebaseAuth>()) {
      locator.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
    }

    if (!locator.isRegistered<FirebaseFirestore>()) {
      locator.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
    }

    locator.registerLazySingleton<RouteObserver<ModalRoute>>(() => RouteObserver<ModalRoute>());

    debugPrint('✔️ Miscellaneous services registered successfully.');
  } catch (e) {
    debugPrint('❌ Failed to register Miscellaneous services: $e');
  }
}
