import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../shared/snackbar.dart';

import '../../cubit/deck_cubit.dart';
import '../../cubit/nfc_cubit.dart';

class NfcWriteTagListener extends StatelessWidget {
  final Widget child;

  const NfcWriteTagListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<NfcCubit, NfcState>(
      listener: (context, state) async {
        final deckCubit = context.read<DeckCubit>();
        final nfcCubit = context.read<NfcCubit>();

        if (state.successMessage.isNotEmpty) {
          showAppSnackBar(context, text: state.successMessage, isError: false);
        }

        if (state.errorMessage.isNotEmpty) {
          showAppSnackBar(context, text: state.errorMessage, isError: true);

          final selectedCard = deckCubit.state.selectedCard;
          if (selectedCard.cardId != null) {
            await nfcCubit.restartSession(card: selectedCard);
          }
        }
      },
      child: child,
    );
  }
}
