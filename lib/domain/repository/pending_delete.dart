import '../value/sync_kind.dart';

abstract interface class PendingDeleteRepository {
  Future<void> add({
    required String userId,
    required SyncKind kind,
    required String id,
  });

  Future<Set<String>> ids({
    required String userId,
    required SyncKind kind,
  });

  Future<void> remove({
    required String userId,
    required SyncKind kind,
    required String id,
  });
}
