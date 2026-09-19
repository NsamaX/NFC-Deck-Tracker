import '../entity/session_user.dart';
import '../repository/session.dart';

class SessionUsecase {
  final SessionRepository repository;
  SessionUsecase(this.repository);
  SessionUser? get currentUser => repository.currentUser;
  Stream<SessionUser?> authStateChanges() => repository.authStateChanges();
  Future<SignInResult> signInWithGoogle() => repository.signInWithGoogle();
  Future<void> signOut() => repository.signOut();
}
