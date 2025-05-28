import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../cubit/nfc_cubit.dart';
import '../../cubit/reader_cubit.dart';
import '../../cubit/drawer_cubit.dart';

class NfcReadTagListener extends StatelessWidget {
  final Widget child;
  final void Function(String collectionId)? onTagDetected;

  const NfcReadTagListener({
    super.key,
    required this.child,
    this.onTagDetected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocListener<NfcCubit, NfcState>(
      listenWhen: (previous, current) =>
          previous.lastScannedTag != current.lastScannedTag &&
          current.lastScannedTag != null,
      listener: (context, state) {
        final readerCubit = context.read<ReaderCubit?>();
        final drawerCubit = context.read<DrawerCubit>();
        final tag = state.lastScannedTag!;

        if (readerCubit != null) {
          readerCubit.scanTag(tag: tag);
        }

        onTagDetected?.call(tag.collectionId);

        if (!drawerCubit.state.visibleHistoryDrawer) {
          drawerCubit.toggleHistoryDrawer();
        }
      },
      child: child,
    );
  }
}
