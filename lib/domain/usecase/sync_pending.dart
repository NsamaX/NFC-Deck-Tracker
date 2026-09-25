import '../repository/card.dart';
import '../repository/collection.dart';
import '../repository/deck.dart';
import '../repository/pending_delete.dart';
import '../repository/record.dart';
import '../service/domain_logger.dart';
import '../value/sync_kind.dart';

/// Pushes only what is out of sync: unsynced local rows and failed remote
/// deletes. Run when the device comes back online or a user signs in, so
/// offline changes reach the cloud without waiting for each list to open.
class SyncPendingUsecase {
  final CollectionRepository collectionRepository;
  final CardRepository cardRepository;
  final DeckRepository deckRepository;
  final RecordRepository recordRepository;
  final PendingDeleteRepository pendingDeletes;
  final DomainLogger logger;

  SyncPendingUsecase({
    required this.collectionRepository,
    required this.cardRepository,
    required this.deckRepository,
    required this.recordRepository,
    required this.pendingDeletes,
    this.logger = const SilentDomainLogger(),
  });

  /// Returns how many rows were pushed or deleted remotely.
  Future<int> call({required String userId}) async {
    if (userId.isEmpty) return 0;
    var done = 0;

    for (final c in await collectionRepository.fetchForLocal()) {
      if (c.isSynced) continue;
      final synced = c.copyWith(isSynced: true);
      if (await collectionRepository.createForRemote(
          userId: userId, collection: synced)) {
        await collectionRepository.updateForLocal(collection: synced);
        done++;
      }
    }

    for (final card in await cardRepository.fetchUserCards()) {
      if (card.isSynced) continue;
      final synced = card.copyWith(isSynced: true);
      if (await cardRepository.createForRemote(userId: userId, card: synced)) {
        await cardRepository.updateForLocal(card: synced);
        done++;
      }
    }

    final decks = await deckRepository.fetchForLocal();
    for (final deck in decks) {
      if (deck.isSynced) continue;
      final synced = deck.copyWith(isSynced: true);
      if (await deckRepository.createForRemote(userId: userId, deck: synced)) {
        await deckRepository.updateForLocal(deck: synced);
        done++;
      }
    }

    for (final deck in decks) {
      for (final record
          in await recordRepository.fetchForLocal(deckId: deck.deckId)) {
        if (record.isSynced) continue;
        final synced = record.copyWith(isSynced: true);
        if (await recordRepository.createForRemote(
            userId: userId, record: synced)) {
          await recordRepository.updateForLocal(record: synced);
          done++;
        }
      }
    }

    final deletes = <SyncKind, Future<bool> Function(String id)>{
      SyncKind.collection: (id) => collectionRepository.deleteForRemote(
          userId: userId, collectionId: id),
      SyncKind.deck: (id) =>
          deckRepository.deleteForRemote(userId: userId, deckId: id),
      SyncKind.record: (id) =>
          recordRepository.deleteForRemote(userId: userId, recordId: id),
    };
    for (final MapEntry(key: kind, value: delete) in deletes.entries) {
      for (final id in await pendingDeletes.ids(userId: userId, kind: kind)) {
        if (await delete(id)) {
          await pendingDeletes.remove(userId: userId, kind: kind, id: id);
          done++;
        }
      }
    }

    logger.d('Pushed $done pending changes for $userId');
    return done;
  }
}
