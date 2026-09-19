import '../entity/session_user.dart';

abstract interface class SessionRepository {
  SessionUser? get currentUser;
  Stream<SessionUser?> authStateChanges();
  Future<SignInResult> signInWithGoogle();
  Future<void> signOut();
}
