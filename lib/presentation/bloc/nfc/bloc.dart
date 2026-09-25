import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entity/nfc_result.dart';
import '../../../domain/usecase/nfc_session.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/tag.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

part 'event.dart';

part 'state.dart';

class NfcBloc extends Bloc<NfcEvent, NfcState> {
  final NfcSessionUsecase session;

  NfcBloc({required this.session}) : super(const NfcState()) {
    on<StartNfcSessionEvent>(_onStartSession);
    on<StopNfcSessionEvent>(_onStopSession);
    on<RestartNfcSessionEvent>(_onRestartSession);
    on<NfcResultEvent>(_onResult);
    on<ClearNFCMessagesEvent>(_onClearNFCMessages);
  }

  Future<void> _onStartSession(
      StartNfcSessionEvent event, Emitter<NfcState> emit) async {
    if (state.isSessionBusy) return;
    emit(state.copyWith(
      isSessionBusy: true,
      successMessage: '',
      warningMessage: '',
      errorMessage: '',
    ));
    await _start(event.card, emit,
        failureKey: 'nfc_snack_bar.error_start_session');
    emit(state.copyWith(isSessionBusy: false));
  }

  Future<void> _onStopSession(
      StopNfcSessionEvent event, Emitter<NfcState> emit) async {
    try {
      await session.stop();
      LoggerUtil.d(
          '[Session Control] NFC session stopped. Reason: ${event.reason}');
    } catch (e) {
      LoggerUtil.e('[Session Control] Error stopping session: $e');
    }
    emit(state.copyWith(isSessionActive: false, isSessionBusy: false));
  }

  Future<void> _onRestartSession(
      RestartNfcSessionEvent event, Emitter<NfcState> emit) async {
    if (state.isSessionBusy || !state.isSessionActive) return;
    emit(state.copyWith(
      isSessionBusy: true,
      successMessage: '',
      warningMessage: '',
      errorMessage: '',
    ));
    try {
      await session.stop();
    } catch (e) {
      LoggerUtil.e('[Error Recovery] Error stopping session: $e');
    }
    emit(state.copyWith(isSessionActive: false));
    await _start(event.card, emit,
        failureKey: 'nfc_snack_bar.error_restart_session');
    emit(state.copyWith(isSessionBusy: false));
  }

  Future<void> _start(
    CardEntity? card,
    Emitter<NfcState> emit, {
    required String failureKey,
  }) async {
    LoggerUtil.d(
        '[Session Control] Starting NFC session: ${card == null ? "Read" : "Write"} mode');
    try {
      if (!await session.isAvailable()) {
        emit(state.copyWith(errorMessage: 'nfc_snack_bar.error_unavailable'));
        return;
      }
      await session.start(
          card: card,
          onResult: (result) {
            if (!isClosed) add(NfcResultEvent(result));
          });
      emit(state.copyWith(isSessionActive: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: failureKey));
      LoggerUtil.e('[Session Control] Error starting NFC session: $e');
    }
  }

  void _onResult(NfcResultEvent event, Emitter<NfcState> emit) {
    final result = event.result;
    final key = _noticeKeys[result.notice]!;
    emit(state.copyWith(
      lastScannedTag: result.tag,
      successMessage: result.kind == NfcResultKind.success ? key : null,
      warningMessage: result.kind == NfcResultKind.warning ? key : null,
      errorMessage: result.kind == NfcResultKind.error ? key : null,
    ));
  }

  void _onClearNFCMessages(
      ClearNFCMessagesEvent event, Emitter<NfcState> emit) {
    emit(state.copyWith(
        successMessage: '', warningMessage: '', errorMessage: ''));
  }
}

const _noticeKeys = {
  NfcNotice.errorNdefCreateFailed: 'nfc_snack_bar.error_ndef_create_failed',
  NfcNotice.errorNdefDataTooLarge: 'nfc_snack_bar.error_ndef_data_too_large',
  NfcNotice.errorNdefNotSupported: 'nfc_snack_bar.error_ndef_not_supported',
  NfcNotice.errorNdefNotWritable: 'nfc_snack_bar.error_ndef_not_writable',
  NfcNotice.errorNdefParseFailed: 'nfc_snack_bar.error_ndef_parse_failed',
  NfcNotice.errorReadTag: 'nfc_snack_bar.error_read_tag',
  NfcNotice.errorRestartSession: 'nfc_snack_bar.error_restart_session',
  NfcNotice.errorStartSession: 'nfc_snack_bar.error_start_session',
  NfcNotice.errorTagCardNotFound: 'nfc_snack_bar.error_no_data',
  NfcNotice.errorUnavailable: 'nfc_snack_bar.error_unavailable',
  NfcNotice.errorWriteTag: 'nfc_snack_bar.error_write_tag',
  NfcNotice.successReadTag: 'nfc_snack_bar.success_read_tag',
  NfcNotice.successWriteTagNew: 'nfc_snack_bar.success_write_tag_new',
  NfcNotice.warningOverwriteDifferentCard:
      'nfc_snack_bar.warning_overwrite_different_card',
  NfcNotice.warningOverwriteUnknownFormat:
      'nfc_snack_bar.warning_overwrite_unknown_format',
  NfcNotice.warningRewriteSameCard: 'nfc_snack_bar.warning_rewrite_same_card',
};
