import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/deck_cubit.dart';
import '../../cubit/nfc_cubit.dart';
import '../../locale/localization.dart';

import '../shared/snackbar.dart';

class WriterListener extends StatelessWidget {
  final Widget child;

  const WriterListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<NfcCubit, NfcState>(
      listener: (context, state) async {
        if (state.successMessage.isNotEmpty) {
          AppSnackBar(
            context, 
            text: AppLocalization.of(context).translate(state.successMessage), 
            isError: false,
          );
        } else if (state.errorMessage.isNotEmpty) {
          AppSnackBar(
            context, 
            text: AppLocalization.of(context).translate(state.errorMessage), 
            isError: true,
          );
          await context.read<NfcCubit>().restartSession(
            card: context.read<DeckCubit>().state.selectedCard,
          );
        }
        context.read<NfcCubit>().clearMessages();
      },
      child: child,
    );
  }
}
