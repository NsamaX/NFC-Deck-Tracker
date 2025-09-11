import 'package:flutter/widgets.dart';

import 'presentation/bloc/nfc/bloc.dart';

class NfcLifecycleObserver extends RouteObserver<ModalRoute<dynamic>> with WidgetsBindingObserver {
  final NfcBloc nfcBloc;
  bool _isDisposed = false;

  NfcLifecycleObserver(this.nfcBloc);

  void startObserving() {
    WidgetsBinding.instance.addObserver(this);
  }

  void stopObservingAndDispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _stopNFCSession(reason: 'Observer was disposed');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;

    final isInactive = state == AppLifecycleState.paused || state == AppLifecycleState.detached;

    if (isInactive) {
      _stopNFCSession(reason: 'App lifecycle changed to $state');
    }
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (_isDisposed || previousRoute == null) return;

    _stopNFCSession(reason: 'Navigated to a new route');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (_isDisposed) return;

    _stopNFCSession(reason: 'Returned from a route');
  }

  void _stopNFCSession({required String reason}) {
    if (_isDisposed || nfcBloc.isClosed || !nfcBloc.state.isSessionActive) {
      return;
    }
    nfcBloc.add(StopNfcSessionEvent(reason: reason));
  }
}
