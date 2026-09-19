import 'tag.dart';

enum NfcNotice {
  errorNdefCreateFailed,
  errorNdefDataTooLarge,
  errorNdefNotSupported,
  errorNdefNotWritable,
  errorNdefParseFailed,
  errorReadTag,
  errorRestartSession,
  errorStartSession,
  errorTagCardNotFound,
  errorUnavailable,
  errorWriteTag,
  successReadTag,
  successWriteTagNew,
  warningOverwriteDifferentCard,
  warningOverwriteUnknownFormat,
  warningRewriteSameCard,
}

enum NfcResultKind { success, warning, error }

class NfcResult {
  final NfcNotice notice;
  final NfcResultKind kind;
  final TagEntity? tag;
  const NfcResult({required this.notice, required this.kind, this.tag});
}
