import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '.config/api.dart';
import '.injector/service_locator.dart';

// ignore_for_file: unused_import
import 'data/datasource/local/@database_service.dart';
import 'data/datasource/local/@shared_preferences_service.dart';

import 'presentation/bloc/deck/bloc.dart';
import 'presentation/cubit/application.dart';
import 'presentation/cubit/nfc_cubit.dart';
import 'presentation/locale/language_manager.dart';
import 'presentation/locale/localization_delegate.dart';
import 'presentation/route/route_generator.dart';
import 'presentation/theme/@theme.dart';

import 'util/logger.dart';

import 'nfc_session_handler.dart';

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

  await Future.wait([
    ApiConfig.loadConfig(kReleaseMode ? 'production' : 'development'),
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

class _MyAppState extends State<MyApp> {
  final RouteObserver<ModalRoute> routeObserver = locator<RouteObserver<ModalRoute>>();

  late final NfcCubit nfcCubit;
  late final NfcSessionHandler nfcSessionHandler;

  @override
  void initState() {
    super.initState();
    nfcCubit = locator<NfcCubit>();
    nfcSessionHandler = NfcSessionHandler(nfcCubit)..startObserving();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      LoggerUtil.debugMessage('📱 Starting app');
    });
  }

  @override
  void dispose() {
    nfcSessionHandler.stopObservingAndDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: nfcCubit),
        BlocProvider.value(value: locator<DeckBloc>()),
        BlocProvider.value(value: locator<ApplicationCubit>()),
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
            loggedIn: state.keyIsLoggedIn,
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
