import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum SignInStatus {
  success,
  cancelled,
  fail,
  unknown,
}

Future<SignInStatus> googleSignIn() async {
  final FirebaseAuth auth = FirebaseAuth.instance;

  try {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return SignInStatus.cancelled;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) return SignInStatus.fail;

    return SignInStatus.success;
  } catch (e) {
    return SignInStatus.unknown;
  }
}

Future<void> googleSignOut() async {
  final FirebaseAuth auth = FirebaseAuth.instance;

  if (auth.currentUser == null) return;

  await auth.signOut();
  await GoogleSignIn().signOut();
}
