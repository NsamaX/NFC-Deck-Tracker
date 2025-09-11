import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/deck/bloc.dart';
import '../../bloc/nfc/bloc.dart';
import '../../locale/localization.dart';

import '../notification/snackbar.dart';

class WriterListener extends StatelessWidget {
  final Widget child;

  const WriterListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<NfcBloc, NfcState>(
      listener: (context, state) {
        if (state.errorMessage.isNotEmpty) {
          AppSnackBar(
            context,
            text: AppLocalization.of(context).translate(state.errorMessage),
            type: SnackBarType.error,
          );

          context.read<NfcBloc>().add(RestartNfcSessionEvent(
            card: context.read<DeckBloc>().state.selectedCard,
          ));
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

        context.read<NfcBloc>().add(ClearNFCMessagesEvent());
      },
      child: child,
    );
  }
}
