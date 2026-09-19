class SessionUser {
  final String uid;
  final String? email;
  const SessionUser({required this.uid, this.email});
}

enum SignInResult { success, cancelledByUser, failed }
