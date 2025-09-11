import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum SignInResult {
  success,
  cancelledByUser,
  failed,
}

final _auth = FirebaseAuth.instance;
final _googleSignIn = GoogleSignIn();

Future<SignInResult> signInWithGoogle() async {
  try {
    await _googleSignIn.signOut();

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return SignInResult.cancelledByUser;
    }

    final googleAuth = await googleUser.authentication;
    if (googleAuth.accessToken == null || googleAuth.idToken == null) {
      return SignInResult.failed;
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await _auth.signInWithCredential(credential);
    return SignInResult.success;

  } on Exception catch (e) {
    if (kDebugMode) {
      print('Sign-in with Google failed: $e');
    }
    return SignInResult.failed;
  }
}

Future<void> signOutFromGoogle() async {
  if (_auth.currentUser == null) return;

  await Future.wait([
    _auth.signOut(),
    _googleSignIn.signOut(),
  ]);
}
