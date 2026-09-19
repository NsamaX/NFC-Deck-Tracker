import 'package:flutter/widgets.dart';
import '../domain/entity/deck.dart';
import '../domain/usecase/session.dart';
import '../domain/usecase/device.dart';
import 'bloc/~index.dart';

/// Typed UI dependencies. The composition root supplies factories; views own
/// factory-created blocs and borrow the shared application/collection blocs.
class PresentationDependencies {
  final NfcBloc nfcBloc;
  final DeckBloc deckBloc;
  final SessionUsecase session;
  final DeviceUsecase device;
  final ApplicationBloc applicationBloc;
  final CollectionBloc collectionBloc;
  final RouteObserver<ModalRoute> routeObserver;
  final CardBloc Function() createCardBloc;
  final DrawerBloc Function() createDrawerBloc;
  final PinCardBloc Function() createPinCardBloc;
  final UsageCardBloc Function() createUsageCardBloc;
  final BrowseCardBloc Function(String) createBrowseCardBloc;
  final ReaderBloc Function(String) createReaderBloc;
  final RecordBloc Function(String) createRecordBloc;
  final TrackerBloc Function(DeckEntity) createTrackerBloc;

  const PresentationDependencies({
    required this.nfcBloc,
    required this.deckBloc,
    required this.session,
    required this.device,
    required this.applicationBloc,
    required this.collectionBloc,
    required this.routeObserver,
    required this.createCardBloc,
    required this.createDrawerBloc,
    required this.createPinCardBloc,
    required this.createUsageCardBloc,
    required this.createBrowseCardBloc,
    required this.createReaderBloc,
    required this.createRecordBloc,
    required this.createTrackerBloc,
  });
}

class PresentationScope extends InheritedWidget {
  final PresentationDependencies dependencies;
  const PresentationScope(
      {super.key, required this.dependencies, required super.child});

  /// Non-listening lookup also supports bloc creation in State.initState.
  static PresentationDependencies read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<PresentationScope>();
    assert(scope != null, 'PresentationScope must wrap the application.');
    return scope!.dependencies;
  }

  @override
  bool updateShouldNotify(PresentationScope oldWidget) =>
      dependencies != oldWidget.dependencies;
}
