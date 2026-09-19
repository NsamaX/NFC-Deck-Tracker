import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../bloc/application/bloc.dart';
import '../route/constant.dart';

const _uuid = Uuid();

Future<void> signInAsGuest(BuildContext context) async {
  if (!context.mounted) return;
  context
      .read<ApplicationBloc>()
      .add(UpdateSettingsEvent((s) => s.copyWith(guestId: _uuid.v4())));
  enterApp(context);
}

Future<void> signInAsUser(BuildContext context) async {
  if (!context.mounted) return;
  context
      .read<ApplicationBloc>()
      .add(UpdateSettingsEvent((s) => s.copyWith(clearGuestId: true)));
  enterApp(context);
}

void enterApp(BuildContext context) {
  final applicationBloc = context.read<ApplicationBloc>();

  applicationBloc.add(SetPageIndexEvent(
    index: RouteConstant.on_boarding_index,
  ));

  Navigator.of(context).pushNamedAndRemoveUntil(
    RouteConstant.on_boarding_route,
    (_) => false,
  );
}
