import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '.injector/setup_locator.dart';

import 'data/datasource/api/@api_config.dart';

import 'presentation/cubit/application_cubit.dart';
import 'presentation/cubit/deck_cubit.dart';
import 'presentation/cubit/nfc_cubit.dart';
import 'presentation/locale/language_manager.dart';
import 'presentation/locale/localization_delegate.dart';
import 'presentation/route/route_generator.dart';
import 'presentation/theme/@theme.dart';

import 'util/nfc_session_handler.dart';

// ignore_for_file: unused_import
import 'data/datasource/local/@database_service.dart';
import 'data/datasource/local/@shared_preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load();
  await setupLocator();

  await locator<DatabaseService>().deleteDatabaseFile();
  await locator<SharedPreferencesService>().clear();

  await Future.wait([
    ApiConfig.loadConfig('development'), // 'production' for release
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
    LanguageManager.loadSupportedLanguages(),
  ]);

  await locator<ApplicationCubit>().initializeCubit();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final RouteObserver<ModalRoute> routeObserver = locator<RouteObserver<ModalRoute>>();

  late final NfcCubit nfcCubit;
  late final NfcSessionHandler nfcSessionHandler;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    nfcCubit = locator<NfcCubit>();
    nfcSessionHandler = NfcSessionHandler(nfcCubit: nfcCubit)..startObserving();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      debugPrint('📱 Starting app in ${kReleaseMode ? 'release' : 'debug'} mode');
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    nfcSessionHandler.stopObservingAndDispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      nfcSessionHandler.stopObservingAndDispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<NfcCubit>.value(value: nfcCubit),
        BlocProvider(create: (_) => locator<DeckCubit>()),
        BlocProvider(create: (_) => locator<ApplicationCubit>()),
      ],
      child: BlocBuilder<ApplicationCubit, ApplicationState>(
        builder: (context, state) => MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: state.locale,
          supportedLocales: _supportedLocales,
          localizationsDelegates: _localizationsDelegates,
          theme: AppTheme(state.isDark),
          onGenerateRoute: RouteGenerator.generateRoute,
          initialRoute: RouteGenerator.getInitialRoute(
            loggedIn: state.loggedIn,
          ),
          navigatorObservers: [
            routeObserver,
            nfcSessionHandler,
          ],
        ),
      ),
    );
  }

  static final List<Locale> _supportedLocales = LanguageManager.supportedLanguages
      .map((lang) => Locale(lang))
      .toList();

  static final List<LocalizationsDelegate<dynamic>> _localizationsDelegates = [
    const AppLocalizationDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}
