import 'package:nfc_deck_tracker/domain/repository/pending_delete.dart';
import 'package:nfc_deck_tracker/domain/value/sync_kind.dart';

class MemoryPendingDeletes implements PendingDeleteRepository {
  final entries = <(String, SyncKind, String)>{};

  @override
  Future<void> add(
          {required String userId,
          required SyncKind kind,
          required String id}) async =>
      entries.add((userId, kind, id));

  @override
  Future<Set<String>> ids(
          {required String userId, required SyncKind kind}) async =>
      {
        for (final (u, k, id) in entries)
          if (u == userId && k == kind) id
      };

  @override
  Future<void> remove(
          {required String userId,
          required SyncKind kind,
          required String id}) async =>
      entries.remove((userId, kind, id));
}
