import 'package:flutter_test/flutter_test.dart';
import 'package:nfc_deck_tracker/data/datasource/remote/firestore_service.dart';
import 'package:nfc_deck_tracker/data/model/collection.dart';
import 'package:nfc_deck_tracker/domain/value/remote_unavailable.dart';

void main() {
  CollectionModel parse(String id, Map<String, dynamic> data) =>
      CollectionModel.fromJson({...data, 'collectionId': id});
  const valid = {'name': 'A', 'isSynced': true, 'updatedAt': '2024-01-01'};

  test('well-formed documents parse with their document ids', () {
    final models = FirestoreService.parseDocuments(
      collectionPath: 'users/u/collections',
      documents: {'c1': valid},
      parse: parse,
    );
    expect(models.single.collectionId, 'c1');
  });

  test('a malformed document makes the remote unreadable instead of absent',
      () {
    expect(
      () => FirestoreService.parseDocuments(
        collectionPath: 'users/u/collections',
        documents: {
          'c1': valid,
          'c2': {'name': 'B'},
        },
        parse: parse,
      ),
      throwsA(isA<RemoteUnavailableException>()),
    );
  });
}
