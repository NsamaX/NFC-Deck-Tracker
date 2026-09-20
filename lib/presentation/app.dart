import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../util/logger.dart';
import 'dependencies.dart';
import 'bloc/application/bloc.dart';
import 'bloc/nfc/bloc.dart';
import 'locale/language_manager.dart';
import 'locale/localization_delegate.dart';
import 'route/generator.dart';
import 'theme/theme.dart';
import 'nfc_life_cycle_observer.dart';
import 'widget/notification/app_error_banner.dart';

class AppRoot extends StatefulWidget {
  final PresentationDependencies dependencies;
  const AppRoot({super.key, required this.dependencies});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  PresentationDependencies get _dependencies => widget.dependencies;
  RouteObserver<ModalRoute> get _routeObserver => _dependencies.routeObserver;
  late final NfcBloc _nfcBloc;
  late final NfcLifecycleObserver _nfcLifecycleObserver;

  @override
  void initState() {
    super.initState();
    _nfcBloc = _dependencies.nfcBloc;
    _nfcLifecycleObserver = NfcLifecycleObserver(_nfcBloc)..startObserving();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      LoggerUtil.i('Application initialized');
    });
  }

  @override
  void dispose() {
    _nfcLifecycleObserver.stopObservingAndDispose();
    super.dispose();
  }

  bool get _isUserLoggedIn {
    final isLoggedIn = _dependencies.session.currentUser?.uid != null;
    final isGuest = _dependencies.applicationBloc.state.guestId != null;
    return isLoggedIn || isGuest;
  }

  @override
  Widget build(BuildContext context) {
    return PresentationScope(
      dependencies: _dependencies,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _nfcBloc),
          BlocProvider.value(value: _dependencies.deckBloc),
          BlocProvider.value(value: _dependencies.deckBuilderBloc),
          BlocProvider.value(value: _dependencies.applicationBloc),
        ],
        child: BlocBuilder<ApplicationBloc, ApplicationState>(
          builder: (context, appState) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: appState.isDark ? AppThemes.dark : AppThemes.light,
              locale: appState.locale,
              supportedLocales: LanguageManager.supportedLanguages
                  .map((lang) => Locale(lang))
                  .toList(),
              localizationsDelegates: <LocalizationsDelegate<dynamic>>[
                AppLocalizationDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              initialRoute:
                  RouteGenerator.getInitialRoute(loggedIn: _isUserLoggedIn),
              onGenerateRoute: RouteGenerator.generateRoute,
              builder: (context, child) =>
                  AppErrorBanner(child: child ?? const SizedBox.shrink()),
              navigatorObservers: [
                _routeObserver,
                _nfcLifecycleObserver,
              ],
            );
          },
        ),
      ),
    );
  }
}
