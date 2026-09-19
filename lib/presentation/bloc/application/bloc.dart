import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/app_settings.dart';
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
  }) : super(const ApplicationState()) {
    on<InitApplicationEvent>(_onInitApplication);
    on<UpdateSettingsEvent>(_onUpdateSettings);
    on<SetPageIndexEvent>(_onSetPageIndex);
    on<ClearUserDataEvent>(_onClearUserData);
  }

  Future<void> _onInitApplication(
    InitApplicationEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    final settings = await initSettingUsecase.call();
    emit(state.copyWith(
      settings: settings,
      currentPageIndex: RouteConstant.on_boarding_index,
    ));
  }

  Future<void> _onUpdateSettings(
    UpdateSettingsEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    final settings = event.change(state.settings);
    await updateSettingUsecase.call(settings);
    emit(state.copyWith(settings: settings));
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
    clearUserDataUsecase.call(isGuest: state.settings.isGuest);
  }

  String getPageRoute({required int index}) {
    return const <int, String>{
          0: RouteConstant.my_deck,
          1: RouteConstant.tag_reader,
          2: RouteConstant.setting,
        }[index] ??
        RouteConstant.not_found;
  }
}
