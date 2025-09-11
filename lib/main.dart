import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '.config/api.dart';
import '.config/game.dart';
import '.injector/service_locator.dart';

// ignore_for_file: unused_import
import 'data/datasource/local/@database_service.dart';
import 'data/datasource/local/@shared_preferences_service.dart';

import 'presentation/bloc/application/bloc.dart';
import 'presentation/bloc/deck/bloc.dart';
import 'presentation/bloc/nfc/bloc.dart';
import 'presentation/locale/language_manager.dart';
import 'presentation/locale/localization_delegate.dart';
import 'presentation/route/generator.dart';
import 'presentation/theme/@theme.dart';

import 'util/logger.dart';

import 'firebase_options.dart';
import 'nfc_life_cycle_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load();
  await initServiceLocator();

  // await locator<DatabaseService>().deleteDatabaseFile();
  // await locator<SharedPreferencesService>().clear();

  await ApiConfig.load(kReleaseMode ? 'production' : 'development');
  GameConfig.load(ApiConfig.instance.environment);

  await Future.wait([
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    LanguageManager.initialize(),
  ]);

  locator<ApplicationBloc>().add(InitApplicationEvent());

  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final _routeObserver = locator<RouteObserver<ModalRoute>>();
  late final NfcBloc _nfcBloc;
  late final NfcLifecycleObserver _nfcLifecycleObserver;

  @override
  void initState() {
    super.initState();
    _nfcBloc = locator<NfcBloc>();
    _nfcLifecycleObserver = NfcLifecycleObserver(_nfcBloc)..startObserving();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      LoggerUtil.i('📱 Application initialized');
    });
  }

  @override
  void dispose() {
    _nfcLifecycleObserver.stopObservingAndDispose();
    super.dispose();
  }

  bool get _isUserLoggedIn {
    final isLoggedIn = locator<FirebaseAuth>().currentUser?.uid != null;
    final isGuest = locator<ApplicationBloc>().state.guestId != null;
    return isLoggedIn || isGuest;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _nfcBloc),
        BlocProvider.value(value: locator<DeckBloc>()),
        BlocProvider.value(value: locator<ApplicationBloc>()),
      ],
      child: BlocBuilder<ApplicationBloc, ApplicationState>(
        builder: (context, appState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: appState.isDark ? AppThemes.dark : AppThemes.light,
            locale: appState.locale,
            supportedLocales: LanguageManager.supportedLanguages.map((lang) => Locale(lang)).toList(),
            localizationsDelegates: <LocalizationsDelegate<dynamic>>[
              AppLocalizationDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: RouteGenerator.getInitialRoute(loggedIn: _isUserLoggedIn),
            onGenerateRoute: RouteGenerator.generateRoute,
            navigatorObservers: [
              _routeObserver,
              _nfcLifecycleObserver,
            ],
          );
        },
      ),
    );
  }
}
