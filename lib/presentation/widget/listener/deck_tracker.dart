import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/nfc_cubit.dart';
import '../../cubit/reader_cubit.dart';
import '../../cubit/record_cubit.dart';
import '../../cubit/tracker_cubit.dart';
import '../../cubit/usage_card_cubit.dart';

class DeckTrackerListener extends StatelessWidget {
  final Widget child;

  const DeckTrackerListener({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<NfcCubit, NfcState>(
      listenWhen: (previous, current) => previous.lastScannedTag != current.lastScannedTag && current.lastScannedTag != null,
      listener: (context, state) async {
        final tag = state.lastScannedTag!;

        context.read<TrackerCubit>().handleTagScan(tag: tag);
        context.read<ReaderCubit>().scanTag(tag: tag);
        context.read<RecordCubit>().appendDataToRecord(
          data: context.read<TrackerCubit>().state.actionLog.last,
        );

        await context.read<UsageCardCubit>().loadUsageStats(
          deck: context.read<TrackerCubit>().state.originalDeck,
          record: context.read<RecordCubit>().state.currentRecord,
        );
      },
      child: child,
    );
  }
}
