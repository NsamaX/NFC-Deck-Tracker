import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/drawer/bloc.dart';
import '../../bloc/nfc/bloc.dart';
import '../../bloc/reader/bloc.dart';
import '../../locale/localization.dart';

import '../notification/snackbar.dart';

class ReaderListener extends StatelessWidget {
  final Widget child;

  const ReaderListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<NfcBloc, NfcState>(
          listener: (context, state) {
            if (state.errorMessage.isNotEmpty) {
              AppSnackBar(
                context,
                text: AppLocalization.of(context).translate(state.errorMessage),
                type: SnackBarType.error,
              );

              context.read<NfcBloc>().add(RestartNfcSessionEvent());
            } else if (state.warningMessage.isNotEmpty) {
              AppSnackBar(
                context,
                text:
                    AppLocalization.of(context).translate(state.warningMessage),
                type: SnackBarType.warning,
              );
            } else if (state.successMessage.isNotEmpty) {
              context
                  .read<ReaderBloc>()
                  .add(ReadTagEvent(tag: state.lastScannedTag));
            }

            context.read<NfcBloc>().add(ClearNFCMessagesEvent());
          },
        ),
        BlocListener<ReaderBloc, ReaderState>(
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
                text:
                    AppLocalization.of(context).translate(state.warningMessage),
                type: SnackBarType.warning,
              );
            } else if (state.successMessage.isNotEmpty) {
              AppSnackBar(
                context,
                text:
                    AppLocalization.of(context).translate(state.successMessage),
                type: SnackBarType.success,
              );

              if (!context.read<DrawerBloc>().state.visibleHistoryDrawer) {
                context.read<DrawerBloc>().add(ToggleHistoryDrawerEvent());
              }
            }

            context.read<ReaderBloc>().add(ClearReaderMessagesEvent());
          },
        ),
      ],
      child: child,
    );
  }
}
