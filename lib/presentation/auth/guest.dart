import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../bloc/application/bloc.dart';
import '../route/constant.dart';

const _uuid = Uuid();

Future<void> signInAsGuest(BuildContext context) async {
  if (!context.mounted) return;

  final applicationBloc = context.read<ApplicationBloc>();
  final guestId = _uuid.v4();

  applicationBloc.add(UpdateSettingsEvent((s) => s.copyWith(guestId: guestId)));

  applicationBloc.add(SetPageIndexEvent(
    index: RouteConstant.on_boarding_index,
  ));

  Navigator.of(context).pushNamedAndRemoveUntil(
    RouteConstant.on_boarding_route,
    (_) => false,
  );
}
