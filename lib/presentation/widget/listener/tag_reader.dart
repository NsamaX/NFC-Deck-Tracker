import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.config/game.dart';

import '../../cubit/drawer_cubit.dart';
import '../../cubit/nfc_cubit.dart';
import '../../cubit/reader_cubit.dart';

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
    return BlocListener<NfcCubit, NfcState>(
      listenWhen: (previous, current) => previous.lastScannedTag != current.lastScannedTag && current.lastScannedTag != null,
      listener: (context, nfcState) {
        onTagDetected.call(nfcState.lastScannedTag?.collectionId ?? Game.dummy);
        context.read<DrawerCubit>().toggleHistoryDrawer();
        context.read<NfcCubit>().clearMessages();
        context.read<ReaderCubit>().scanTag(tag: nfcState.lastScannedTag);
      },
      child: child,
    );
  }
}
