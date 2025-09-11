import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/.config/app.dart';

import 'package:nfc_deck_tracker/domain/usecase/clear_user_data.dart';
import 'package:nfc_deck_tracker/domain/usecase/init_setting.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_setting.dart';
import 'package:nfc_deck_tracker/util/logger.dart';

import '../../route/constant.dart';

part 'event.dart';
part 'state.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  final ClearUserDataUsecase clearUserDataUsecase;
  final InitSettingUsecase initSettingUsecase;
  final UpdateSettingUsecase updateSettingUsecase;

  ApplicationBloc({
    required this.clearUserDataUsecase,
    required this.initSettingUsecase,
    required this.updateSettingUsecase,
  }) : super(ApplicationState.initial()) {
    on<InitApplicationEvent>(_onInitApplication);
    on<UpdateSettingEvent>(_onUpdateSetting);
    on<SetPageIndexEvent>(_onSetPageIndex);
    on<ClearUserDataEvent>(_onClearUserData);
  }

  Future<void> _onInitApplication(
    InitApplicationEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    final updated = await initSettingUsecase.call(AppConfig.defaults);

    ApplicationState newState = state;

    for (final entry in updated.entries) {
      newState = _mapUpdatedState(newState, entry.key, entry.value);
    }

    emit(newState.copyWith(currentPageIndex: RouteConstant.on_boarding_index));
  }

  Future<void> _onUpdateSetting(
    UpdateSettingEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    await updateSettingUsecase.call(key: event.key, value: event.value);
    emit(_mapUpdatedState(state, event.key, event.value));
    LoggerUtil.flush();
  }

  void _onSetPageIndex(
    SetPageIndexEvent event,
    Emitter<ApplicationState> emit,
  ) {
    emit(state.copyWith(currentPageIndex: event.index));
  }

  void _onClearUserData(
    ClearUserDataEvent event,
    Emitter<ApplicationState> emit,
  ) {
    clearUserDataUsecase.call(isGuest: state.guestId != null);
  }

  ApplicationState _mapUpdatedState(ApplicationState state, String key, dynamic value) {
    switch (key) {
      case AppConfig.keyLocale:
        return state.copyWith(locale: Locale(value));
      case AppConfig.keyIsDark:
        return state.copyWith(isDark: value);
      case AppConfig.keyGuestId:
        return state.copyWith(guestId: value);
      case AppConfig.keyRecentId:
        return state.copyWith(recentId: value);
      case AppConfig.keyRecentGame:
        return state.copyWith(recentGame: value);
      case AppConfig.keyTutorial:
        return state.copyWith(tutorialNfcIcon: value);
      default:
        return state;
    }
  }

  String getPageRoute({required int index}) {
    return const <int, String>{
      0: RouteConstant.my_deck,
      1: RouteConstant.tag_reader,
      2: RouteConstant.setting,
    }[index] ?? RouteConstant.not_found;
  }
}
