import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entity/session_user.dart';
import '../../domain/repository/session.dart';

class FirebaseSessionRepository implements SessionRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  FirebaseSessionRepository(
      {required FirebaseAuth auth, required GoogleSignIn googleSignIn})
      : _auth = auth,
        _googleSignIn = googleSignIn;

  SessionUser? _mapUser(User? user) =>
      user == null ? null : SessionUser(uid: user.uid, email: user.email);
  @override
  SessionUser? get currentUser => _mapUser(_auth.currentUser);
  @override
  Stream<SessionUser?> authStateChanges() =>
      _auth.authStateChanges().map(_mapUser);

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

  Future<void> signOut() async {
    if (_auth.currentUser == null) return;

    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}

class GuestSessionRepository implements SessionRepository {
  @override
  SessionUser? get currentUser => null;
  @override
  Stream<SessionUser?> authStateChanges() => Stream.value(null);
  @override
  Future<SignInResult> signInWithGoogle() async => SignInResult.failed;
  @override
  Future<void> signOut() async {}
}
