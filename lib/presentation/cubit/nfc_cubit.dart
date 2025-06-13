import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/tag.dart';

import 'package:nfc_deck_tracker/util/logger.dart';

part 'nfc_helper.dart';
part 'nfc_state.dart';

class NfcCubit extends Cubit<NfcState> {
  NfcCubit() : super(const NfcState());

  void safeEmit(NfcState newState) {
    if (!isClosed) emit(newState);
  }

  Future<void> startSession({
    CardEntity? card,
  }) async {
    if (state.isSessionBusy) return;
    safeEmit(state.copyWith(
      isSessionBusy: true,
      successMessage: '',
      warningMessage: '',
      errorMessage: '',
    ));
    LoggerUtil.addMessage(message: '[Session Control] Starting NFC session: ${card == null ? "Read" : "Write"} mode');
    LoggerUtil.flushMessages();

    try {
      if (!await NfcManager.instance.isAvailable()) {
        safeEmit(state.copyWith(errorMessage: 'nfc_snack_bar.error_unavailable'));
        throw Exception('NFC is not available.');
      }

      await NfcManager.instance.startSession(onDiscovered: (tag) async {
        try {
          if (card == null) {
            await _processReadTag(tag: tag);
          } else {
            await _processWriteTag(tag: tag, card: card);
          }
        } catch (e) {
          safeEmit(state.copyWith(errorMessage: 'nfc_snack_bar.error_process_tag'));
          LoggerUtil.addMessage(message: '[Session Control] Error during tag processing: $e');
          LoggerUtil.flushMessages(isError: true);
        }
      });

      safeEmit(state.copyWith(isSessionActive: true));
    } catch (e) {
      safeEmit(state.copyWith(errorMessage: 'nfc_snack_bar.error_start_session'));
      LoggerUtil.addMessage(message: '[Session Control] Error initializing NFC session: $e');
      LoggerUtil.flushMessages(isError: true);
    } finally {
      safeEmit(state.copyWith(isSessionBusy: false));
    }
  }

  Future<void> restartSession({
    CardEntity? card,
    bool isCardChanged = false,
  }) async {
    if (state.isSessionBusy) return;
    safeEmit(state.copyWith(isSessionBusy: true));
    clearMessages();

    if (state.isSessionActive) {
      try {
        if (isCardChanged) {
          LoggerUtil.addMessage(message: '[Error Recovery] Card changed. Restarting NFC session...');
          await stopSession(reason: 'Card changed, restarting session...');
        }
        await startSession(card: card);
      } catch (e) {
        safeEmit(state.copyWith(errorMessage: 'nfc_snack_bar.error_restart_session'));
        LoggerUtil.addMessage(message: '[Error Recovery] Failed to restart NFC session: ${e.toString()}');
        LoggerUtil.flushMessages(isError: true);
      }
    }
  }

  Future<void> stopSession({
    String reason = 'User stopped NFC session',
  }) async {
    try {
      await NfcManager.instance.stopSession();
      safeEmit(state.copyWith(
        isSessionActive: false,
        isSessionBusy: false,
      ));
      LoggerUtil.addMessage(message: '[Session Control] NFC session stopped. Reason: $reason');
      LoggerUtil.flushMessages();
    } catch (e) {
      LoggerUtil.addMessage(message: '[Session Control] Error stopping session: $e');
      LoggerUtil.flushMessages(isError: true);
      safeEmit(state.copyWith(isSessionBusy: false));
    }
  }

  Future<void> _processReadTag({
    required NfcTag tag,
  }) async {
    try {
      final Ndef ndef = validateNDEF(tag: tag);
      final List<String> records = parseNDEFRecords(ndef: ndef);
      final TagEntity tagEntity = createTagEntity(tag: tag, records: records);
      safeEmit(state.copyWith(
        lastScannedTag: tagEntity,
        successMessage: 'nfc_snack_bar.success_read_tag',
      ));
      LoggerUtil.addMessage(message: '[Processing] Tag read successfully for card id[${tagEntity.cardId}]');
      LoggerUtil.flushMessages();
    } catch (e) {
      final message = e.toString();

      if (message.contains('Tag does not support NDEF')) {
        safeEmit(state.copyWith(errorMessage: 'nfc_snack_bar.error_ndef_not_supported'));
      } else if (message.contains('No NDEF message found')) {
        safeEmit(state.copyWith(errorMessage: 'nfc_snack_bar.error_ndef_parse_failed'));
      } else if (message.contains('Incomplete tag data')) {
        safeEmit(state.copyWith(errorMessage: 'nfc_snack_bar.error_tag_card_not_found'));
      } else {
        safeEmit(state.copyWith(errorMessage: 'nfc_snack_bar.error_read_tag'));
      }

      LoggerUtil.addMessage(message: '[Processing] Error reading tag: $e');
      LoggerUtil.flushMessages(isError: true);
    }
  }

  Future<void> _processWriteTag({
    required NfcTag tag,
    required CardEntity card,
  }) async {
    try {
      final Ndef ndef = validateNDEF(tag: tag);
      final List<String> records = parseNDEFRecords(ndef: ndef);
      final TagEntity tagEntity = createTagEntity(tag: tag, records: records);
      final bool isSameData = tagEntity.collectionId == card.collectionId && tagEntity.cardId == card.cardId;

      final NdefMessage message = createNDEFMessage(card: card);
      await ndef.write(message);

      if (isSameData) {
        safeEmit(state.copyWith(warningMessage: 'nfc_snack_bar.warning_rewrite_card'));
      } else {      
        safeEmit(state.copyWith(successMessage: 'nfc_snack_bar.success_write_tag'));
      }

      LoggerUtil.addMessage(message: '[Processing] Tag written successfully for card id[${card.cardId}]');
      LoggerUtil.flushMessages();
    } catch (e) {
      final message = e.toString();

      if (message.contains('Tag does not support NDEF')) {
        safeEmit(state.copyWith(errorMessage: 'nfc_snack_bar.error_ndef_not_supported'));
      } else if (message.contains('Tag is read-only')) {
        safeEmit(state.copyWith(errorMessage: 'nfc_snack_bar.error_ndef_not_writable'));
      } else if (message.contains('Card data is incomplete')) {
        safeEmit(state.copyWith(errorMessage: 'nfc_snack_bar.error_ndef_create_failed'));
      } else if (message.contains('Data exceeds tag capacity')) {
        safeEmit(state.copyWith(errorMessage: 'nfc_snack_bar.error_ndef_data_too_large'));
      } else if (message.contains('No NDEF message found') || message.contains('Incomplete tag data')) {
      } else {
        safeEmit(state.copyWith(errorMessage: 'nfc_snack_bar.error_write_tag'));
      }

      LoggerUtil.addMessage(message: '[Processing] Error writing to tag: $e');
      LoggerUtil.flushMessages(isError: true);
    }
  }

  void clearMessages() => safeEmit(state.copyWith(successMessage: '', warningMessage: '', errorMessage: ''));
}
