import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'setting_constant.dart';

import '../../cubit/application_cubit.dart';
import '../../route/route.dart';

Future<String> signInWithGoogle() async {
  final FirebaseAuth auth = FirebaseAuth.instance;

  try {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) return 'cancelled';

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await auth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) return 'fail';

    return 'success';
  } catch (e) {
    return 'unknown';
  }
}

Future<void> signOutFromGoogle({
  required ApplicationCubit applicationCubit,
}) async {
  final FirebaseAuth auth = FirebaseAuth.instance;

  await auth.signOut();
  await GoogleSignIn().signOut();
}

void handleGuestSignIn({
  required NavigatorState navigator,
  required ApplicationCubit applicationCubit,
}) {
  applicationCubit.updateSetting(
    key: SettingConstant.keyLoggedIn,
    value: true,
  );

  applicationCubit.setPageIndex(
    index: RouteConstant.on_boarding_index,
  );

  navigator.pushNamedAndRemoveUntil(
    RouteConstant.on_boarding_route,
    (_) => false,
  );
}
