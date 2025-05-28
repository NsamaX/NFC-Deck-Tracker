import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/nfc_cubit.dart';
import '../../cubit/reader_cubit.dart';
import '../../cubit/tracker_cubit.dart';

class NfcTrackListener extends StatelessWidget {
  final Widget child;

  const NfcTrackListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NfcCubit, NfcState>(
      listenWhen: (previous, current) =>
          previous.lastScannedTag != current.lastScannedTag &&
          current.lastScannedTag != null &&
          current.isSessionActive,
      listener: (context, state) {
        final readerCubit = context.read<ReaderCubit>();
        final trackerCubit = context.read<TrackerCubit>();

        readerCubit.resetScannedCard();
        trackerCubit.handleTagScan(tag: state.lastScannedTag!);
      },
      child: child,
    );
  }
}
