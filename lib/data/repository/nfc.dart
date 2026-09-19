import 'package:nfc_manager/nfc_manager.dart';
import '../../domain/entity/card.dart';
import '../../domain/entity/tag.dart';
import '../../domain/entity/nfc_result.dart';
import '../../domain/repository/nfc.dart';
import '../../util/logger.dart';
part '../datasource/device/ndef_codec.dart';

class NfcRepositoryImpl implements NfcRepository {
  @override
  Future<bool> isAvailable() => NfcManager.instance.isAvailable();
  @override
  Future<void> start(
          {CardEntity? card, required void Function(NfcResult) onResult}) =>
      NfcManager.instance.startSession(onDiscovered: (tag) async {
        if (card == null) {
          await _processReadTag(tag: tag, onResult: onResult);
        } else {
          await _processWriteTag(tag: tag, card: card, onResult: onResult);
        }
      });
  @override
  Future<void> stop() => NfcManager.instance.stopSession();

  Future<void> _processReadTag({
    required NfcTag tag,
    required void Function(NfcResult) onResult,
  }) async {
    try {
      final ndef = validateNDEF(tag: tag);

      if (!hasNdefRecords(ndef)) {
        throw Exception('[Validation] No NDEF message found.');
      }

      final records = extractFormattedNdefRecords(ndef);
      final tagEntity = createTagEntity(tag: tag, records: records);

      onResult(NfcResult(
          notice: NfcNotice.successReadTag,
          kind: NfcResultKind.success,
          tag: tagEntity));

      LoggerUtil.d(
          '[Processing] Tag read successfully for card id[${tagEntity.cardId}]');
    } catch (e) {
      final message = e.toString();
      if (message.contains('Tag does not support NDEF')) {
        onResult(NfcResult(
            notice: NfcNotice.errorNdefNotSupported,
            kind: NfcResultKind.error));
      } else if (message.contains('No NDEF message found')) {
        onResult(NfcResult(
            notice: NfcNotice.errorNdefParseFailed, kind: NfcResultKind.error));
      } else if (message.contains('Incomplete tag data')) {
        onResult(NfcResult(
            notice: NfcNotice.errorTagCardNotFound, kind: NfcResultKind.error));
      } else {
        onResult(NfcResult(
            notice: NfcNotice.errorReadTag, kind: NfcResultKind.error));
      }

      LoggerUtil.e('[Processing] Error reading tag: $e');
    }
  }

  Future<void> _processWriteTag({
    required NfcTag tag,
    required CardEntity card,
    required void Function(NfcResult) onResult,
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
          LoggerUtil.e(
              '[Processing] Tag contains data in unknown or invalid format: $e');
        }
      }

      final message = createNDEFMessage(card: card);
      await ndef.write(message);

      if (!isDataOnTag) {
        onResult(NfcResult(
            notice: NfcNotice.successWriteTagNew, kind: NfcResultKind.success));
        LoggerUtil.d(
            '[Processing] Tag was empty. New data written successfully for card id[${card.cardId}].');
      } else if (!isAppFormat) {
        onResult(NfcResult(
            notice: NfcNotice.warningOverwriteUnknownFormat,
            kind: NfcResultKind.warning));
        LoggerUtil.d(
            '[Processing] Tag contained unknown format data. Overwritten successfully for card id[${card.cardId}].');
      } else if (isSameCard) {
        onResult(NfcResult(
            notice: NfcNotice.warningRewriteSameCard,
            kind: NfcResultKind.warning));
        LoggerUtil.d(
            '[Processing] Tag contained same card data. Rewritten successfully for card id[${card.cardId}].');
      } else {
        onResult(NfcResult(
            notice: NfcNotice.warningOverwriteDifferentCard,
            kind: NfcResultKind.success));
        LoggerUtil.d(
            '[Processing] Tag contained different card data. Overwritten successfully for card id[${card.cardId}].');
      }
    } catch (e) {
      final message = e.toString();

      if (message.contains('Tag does not support NDEF')) {
        onResult(NfcResult(
            notice: NfcNotice.errorNdefNotSupported,
            kind: NfcResultKind.error));
      } else if (message.contains('Tag is read-only')) {
        onResult(NfcResult(
            notice: NfcNotice.errorNdefNotWritable, kind: NfcResultKind.error));
      } else if (message.contains('Card data is incomplete')) {
        onResult(NfcResult(
            notice: NfcNotice.errorNdefCreateFailed,
            kind: NfcResultKind.error));
      } else if (message.contains('Data exceeds tag capacity')) {
        onResult(NfcResult(
            notice: NfcNotice.errorNdefDataTooLarge,
            kind: NfcResultKind.error));
      } else {
        onResult(NfcResult(
            notice: NfcNotice.errorWriteTag, kind: NfcResultKind.error));
      }

      LoggerUtil.e('[Processing] Error writing to tag: $e');
    }
  }
}
