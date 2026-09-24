import 'package:equatable/equatable.dart';

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

class NfcResult extends Equatable {
  final NfcNotice notice;
  final NfcResultKind kind;
  final TagEntity? tag;
  const NfcResult({required this.notice, required this.kind, this.tag});

  @override
  List<Object?> get props => [notice, kind, tag];
}
