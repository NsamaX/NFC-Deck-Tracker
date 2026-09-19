import 'package:firebase_auth/firebase_auth.dart';

import '../../.config/runtime.dart';

/// Guest builds never instantiate Firebase authentication.
class AuthSession {
  static User? get currentUser =>
      RuntimeConfig.guestMode ? null : FirebaseAuth.instance.currentUser;

  static Stream<User?> authStateChanges() => RuntimeConfig.guestMode
      ? Stream<User?>.value(null)
      : FirebaseAuth.instance.authStateChanges();
}
