import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/nfc_cubit.dart';
import '../../cubit/record_cubit.dart';
import '../../cubit/tracker_cubit.dart';

class TrackerListener extends StatelessWidget {
  final Widget child;

  const TrackerListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NfcCubit, NfcState>(
      listenWhen: (previous, current) => previous.lastScannedTag != current.lastScannedTag && current.lastScannedTag != null,
      listener: (context, state) {
        context.read<TrackerCubit>().handleTagScan(tag: state.lastScannedTag!);
        context.read<RecordCubit>().appendDataToRecord(data: context.read<TrackerCubit>().state.actionLog.last);
      },
      child: child,
    );
  }
}
