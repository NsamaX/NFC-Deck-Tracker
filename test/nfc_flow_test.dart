import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/tag.dart';
import 'package:nfc_deck_tracker/domain/entity/nfc_result.dart';
import 'package:nfc_deck_tracker/domain/repository/nfc.dart';
import 'package:nfc_deck_tracker/domain/usecase/nfc_session.dart';
import 'package:nfc_deck_tracker/presentation/bloc/nfc/bloc.dart';
import 'package:nfc_deck_tracker/data/repository/nfc.dart';

class FakeNfcRepository implements NfcRepository {
  bool available = true;
  bool stopped = false;
  CardEntity? writeCard;
  void Function(NfcResult)? report;
  @override
  Future<bool> isAvailable() async => available;
  @override
  Future<void> start(
      {CardEntity? card, required void Function(NfcResult) onResult}) async {
    writeCard = card;
    report = onResult;
  }

  @override
  Future<void> stop() async => stopped = true;
}

void main() {
  test('NFC results reach presentation without a platform tag or NFC hardware',
      () async {
    final repository = FakeNfcRepository();
    final bloc = NfcBloc(session: NfcSessionUsecase(repository));
    addTearDown(bloc.close);
    final active = bloc.stream.firstWhere((state) => state.isSessionActive);
    bloc.add(const StartNfcSessionEvent());
    await active;
    const tag = TagEntity(tagId: '01:02', cardId: 'c', collectionId: 'game');
    final scanned =
        bloc.stream.firstWhere((state) => state.lastScannedTag != null);
    repository.report!(const NfcResult(
        notice: NfcNotice.successReadTag,
        kind: NfcResultKind.success,
        tag: tag));
    expect((await scanned).lastScannedTag, tag);
    expect(bloc.state.successMessage, 'nfc_snack_bar.success_read_tag');
    final stopped = bloc.stream.firstWhere((state) => !state.isSessionActive);
    bloc.add(const StopNfcSessionEvent());
    await stopped;
    expect(repository.stopped, isTrue);
  });

  test('write mode passes the selected card through the use case', () async {
    final repository = FakeNfcRepository();
    final bloc = NfcBloc(session: NfcSessionUsecase(repository));
    addTearDown(bloc.close);
    const card = CardEntity(cardId: 'c', collectionId: 'game');
    final active = bloc.stream.firstWhere((state) => state.isSessionActive);
    bloc.add(const StartNfcSessionEvent(card: card));
    await active;
    expect(repository.writeCard, card);
    final warning =
        bloc.stream.firstWhere((state) => state.warningMessage.isNotEmpty);
    repository.report!(const NfcResult(
        notice: NfcNotice.warningRewriteSameCard, kind: NfcResultKind.warning));
    expect((await warning).warningMessage,
        'nfc_snack_bar.warning_rewrite_same_card');
  });

  test('an emulator without NFC finishes startup with an error state',
      () async {
    final repository = FakeNfcRepository()..available = false;
    final bloc = NfcBloc(session: NfcSessionUsecase(repository));
    addTearDown(bloc.close);
    final failed = bloc.stream.firstWhere(
        (state) => !state.isSessionBusy && state.errorMessage.isNotEmpty);
    bloc.add(const StartNfcSessionEvent());
    expect((await failed).isSessionActive, isFalse);
    expect(repository.report, isNull);
  });

  test('NDEF adapter retains the existing coId/caId wire format', () {
    final message = createNDEFMessage(
        card: const CardEntity(collectionId: 'game', cardId: 'card'),
        maxSize: 144);
    expect(
        message.records
            .map((record) => String.fromCharCodes(record.payload).substring(3)),
        ['coId: game', 'caId: card']);
    expect(
        message.records.map(decodeTextPayload), ['coId: game', 'caId: card']);
  });
  test('NDEF adapter reports incomplete and oversized data as typed notices',
      () {
    Matcher failsWith(NfcNotice notice) =>
        throwsA(isA<NdefFailure>().having((e) => e.notice, 'notice', notice));
    expect(() => createNDEFMessage(card: const CardEntity(), maxSize: 144),
        failsWith(NfcNotice.errorNdefCreateFailed));
    final long = CardEntity(collectionId: 'game', cardId: 'x' * 200);
    expect(() => createNDEFMessage(card: long, maxSize: 144),
        failsWith(NfcNotice.errorNdefDataTooLarge));
    expect(createNDEFMessage(card: long, maxSize: 504).records, hasLength(2));
  });
  test('tag id is read from whichever technology reports an identifier', () {
    NfcTag tagWith(Map<String, dynamic> data) =>
        NfcTag(handle: 'h', data: data);
    expect(
        tagIdentifier(tagWith({
          'nfca': {
            'identifier': [1, 171]
          }
        })),
        '01:ab');
    expect(
        tagIdentifier(tagWith({
          'mifare': {
            'identifier': [255]
          }
        })),
        'ff');
    expect(tagIdentifier(tagWith({})), isEmpty);
  });
  test('a read-only tag is readable but rejected for writing', () {
    final written = createNDEFMessage(
        card: const CardEntity(collectionId: 'game', cardId: 'card'),
        maxSize: 144);
    final tag = NfcTag(handle: 'h', data: {
      'nfca': {
        'identifier': [1, 2]
      },
      'ndef': {
        'isWritable': false,
        'maxSize': 144,
        'cachedMessage': {
          'records': [
            for (final r in written.records)
              {
                'typeNameFormat': 1,
                'type': r.type,
                'identifier': r.identifier,
                'payload': r.payload,
              }
          ]
        },
      },
    });

    final ndef = validateNDEF(tag: tag);
    expect(
        createTagEntity(tag: tag, records: extractFormattedNdefRecords(ndef)),
        const TagEntity(tagId: '01:02', cardId: 'card', collectionId: 'game'));
    expect(
        () => validateNDEF(tag: tag, requireWritable: true),
        throwsA(isA<NdefFailure>().having(
            (e) => e.notice, 'notice', NfcNotice.errorNdefNotWritable)));
  });
}
