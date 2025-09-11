import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/nfc/bloc.dart';
import '../../bloc/reader/bloc.dart';
import '../../bloc/record/bloc.dart';
import '../../bloc/tracker/bloc.dart';
import '../../bloc/usage_card/bloc.dart';
import '../../locale/localization.dart';

import '../notification/snackbar.dart';

class TrackerListener extends StatelessWidget {
  final Widget child;

  const TrackerListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalization.of(context).translate;

    return MultiBlocListener(
      listeners: [
        BlocListener<NfcBloc, NfcState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage && current.errorMessage.isNotEmpty ||
              previous.warningMessage != current.warningMessage && current.warningMessage.isNotEmpty ||
              current.lastScannedTag != null && previous.lastScannedTag != current.lastScannedTag ||
              current.lastScannedTag != null && current.successMessage.isNotEmpty && previous.successMessage != current.successMessage,
          listener: (context, state) {
            if (state.errorMessage.isNotEmpty) {
              AppSnackBar(
                context,
                text: localize(state.errorMessage),
                type: SnackBarType.error,
              );
              context.read<NfcBloc>().add(RestartNfcSessionEvent());
            } else if (state.warningMessage.isNotEmpty) {
              AppSnackBar(
                context,
                text: localize(state.warningMessage),
                type: SnackBarType.warning,
              );
            } else if (state.successMessage.isNotEmpty) {
              final tag = state.lastScannedTag!;
              context.read<ReaderBloc>().add(ReadTagEvent(tag: tag));
              context.read<TrackerBloc>().add(TrackingInteractionEvent(tag: tag));
            }
            context.read<NfcBloc>().add(ClearNFCMessagesEvent());
          },
        ),
        BlocListener<TrackerBloc, TrackerState>(
          listenWhen: (previous, current) =>
              previous.warningMessage != current.warningMessage &&
              current.warningMessage.isNotEmpty,
          listener: (context, state) {
            AppSnackBar(
              context,
              text: localize(state.warningMessage),
              type: SnackBarType.warning,
            );
          },
        ),
        BlocListener<ReaderBloc, ReaderState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage && current.errorMessage.isNotEmpty ||
              previous.warningMessage != current.warningMessage && current.warningMessage.isNotEmpty ||
              previous.successMessage != current.successMessage && current.successMessage.isNotEmpty,
          listener: (context, state) {
            final localize = AppLocalization.of(context).translate;
            if (state.errorMessage.isNotEmpty) {
              AppSnackBar(
                context,
                text: localize(state.errorMessage),
                type: SnackBarType.error,
              );
            } else if (state.warningMessage.isNotEmpty) {
              AppSnackBar(
                context,
                text: localize(state.warningMessage),
                type: SnackBarType.warning,
              );
            }
            context.read<ReaderBloc>().add(ClearReaderMessagesEvent());
          },
        ),
        BlocListener<TrackerBloc, TrackerState>(
          listenWhen: (previous, current) =>
              previous.actionLog.length != current.actionLog.length,
          listener: (context, state) {
            if (state.warningMessage.isEmpty && state.actionLog.isNotEmpty) {
              context.read<RecordBloc>().add(UpdateRecordEvent(
                data: state.actionLog.last,
              ));
            }
          },
        ),
        BlocListener<RecordBloc, RecordState>(
          listenWhen: (previous, current) =>
              previous.currentRecord.data.length != current.currentRecord.data.length,
          listener: (context, state) {
            final trackerState = context.read<TrackerBloc>().state;

            context.read<UsageCardBloc>().add(CalculateUsageCardEvent(
              deck: trackerState.originalDeck,
              record: state.currentRecord,
            ));
          },
        ),
      ],
      child: child,
    );
  }
}
