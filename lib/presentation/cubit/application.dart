import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.config/app.dart';

import 'package:nfc_deck_tracker/domain/usecase/clear_user_data.dart';
import 'package:nfc_deck_tracker/domain/usecase/initialize_setting.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_setting.dart';

import '../route/route_constant.dart';

class ApplicationCubit extends Cubit<ApplicationState> {
  final ClearUserDataUsecase clearUserDataUsecase;
  final InitializeSettingUsecase initializeSettingUsecase;
  final UpdateSettingUsecase updateSettingUsecase;

  ApplicationCubit({
    required this.clearUserDataUsecase,
    required this.initializeSettingUsecase,
    required this.updateSettingUsecase,
  }) : super(ApplicationState.initialFromConstant());

  void safeEmit(ApplicationState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> initializeCubit() async {
    final updated = await initializeSettingUsecase.call(AppConfig.defaults);

    for (final entry in updated.entries) {
      safeEmit(_mapUpdatedState(key: entry.key, value: entry.value));
    }

    safeEmit(state.copyWith(currentPageIndex: RouteConstant.on_boarding_index));
  }

  Future<void> updateSetting({
    required String key,
    required dynamic value,
  }) async {
    await updateSettingUsecase.call(key: key, value: value);
    safeEmit(_mapUpdatedState(key: key, value: value));
  }

  ApplicationState _mapUpdatedState({
    required String key,
    required dynamic value,
  }) {
    switch (key) {
      case AppConfig.keyLocale:
        return state.copyWith(locale: Locale(value));
      case AppConfig.keyIsDark:
        return state.copyWith(isDark: value);
      case AppConfig.keyIsLoggedIn:
        return state.copyWith(keyIsLoggedIn: value);
      case AppConfig.keyRecentId:
        return state.copyWith(recentId: value);
      case AppConfig.keyRecentGame:
        return state.copyWith(recentGame: value);
      case AppConfig.keyTutorialNFCIcon:
        return state.copyWith(tutorialNfcIcon: value);
      default:
        return state;
    }
  }

  String getPageRoute({
    required int index,
  }) {
    return const <int, String>{
      0: RouteConstant.my_deck,
      1: RouteConstant.tag_reader,
      2: RouteConstant.setting,
    }[index] ?? RouteConstant.not_found;
  }

  void setPageIndex({
    required int index,
  }) {
    safeEmit(state.copyWith(currentPageIndex: index));
  }

  void clearUserData() => clearUserDataUsecase.call();
}

class ApplicationState extends Equatable {
  final Locale locale;
  final bool isDark;
  final bool keyIsLoggedIn;
  final String recentId;
  final String recentGame;
  final int currentPageIndex;
  final bool tutorialNfcIcon;

  const ApplicationState({
    required this.locale,
    required this.isDark,
    required this.keyIsLoggedIn,
    required this.recentId,
    required this.recentGame,
    required this.currentPageIndex,
    required this.tutorialNfcIcon,
  });

  factory ApplicationState.initialFromConstant() {
    return ApplicationState(
      locale: Locale(AppConfig.defaults[AppConfig.keyLocale]),
      isDark: AppConfig.defaults[AppConfig.keyIsDark],
      keyIsLoggedIn: AppConfig.defaults[AppConfig.keyIsLoggedIn],
      recentId: '',
      recentGame: '',
      currentPageIndex: RouteConstant.on_boarding_index,
      tutorialNfcIcon: AppConfig.defaults[AppConfig.keyTutorialNFCIcon],
    );
  }

  ApplicationState copyWith({
    Locale? locale,
    bool? isDark,
    bool? keyIsLoggedIn,
    String? recentId,
    String? recentGame,
    int? currentPageIndex,
    bool? tutorialNfcIcon,
  }) {
    return ApplicationState(
      locale: locale ?? this.locale,
      isDark: isDark ?? this.isDark,
      keyIsLoggedIn: keyIsLoggedIn ?? this.keyIsLoggedIn,
      recentId: recentId ?? this.recentId,
      recentGame: recentGame ?? this.recentGame,
      currentPageIndex: currentPageIndex ?? this.currentPageIndex,
      tutorialNfcIcon: tutorialNfcIcon ?? this.tutorialNfcIcon,
    );
  }

  @override
  List<Object?> get props => [
        locale,
        isDark,
        keyIsLoggedIn,
        recentId,
        recentGame,
        currentPageIndex,
        tutorialNfcIcon,
      ];
}
