import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../locale/localization.dart';
import '../notification/snackbar.dart';

class ErrorListener<B extends StateStreamable<S>, S> extends StatelessWidget {
  final String Function(S state) errorOf;
  final Widget child;

  const ErrorListener({super.key, required this.errorOf, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<B, S>(
      listenWhen: (previous, current) =>
          errorOf(previous) != errorOf(current) && errorOf(current).isNotEmpty,
      listener: (context, state) => AppSnackBar(
        context,
        text: AppLocalization.of(context).translate(errorOf(state)),
        type: SnackBarType.error,
      ),
      child: child,
    );
  }
}
