import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '.config/api.dart';
import '.config/game.dart';
import '.config/runtime.dart';
import '.injector/service_locator.dart';
import '.injector/presentation_dependencies.dart';
import 'presentation/app.dart';
import 'presentation/bloc/application/bloc.dart';
import 'presentation/locale/language_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await dotenv.load();
  if (!RuntimeConfig.guestMode) {
    await Firebase.initializeApp();
  }
  await initServiceLocator();

  await ApiConfig.load(kReleaseMode ? 'production' : 'development');
  GameConfig.load(ApiConfig.instance.environment);

  await Future.wait([
    LanguageManager.initialize(),
  ]);

  locator<ApplicationBloc>().add(InitApplicationEvent());

  runApp(AppRoot(dependencies: createPresentationDependencies()));
}
