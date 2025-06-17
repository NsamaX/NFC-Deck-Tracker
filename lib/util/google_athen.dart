import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:nfc_deck_tracker/.config/app.dart';

import 'package:nfc_deck_tracker/presentation/cubit/application_cubit.dart';
import 'package:nfc_deck_tracker/presentation/route/route_constant.dart';

enum SignInStatus {
  success,
  cancelled,
  fail,
  unknown,
}

Future<SignInStatus> signInWithGoogle() async {
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

Future<void> signOutFromGoogle() async {
  final FirebaseAuth auth = FirebaseAuth.instance;

  if (auth.currentUser == null) return;

  await auth.signOut();
  await GoogleSignIn().signOut();
}

Future<void> handleGuestSignIn({
  required BuildContext context,
}) async {
  context.read<ApplicationCubit>().updateSetting(
    key: App.keyIsLoggedIn,
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
