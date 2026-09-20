import 'dart:async';
import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:nfc_deck_tracker/domain/entity/app_settings.dart';
import 'package:nfc_deck_tracker/domain/entity/session_user.dart';
import 'package:nfc_deck_tracker/domain/usecase/clear_user_data.dart';
import 'package:nfc_deck_tracker/domain/usecase/device.dart';
import 'package:nfc_deck_tracker/domain/usecase/init_setting.dart';
import 'package:nfc_deck_tracker/domain/usecase/session.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_setting.dart';
import 'package:nfc_deck_tracker/util/logger.dart';

import '../../route/constant.dart';
import '../error_reporting.dart';

part 'event.dart';
part 'state.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState>
    with ErrorReporting<ApplicationEvent, ApplicationState> {
  final ClearUserDataUsecase clearUserDataUsecase;
  final InitSettingUsecase initSettingUsecase;
  final UpdateSettingUsecase updateSettingUsecase;
  final SessionUsecase sessionUsecase;
  final DeviceUsecase deviceUsecase;
  StreamSubscription<SessionUser?>? _sessionSubscription;
  StreamSubscription<bool>? _connectivitySubscription;

  ApplicationBloc({
    required this.clearUserDataUsecase,
    required this.initSettingUsecase,
    required this.updateSettingUsecase,
    required this.sessionUsecase,
    required this.deviceUsecase,
  }) : super(const ApplicationState()) {
    on<InitApplicationEvent>(_onInitApplication);
    on<SessionChangedEvent>((event, emit) =>
        emit(state.copyWith(user: event.user, clearUser: event.user == null)));
    on<ConnectivityChangedEvent>(
        (event, emit) => emit(state.copyWith(isOnline: event.isOnline)));
    on<UpdateSettingsEvent>(_onUpdateSettings);
    on<SetPageIndexEvent>(_onSetPageIndex);
    on<ClearUserDataEvent>(_onClearUserData);
    on<DismissApplicationErrorEvent>(
        (_, emit) => emit(state.copyWith(errorMessage: '')));
  }

  Future<void> _onInitApplication(
    InitApplicationEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    _sessionSubscription ??= sessionUsecase
        .authStateChanges()
        .listen((user) => add(SessionChangedEvent(user)));
    _connectivitySubscription ??= deviceUsecase.connectivityChanges
        .listen((isOnline) => add(ConnectivityChangedEvent(isOnline)));

    await guard(emit, ErrorKeys.load, () async {
      final settings = await initSettingUsecase.call();
      emit(state.copyWith(
        settings: settings,
        user: sessionUsecase.currentUser,
        currentPageIndex: RouteConstant.on_boarding_index,
      ));
    });
  }

  @override
  Future<void> close() async {
    await _sessionSubscription?.cancel();
    await _connectivitySubscription?.cancel();
    return super.close();
  }

  Future<void> _onUpdateSettings(
    UpdateSettingsEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    await guard(emit, ErrorKeys.save, () async {
      final settings = event.change(state.settings);
      await updateSettingUsecase.call(settings);
      emit(state.copyWith(settings: settings));
    });
    LoggerUtil.flush();
  }

  void _onSetPageIndex(
    SetPageIndexEvent event,
    Emitter<ApplicationState> emit,
  ) {
    emit(state.copyWith(currentPageIndex: event.index));
  }

  Future<void> _onClearUserData(
    ClearUserDataEvent event,
    Emitter<ApplicationState> emit,
  ) async {
    await guard(emit, ErrorKeys.delete, () async {
      await clearUserDataUsecase.call(isGuest: state.settings.isGuest);
    });
  }

  String getPageRoute({required int index}) {
    return const <int, String>{
          0: RouteConstant.my_deck,
          1: RouteConstant.tag_reader,
          2: RouteConstant.setting,
        }[index] ??
        RouteConstant.not_found;
  }

  @override
  ApplicationState withError(ApplicationState state, String messageKey) =>
      state.copyWith(errorMessage: messageKey);
}
