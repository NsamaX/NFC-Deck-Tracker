import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.config/app.dart';

import 'package:nfc_deck_tracker/domain/usecase/clear_local_datasource.dart';
import 'package:nfc_deck_tracker/domain/usecase/initialize_setting.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_setting.dart';

import '../route/route_constant.dart';

part 'application_state.dart';

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
      case AppConfig.keyLocale:          return state.copyWith(locale: Locale(value));
      case AppConfig.keyIsDark:          return state.copyWith(isDark: value);
      case AppConfig.keyIsLoggedIn:      return state.copyWith(keyIsLoggedIn: value);
      case AppConfig.keyRecentId:        return state.copyWith(recentId: value);
      case AppConfig.keyRecentGame:      return state.copyWith(recentGame: value);
      case AppConfig.keyTutorialNFCIcon: return state.copyWith(tutorialNfcIcon: value);
      case AppConfig.keyTutorialHowTo:   return state.copyWith(tutorialHowTo: value);
      default: return state;
    }
  }

  String getPageRoute({
    required int index,
  }) {
    return const <int, String> {
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

  void signOut() => clearUserDataUsecase.call();
}
