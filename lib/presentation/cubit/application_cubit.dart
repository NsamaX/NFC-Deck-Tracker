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
  final ClearLocalDataSourceUsecase clearLocalDataSourceUsecase;
  final InitializeSettingUsecase initializeSettingUsecase;
  final UpdateSettingUsecase updateSettingUsecase;

  ApplicationCubit({
    required this.clearLocalDataSourceUsecase,
    required this.initializeSettingUsecase,
    required this.updateSettingUsecase,
  }) : super(ApplicationState.initialFromConstant());

  void safeEmit(ApplicationState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> initializeCubit() async {
    final updated = await initializeSettingUsecase.call(App.all);

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
      case App.keyLocale:         return state.copyWith(locale: Locale(value));
      case App.keyIsDark:         return state.copyWith(isDark: value);
      case App.keyIsLoggedIn: return state.copyWith(keyIsLoggedIn: value);
      case App.keyRecentId:       return state.copyWith(recentId: value);
      case App.keyRecentGame:     return state.copyWith(recentGame: value);
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

  void signOut() => clearLocalDataSourceUsecase.call();
}
