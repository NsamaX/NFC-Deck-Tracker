import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:nfc_deck_tracker/.config/setting.dart';

import '../../cubit/application_cubit.dart';
import '../../route/route_constant.dart';

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

Future<void> signOutFromGoogle() async {
  final FirebaseAuth auth = FirebaseAuth.instance;

  await auth.signOut();
  await GoogleSignIn().signOut();
}

Future<void> handleGuestSignIn(BuildContext context) async {
  final FirebaseAuth auth = FirebaseAuth.instance;

  if (auth.currentUser != null) {
    await auth.signOut();
    await GoogleSignIn().signOut();
  }

  context.read<ApplicationCubit>().updateSetting(
    key: Setting.keyLoggedIn,
    value: true,
  );

  context.read<ApplicationCubit>().setPageIndex(
    index: RouteConstant.on_boarding_index,
  );

  Navigator.of(context).pushNamedAndRemoveUntil(
    RouteConstant.on_boarding_route,
    (_) => false,
  );
}
