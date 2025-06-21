import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.config/game.dart';

import '../../bloc/drawer/bloc.dart';
import '../../cubit/nfc_cubit.dart';
import '../../cubit/reader.dart';
import '../../locale/localization.dart';

import '../notification/snackbar.dart';

class TagReaderListener extends StatelessWidget {
  final Widget child;
  final Function(String) onTagDetected;

  const TagReaderListener({
    super.key,
    required this.child,
    required this.onTagDetected,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<NfcCubit, NfcState>(
          listenWhen: (previous, current) =>
              previous.lastScannedTag != current.lastScannedTag && current.lastScannedTag != null ||
              previous.errorMessage != current.errorMessage && current.errorMessage.isNotEmpty ||
              previous.warningMessage != current.warningMessage && current.warningMessage.isNotEmpty ||
              previous.successMessage != current.successMessage && current.successMessage.isNotEmpty,
          listener: (context, state) async {
            if (state.errorMessage.isNotEmpty) {
              AppSnackBar(
                context,
                text: AppLocalization.of(context).translate(state.errorMessage),
                type: SnackBarType.error,
              );

              await context.read<NfcCubit>().restartSession();
            } else if (state.warningMessage.isNotEmpty) {
              AppSnackBar(
                context,
                text: AppLocalization.of(context).translate(state.warningMessage),
                type: SnackBarType.warning,
              );
            } else if (state.successMessage.isNotEmpty) {
              onTagDetected.call(state.lastScannedTag?.collectionId ?? GameConfig.dummy);
              context.read<ReaderCubit>().scanTag(tag: state.lastScannedTag!);
            }

            context.read<NfcCubit>().clearMessages();
          },
        ),
        BlocListener<ReaderCubit, ReaderState>(
          listener: (context, state) {
            if (state.errorMessage.isNotEmpty) {
              AppSnackBar(
                context,
                text: AppLocalization.of(context).translate(state.errorMessage),
                type: SnackBarType.error,
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

              if (!context.read<DrawerBloc>().state.visibleHistoryDrawer) {
                context.read<DrawerBloc>().add(ToggleHistoryDrawerEvent());
              }
            }

            context.read<ReaderCubit>().clearMessages();
          },
        ),
      ],
      child: child,
    );
  }
}
