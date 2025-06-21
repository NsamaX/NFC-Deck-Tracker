import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/deck/bloc.dart';
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
            type: SnackBarType.error,
          );

          await context.read<NfcCubit>().restartSession(
            card: context.read<DeckBloc>().state.selectedCard,
          );
        } else if (state.warningMessage.isNotEmpty) {
          AppSnackBar(
            context,
            text: AppLocalization.of(context).translate(state.warningMessage),
            type: SnackBarType.warning,
          );
        } else if (state.successMessage.isNotEmpty) {
          AppSnackBar(
            context,
            text: AppLocalization.of(context).translate(state.successMessage),
            type: SnackBarType.success,
          );
        }

        context.read<NfcCubit>().clearMessages();
      },
      child: child,
    );
  }
}
