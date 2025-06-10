import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/deck_cubit.dart';
import '../../cubit/nfc_cubit.dart';
import '../../locale/localization.dart';

import '../notification/snackbar.dart';

class CardWriterListener extends StatelessWidget {
  final Widget child;

  const CardWriterListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<NfcCubit, NfcState>(
      listener: (context, state) async {
        if (state.errorMessage.isNotEmpty) {
          AppSnackBar(
            context,
            text: AppLocalization.of(context).translate(state.errorMessage),
            isError: true,
          );

          await context.read<NfcCubit>().restartSession(
            card: context.read<DeckCubit>().state.selectedCard,
          );
        } else if (state.successMessage.isNotEmpty) {
          AppSnackBar(
            context,
            text: AppLocalization.of(context).translate(state.successMessage),
            isError: false,
          );
        }

        context.read<NfcCubit>().clearMessages();
      },
      child: child,
    );
  }
}
