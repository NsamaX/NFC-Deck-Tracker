import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.config/app.dart';

import 'package:nfc_deck_tracker/presentation/cubit/application_cubit.dart';
import 'package:nfc_deck_tracker/presentation/route/route_constant.dart';

Future<void> guestSignIn({
  required BuildContext context,
}) async {
  context.read<ApplicationCubit>().updateSetting(
    key: AppConfig.keyIsLoggedIn,
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
