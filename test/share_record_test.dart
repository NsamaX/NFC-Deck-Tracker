import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/firestore_service.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/record.dart';
import 'package:nfc_deck_tracker/data/model/card.dart';
import 'package:nfc_deck_tracker/data/model/data.dart';
import 'package:nfc_deck_tracker/data/model/share_record.dart';
import 'package:nfc_deck_tracker/domain/value/player_action.dart';

class DocumentStore extends FirestoreService {
  final docs = <String, Map<String, dynamic>>{};
  DocumentStore() : super.offline();

  String _key(String collectionPath, String documentId) {
    if (collectionPath.split('/').length.isEven) {
      throw ArgumentError('"$collectionPath" is not a collection path');
    }
    return '$collectionPath/$documentId';
  }

  @override
  Future<bool> insert({
    required String collectionPath,
    required String documentId,
    required Map<String, dynamic> data,
    bool merge = true,
  }) async {
    docs[_key(collectionPath, documentId)] = data;
    return true;
  }

  @override
  Future<Map<String, dynamic>?> getDocument({
    required String collectionPath,
    required String documentId,
  }) async =>
      docs[_key(collectionPath, documentId)];
}

void main() {
  test('a shared record is stored at a valid path and imported back', () async {
    final store = DocumentStore();
    final records = RecordRemoteDatasource(store);
    final shared = ShareRecordModel(
      cards: [
        CardModel(
            collectionId: 'magic',
            cardId: 'c1',
            name: 'Katana',
            isSynced: true,
            updatedAt: DateTime(2026)),
      ],
      data: [
        DataModel(
            tagId: 't1',
            collectionId: 'magic',
            cardId: 'c1',
            location: 'hand',
            playerAction: PlayerAction.take,
            timestamp: DateTime(2026)),
      ],
    );

    expect(await records.share(userId: 'alice', shareRecord: shared), isTrue);
    expect(store.docs.keys, ['shares/alice']);

    final imported = await records.import(userId: 'alice');
    expect(imported!.cards.single.name, 'Katana');
    expect(imported.data.single.playerAction, PlayerAction.take);
    expect(await records.import(userId: 'bob'), isNull);
  });
}
