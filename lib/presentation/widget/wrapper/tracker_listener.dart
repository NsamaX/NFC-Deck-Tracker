import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/nfc_cubit.dart';
import '../../cubit/reader_cubit.dart';
import '../../cubit/record_cubit.dart';
import '../../cubit/tracker_cubit.dart';
import '../../cubit/usage_card_cubit.dart';

class TrackerListener extends StatelessWidget {
  final Widget child;

  const TrackerListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NfcCubit, NfcState>(
      listenWhen: (previous, current) =>
          previous.lastScannedTag != current.lastScannedTag &&
          current.lastScannedTag != null,
      listener: (context, state) async {
        final trackerCubit = context.read<TrackerCubit>();
        final readerCubit = context.read<ReaderCubit>();
        final recordCubit = context.read<RecordCubit>();
        final usageCardCubit = context.read<UsageCardCubit>();

        final tag = state.lastScannedTag!;

        trackerCubit.handleTagScan(tag: tag);
        readerCubit.scanTag(tag: tag);
        recordCubit.appendDataToRecord(data: trackerCubit.state.actionLog.last);

        await usageCardCubit.loadUsageStats(
          deck: trackerCubit.state.originalDeck,
          record: recordCubit.state.currentRecord,
        );
      },
      child: child,
    );
  }
}
