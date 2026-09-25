import 'dart:convert';

import 'package:nfc_manager/nfc_manager.dart';
import '../../domain/entity/card.dart';
import '../../domain/entity/tag.dart';
import '../../domain/entity/nfc_result.dart';
import '../../domain/repository/nfc.dart';
import '../../util/logger.dart';
part '../datasource/device/ndef_codec.dart';

class NfcRepositoryImpl implements NfcRepository {
  // NTAG stickers are ISO 14443; FeliCa (ISO 18092) would need system codes
  // in the iOS Info.plist, and tracking needs the iOS session to stay open.
  static const pollingOptions = {
    NfcPollingOption.iso14443,
    NfcPollingOption.iso15693,
  };

  @override
  Future<bool> isAvailable() => NfcManager.instance.isAvailable();
  @override
  Future<void> start(
          {CardEntity? card, required void Function(NfcResult) onResult}) =>
      NfcManager.instance.startSession(
        pollingOptions: pollingOptions,
        invalidateAfterFirstRead: false,
        onDiscovered: (tag) async {
          if (card == null) {
            await _processReadTag(tag: tag, onResult: onResult);
          } else {
            await _processWriteTag(tag: tag, card: card, onResult: onResult);
          }
        },
      );
  @override
  Future<void> stop() => NfcManager.instance.stopSession();

  Future<void> _processReadTag({
    required NfcTag tag,
    required void Function(NfcResult) onResult,
  }) async {
    try {
      final ndef = validateNDEF(tag: tag);
      final records = extractFormattedNdefRecords(ndef);
      final tagEntity = createTagEntity(tag: tag, records: records);

      onResult(NfcResult(
          notice: NfcNotice.successReadTag,
          kind: NfcResultKind.success,
          tag: tagEntity));
      LoggerUtil.d('[NFC] Read card id[${tagEntity.cardId}]');
    } on NdefFailure catch (e) {
      onResult(NfcResult(notice: e.notice, kind: NfcResultKind.error));
      LoggerUtil.e('[NFC] Read rejected: $e');
    } catch (e) {
      onResult(const NfcResult(
          notice: NfcNotice.errorReadTag, kind: NfcResultKind.error));
      LoggerUtil.e('[NFC] Read failed: $e');
    }
  }

  Future<void> _processWriteTag({
    required NfcTag tag,
    required CardEntity card,
    required void Function(NfcResult) onResult,
  }) async {
    try {
      final ndef = validateNDEF(tag: tag, requireWritable: true);
      final message = createNDEFMessage(card: card, maxSize: ndef.maxSize);

      final hadData = hasNdefRecords(ndef);
      TagEntity? existing;
      if (hadData) {
        try {
          existing = createTagEntity(
              tag: tag, records: extractFormattedNdefRecords(ndef));
        } on NdefFailure {
          existing = null;
        }
      }

      await ndef.write(message);

      final NfcResult result;
      if (!hadData) {
        result = const NfcResult(
            notice: NfcNotice.successWriteTagNew, kind: NfcResultKind.success);
      } else if (existing == null) {
        result = const NfcResult(
            notice: NfcNotice.warningOverwriteUnknownFormat,
            kind: NfcResultKind.warning);
      } else if (existing.collectionId == card.collectionId &&
          existing.cardId == card.cardId) {
        result = const NfcResult(
            notice: NfcNotice.warningRewriteSameCard,
            kind: NfcResultKind.warning);
      } else {
        result = const NfcResult(
            notice: NfcNotice.warningOverwriteDifferentCard,
            kind: NfcResultKind.success);
      }
      onResult(result);
      LoggerUtil.d(
          '[NFC] Wrote card id[${card.cardId}]: ${result.notice.name}');
    } on NdefFailure catch (e) {
      onResult(NfcResult(notice: e.notice, kind: NfcResultKind.error));
      LoggerUtil.e('[NFC] Write rejected: $e');
    } catch (e) {
      onResult(const NfcResult(
          notice: NfcNotice.errorWriteTag, kind: NfcResultKind.error));
      LoggerUtil.e('[NFC] Write failed: $e');
    }
  }
}
