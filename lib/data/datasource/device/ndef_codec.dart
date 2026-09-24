part of '../../repository/nfc.dart';

class NdefFailure implements Exception {
  final NfcNotice notice;

  const NdefFailure(this.notice);

  @override
  String toString() => 'NdefFailure: ${notice.name}';
}

Ndef validateNDEF({
  required NfcTag tag,
  bool requireWritable = false,
}) {
  final ndef = Ndef.from(tag);
  if (ndef == null) {
    throw const NdefFailure(NfcNotice.errorNdefNotSupported);
  }
  if (requireWritable && !ndef.isWritable) {
    throw const NdefFailure(NfcNotice.errorNdefNotWritable);
  }
  return ndef;
}

bool hasNdefRecords(Ndef ndef) {
  final message = ndef.cachedMessage;
  return message != null && message.records.isNotEmpty;
}

List<String> extractFormattedNdefRecords(Ndef ndef) {
  final message = ndef.cachedMessage;
  if (message == null || message.records.isEmpty) {
    throw const NdefFailure(NfcNotice.errorNdefParseFailed);
  }
  return message.records.map(decodeTextPayload).whereType<String>().toList();
}

String? decodeTextPayload(NdefRecord record) {
  final payload = record.payload;
  if (payload.isEmpty || payload[0] & 0x80 != 0) return null;
  final languageLength = payload[0] & 0x3F;
  if (payload.length < 1 + languageLength) return null;
  try {
    return utf8.decode(payload.sublist(1 + languageLength));
  } on FormatException {
    return null;
  }
}

String tagIdentifier(NfcTag tag) {
  for (final tech in tag.data.values) {
    final identifier = tech is Map ? tech['identifier'] : null;
    if (identifier is List && identifier.isNotEmpty) {
      return identifier
          .map((e) => (e as int).toRadixString(16).padLeft(2, '0'))
          .join(':');
    }
  }
  return '';
}

TagEntity createTagEntity({
  required NfcTag tag,
  required List<String> records,
}) {
  String field(String prefix) => records
      .firstWhere((r) => r.startsWith(prefix), orElse: () => '')
      .split(': ')
      .last;

  final collectionId = field('coId:');
  final cardId = field('caId:');
  final tagId = tagIdentifier(tag);

  if (collectionId.isEmpty || cardId.isEmpty || tagId.isEmpty) {
    throw const NdefFailure(NfcNotice.errorTagCardNotFound);
  }

  return TagEntity(tagId: tagId, cardId: cardId, collectionId: collectionId);
}

NdefMessage createNDEFMessage({
  required CardEntity card,
  required int maxSize,
}) {
  if (card.collectionId.isEmpty || card.cardId.isEmpty) {
    throw const NdefFailure(NfcNotice.errorNdefCreateFailed);
  }

  final message = NdefMessage([
    NdefRecord.createText('coId: ${card.collectionId}'),
    NdefRecord.createText('caId: ${card.cardId}'),
  ]);

  if (message.byteLength > maxSize) {
    throw const NdefFailure(NfcNotice.errorNdefDataTooLarge);
  }

  return message;
}
