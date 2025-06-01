import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/usecase/initialize_setting.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_setting.dart';

import '../route/route_constant.dart';
import '../widget/material/setting_constant.dart';

part 'application_state.dart';

class ApplicationCubit extends Cubit<ApplicationState> {
  final InitializeSettingUsecase initializeSettingUsecase;
  final UpdateSettingUsecase updateSettingUsecase;

  ApplicationCubit({
    required this.initializeSettingUsecase,
    required this.updateSettingUsecase,
  }) : super(ApplicationState.initialFromConstant());

  void safeEmit(ApplicationState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> initializeCubit() async {
    final updated = await initializeSettingUsecase.call(SettingConstant.all);

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
      case SettingConstant.keylocale:     return state.copyWith(locale: Locale(value));
      case SettingConstant.keyIsDark:     return state.copyWith(isDark: value);
      case SettingConstant.keyLoggedIn:   return state.copyWith(loggedIn: value);
      case SettingConstant.keyRecentId:   return state.copyWith(recentId: value);
      case SettingConstant.keyRecentGame: return state.copyWith(recentGame: value);
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
}
