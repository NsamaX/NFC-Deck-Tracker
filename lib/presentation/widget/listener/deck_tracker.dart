import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/tracker/bloc.dart';
import '../../bloc/usage_card/bloc.dart';
import '../../cubit/nfc_cubit.dart';
import '../../cubit/reader.dart';
import '../../cubit/record.dart';
import '../../locale/localization.dart';

import '../notification/snackbar.dart';

class DeckTrackerListener extends StatelessWidget {
  final Widget child;

  const DeckTrackerListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final localize = AppLocalization.of(context).translate;

    return MultiBlocListener(
      listeners: [
        BlocListener<NfcCubit, NfcState>(
          listenWhen: (previous, current) =>
              previous.lastScannedTag != current.lastScannedTag && current.lastScannedTag != null ||
              previous.errorMessage != current.errorMessage && current.errorMessage.isNotEmpty ||
              previous.warningMessage != current.warningMessage && current.warningMessage.isNotEmpty,
          listener: (context, state) async {
            if (state.errorMessage.isNotEmpty) {
              AppSnackBar(
                context,
                text: localize(state.errorMessage),
                type: SnackBarType.error,
              );

              await context.read<NfcCubit>().restartSession();
            } else if (state.warningMessage.isNotEmpty) {
              AppSnackBar(
                context,
                text: localize(state.warningMessage),
                type: SnackBarType.warning,
              );
            }

            final tag = state.lastScannedTag;
            if (tag != null) {
              context.read<TrackerBloc>().add(HandleTagScanEvent(tag: tag));

              if (context.read<TrackerBloc>().state.warningMessage.isEmpty) {
                context.read<ReaderCubit>().scanTag(tag: tag);
                context.read<RecordCubit>().appendDataToRecord(
                  data: context.read<TrackerBloc>().state.actionLog.last,
                );

                context.read<UsageCardBloc>().add(LoadUsageStatsEvent(
                  deck: context.read<TrackerBloc>().state.originalDeck,
                  record: context.read<RecordCubit>().state.currentRecord,
                ));
              }
            }

            context.read<NfcCubit>().clearMessages();
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
      ],
      child: child,
    );
  }
}
