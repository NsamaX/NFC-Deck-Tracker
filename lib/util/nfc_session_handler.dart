import 'package:flutter/widgets.dart';

import 'package:nfc_deck_tracker/presentation/cubit/nfc_cubit.dart';

class NfcSessionHandler extends RouteObserver<ModalRoute> with WidgetsBindingObserver {
  final NfcCubit nfcCubit;
  bool _isDisposed = false;

  NfcSessionHandler({
    required this.nfcCubit,
  });

  void startObserving() => WidgetsBinding.instance.addObserver(this);

  void stopObservingAndDispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _stopNFCSession(reason: 'App closed (dispose)');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _stopNFCSession(reason: 'App went to background or closed');
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (previousRoute != null) {
      _stopNFCSession(reason: 'Navigated to a new page');
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    _stopNFCSession(reason: 'Returned to previous page');
  }

  void _stopNFCSession({
    required String reason,
  }) {
    if (!nfcCubit.isClosed && nfcCubit.state.isSessionActive) {
      nfcCubit.stopSession(reason: reason);
    }
  }
}
