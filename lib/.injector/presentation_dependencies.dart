import 'package:flutter/widgets.dart';
import '../domain/usecase/session.dart';
import '../domain/usecase/device.dart';
import '../presentation/dependencies.dart';
import '../presentation/bloc/~index.dart';
import 'locator.dart';

PresentationDependencies createPresentationDependencies() =>
    PresentationDependencies(
      nfcBloc: locator<NfcBloc>(),
      deckBloc: locator<DeckBloc>(),
      session: locator<SessionUsecase>(),
      device: locator<DeviceUsecase>(),
      applicationBloc: locator<ApplicationBloc>(),
      collectionBloc: locator<CollectionBloc>(),
      routeObserver: locator<RouteObserver<ModalRoute>>(),
      createCardBloc: () => locator<CardBloc>(),
      createDrawerBloc: () => locator<DrawerBloc>(),
      createPinCardBloc: () => locator<PinCardBloc>(),
      createUsageCardBloc: () => locator<UsageCardBloc>(),
      createBrowseCardBloc: (id) => locator<BrowseCardBloc>(param1: id),
      createReaderBloc: (id) => locator<ReaderBloc>(param1: id),
      createRecordBloc: (id) => locator<RecordBloc>(param1: id),
      createTrackerBloc: (deck) => locator<TrackerBloc>(param1: deck),
    );
