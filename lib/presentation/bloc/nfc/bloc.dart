import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/tag.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

part 'event.dart';
part 'helper.dart';
part 'state.dart';

class NfcBloc extends Bloc<NfcEvent, NfcState> {
  NfcBloc() : super(const NfcState()) {
    on<StartNfcSessionEvent>(_onStartSession);
    on<StopNfcSessionEvent>(_onStopSession);
    on<RestartNfcSessionEvent>(_onRestartSession);
    on<ProcessReadTagEvent>(_onProcessReadTag);
    on<ProcessWriteTagEvent>(_onProcessWriteTag);
    on<ClearNFCMessagesEvent>(_onClearNFCMessages);
  }

  Future<void> _onStartSession(StartNfcSessionEvent event, Emitter<NfcState> emit) async {
    if (state.isSessionBusy) return;
    emit(state.copyWith(
      isSessionBusy: true,
      successMessage: '',
      warningMessage: '',
      errorMessage: '',
    ));

    LoggerUtil.d('[Session Control] Starting NFC session: ${event.card == null ? "Read" : "Write"} mode');

    try {
      final isAvailable = await NfcManager.instance.isAvailable();
      if (!isAvailable) {
        emit(state.copyWith(errorMessage: 'nfc_snack_bar.error_unavailable'));
        throw Exception('NFC is not available.');
      }

      await NfcManager.instance.startSession(onDiscovered: (tag) async {
        try {
          if (event.card == null) {
            add(ProcessReadTagEvent(tag: tag));
          } else {
            add(ProcessWriteTagEvent(tag: tag, card: event.card!));
          }
        } catch (e) {
          LoggerUtil.e('[Session Control] Error dispatching process tag event: $e');
        }
      });

      emit(state.copyWith(isSessionActive: true));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'nfc_snack_bar.error_start_session'));
      LoggerUtil.e('[Session Control] Error initializing NFC session: $e');
    } finally {
      emit(state.copyWith(isSessionBusy: false));
    }
  }

  Future<void> _onStopSession(StopNfcSessionEvent event, Emitter<NfcState> emit) async {
    try {
      await NfcManager.instance.stopSession();
      emit(state.copyWith(isSessionActive: false, isSessionBusy: false));
      LoggerUtil.d('[Session Control] NFC session stopped. Reason: ${event.reason}');
    } catch (e) {
      LoggerUtil.e('[Session Control] Error stopping session: $e');
      emit(state.copyWith(isSessionBusy: false));
    }
  }

  Future<void> _onRestartSession(RestartNfcSessionEvent event, Emitter<NfcState> emit) async {
    if (state.isSessionBusy) return;
    emit(state.copyWith(isSessionBusy: true));
    emit(state.copyWith(successMessage: '', warningMessage: '', errorMessage: ''));

    if (state.isSessionActive) {
      try {
        if (event.isCardChanged) {
          LoggerUtil.d('[Error Recovery] Card changed. Restarting NFC session...');
          add(StopNfcSessionEvent(reason: 'Card changed, restarting session...'));
        }
        add(StartNfcSessionEvent(card: event.card));
      } catch (e) {
        emit(state.copyWith(errorMessage: 'nfc_snack_bar.error_restart_session'));
        LoggerUtil.e('[Error Recovery] Failed to restart NFC session: $e');
      }
    }
  }

  Future<void> _onProcessReadTag(ProcessReadTagEvent event, Emitter<NfcState> emit) async {
    await _processReadTag(tag: event.tag, emit: emit);
  }

  Future<void> _onProcessWriteTag(ProcessWriteTagEvent event, Emitter<NfcState> emit) async {
    await _processWriteTag(tag: event.tag, card: event.card, emit: emit);
  }

  Future<void> _processReadTag({
    required NfcTag tag,
    required Emitter<NfcState> emit,
  }) async {
    try {
      final ndef = validateNDEF(tag: tag);

      if (!hasNdefRecords(ndef)) {
        throw Exception('[Validation] No NDEF message found.');
      }

      final records = extractFormattedNdefRecords(ndef);
      final tagEntity = createTagEntity(tag: tag, records: records);

      emit(state.copyWith(
        lastScannedTag: tagEntity,
        successMessage: 'nfc_snack_bar.success_read_tag',
      ));

      LoggerUtil.d('[Processing] Tag read successfully for card id[${tagEntity.cardId}]');
    } catch (e) {
      final message = e.toString();
      if (message.contains('Tag does not support NDEF')) {
        emit(state.copyWith(errorMessage: 'nfc_snack_bar.error_ndef_not_supported'));
      } else if (message.contains('No NDEF message found')) {
        emit(state.copyWith(errorMessage: 'nfc_snack_bar.error_ndef_parse_failed'));
      } else if (message.contains('Incomplete tag data')) {
        emit(state.copyWith(errorMessage: 'nfc_snack_bar.error_tag_card_not_found'));
      } else {
        emit(state.copyWith(errorMessage: 'nfc_snack_bar.error_read_tag'));
      }

      LoggerUtil.e('[Processing] Error reading tag: $e');
    }
  }

Future<void> _processWriteTag({
    required NfcTag tag,
    required CardEntity card,
    required Emitter<NfcState> emit,
  }) async {
    try {
      final ndef = validateNDEF(tag: tag);

      bool isDataOnTag = hasNdefRecords(ndef);
      bool isAppFormat = false;
      bool isSameCard = false;

      TagEntity? existingTagEntity;

      if (isDataOnTag) {
        try {
          final records = extractFormattedNdefRecords(ndef);
          existingTagEntity = createTagEntity(tag: tag, records: records);
          isAppFormat = true;

          if (existingTagEntity.collectionId == card.collectionId &&
              existingTagEntity.cardId == card.cardId) {
            isSameCard = true;
          }
        } catch (e) {
          isAppFormat = false;
          LoggerUtil.e('[Processing] Tag contains data in unknown or invalid format: $e');
        }
      }

      final message = createNDEFMessage(card: card);
      await ndef.write(message);

      if (!isDataOnTag) {
        emit(state.copyWith(successMessage: 'nfc_snack_bar.success_write_tag_new'));
        LoggerUtil.d('[Processing] Tag was empty. New data written successfully for card id[${card.cardId}].');
      } else if (!isAppFormat) {
        emit(state.copyWith(warningMessage: 'nfc_snack_bar.warning_overwrite_unknown_format'));
        LoggerUtil.d('[Processing] Tag contained unknown format data. Overwritten successfully for card id[${card.cardId}].');
      } else if (isSameCard) {
        emit(state.copyWith(warningMessage: 'nfc_snack_bar.warning_rewrite_same_card'));
        LoggerUtil.d('[Processing] Tag contained same card data. Rewritten successfully for card id[${card.cardId}].');
      } else {
        emit(state.copyWith(successMessage: 'nfc_snack_bar.warning_overwrite_different_card'));
        LoggerUtil.d('[Processing] Tag contained different card data. Overwritten successfully for card id[${card.cardId}].');
      }
    } catch (e) {
      final message = e.toString();

      if (message.contains('Tag does not support NDEF')) {
        emit(state.copyWith(errorMessage: 'nfc_snack_bar.error_ndef_not_supported'));
      } else if (message.contains('Tag is read-only')) {
        emit(state.copyWith(errorMessage: 'nfc_snack_bar.error_ndef_not_writable'));
      } else if (message.contains('Card data is incomplete')) {
        emit(state.copyWith(errorMessage: 'nfc_snack_bar.error_ndef_create_failed'));
      } else if (message.contains('Data exceeds tag capacity')) {
        emit(state.copyWith(errorMessage: 'nfc_snack_bar.error_ndef_data_too_large'));
      } else {
        emit(state.copyWith(errorMessage: 'nfc_snack_bar.error_write_tag'));
      }

      LoggerUtil.e('[Processing] Error writing to tag: $e');
    }
  }

  void _onClearNFCMessages(ClearNFCMessagesEvent event, Emitter<NfcState> emit) {
    emit(state.copyWith(successMessage: '', warningMessage: '', errorMessage: ''));
  }
}
