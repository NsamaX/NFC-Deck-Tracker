import '../value/remote_unavailable.dart';
import 'domain_logger.dart';

class SyncTarget<T> {
  final String Function(T entity) id;
  final DateTime? Function(T entity) updatedAt;
  final bool Function(T entity) isSynced;
  final T Function(T entity, bool synced) markSynced;
  final Future<void> Function(T entity) createLocal;
  final Future<void> Function(T entity) updateLocal;
  final Future<bool> Function(T entity) deleteLocal;
  final Future<bool> Function(T entity) createRemote;
  final Future<bool> Function(T entity) updateRemote;
  final T? Function(T local, T remote)? mergeExisting;

  /// Ids deleted locally whose remote delete has not succeeded yet. Such a
  /// remote row is deleted again instead of being imported back.
  final Set<String> pendingDeletes;
  final Future<bool> Function(T entity)? deleteRemote;
  final Future<void> Function(String id)? forgetDelete;

  const SyncTarget({
    required this.id,
    required this.updatedAt,
    required this.isSynced,
    required this.markSynced,
    required this.createLocal,
    required this.updateLocal,
    required this.deleteLocal,
    required this.createRemote,
    required this.updateRemote,
    this.mergeExisting,
    this.pendingDeletes = const {},
    this.deleteRemote,
    this.forgetDelete,
  });
}

class SyncPolicy {
  final DomainLogger logger;

  const SyncPolicy({this.logger = const SilentDomainLogger()});

  bool _isSignedIn(String userId) => userId.isNotEmpty;

  Future<T> write<T>({
    required String userId,
    required T entity,
    required T Function(T entity, bool synced) markSynced,
    required Future<bool> Function(T entity) remote,
    required Future<void> Function(T entity) local,
  }) async {
    var synced = false;
    if (_isSignedIn(userId)) {
      synced = await remote(markSynced(entity, true));
    }
    final saved = markSynced(entity, synced);
    await local(saved);
    return saved;
  }

  Future<void> delete({
    required String userId,
    required Future<void> Function() local,
    required Future<bool> Function() remote,
    required Future<void> Function() rememberPending,
  }) async {
    await local();
    if (!_isSignedIn(userId)) return;
    if (!await remote()) {
      logger.e('Remote delete failed; retrying on the next sync');
      await rememberPending();
    }
  }

  Future<List<T>> reconcile<T>({
    required String userId,
    required List<T> local,
    required Future<List<T>> Function() fetchRemote,
    required SyncTarget<T> target,
  }) async {
    final result = [...local];
    if (!_isSignedIn(userId)) return result;

    final List<T> remoteList;
    try {
      remoteList = await fetchRemote();
    } on RemoteUnavailableException catch (e) {
      logger.e('Remote unavailable, keeping local data: $e');
      return result;
    }

    final remoteIds = {for (final r in remoteList) target.id(r)};
    for (final id in target.pendingDeletes.difference(remoteIds)) {
      await target.forgetDelete?.call(id);
    }

    final pending = <T>[];
    final live = <T>[];
    for (final r in remoteList) {
      (target.pendingDeletes.contains(target.id(r)) ? pending : live).add(r);
    }
    for (final remote in pending) {
      if (await target.deleteRemote?.call(remote) ?? false) {
        await target.forgetDelete?.call(target.id(remote));
        logger.d('Deleted remote after a failed delete: ${target.id(remote)}');
      }
    }

    final remoteMap = {for (final r in live) target.id(r): r};
    final localMap = {for (final l in result) target.id(l): l};

    for (final remote in live) {
      final existing = localMap[target.id(remote)];
      if (existing == null) {
        await target.createLocal(remote);
        result.add(remote);
        logger.d('Imported remote -> local: ${target.id(remote)}');
      } else if (_isNewer(target, remote, existing)) {
        await target.updateLocal(remote);
        _replace(result, target, remote);
        logger.d('Updated local from remote: ${target.id(remote)}');
      } else {
        final merged = target.mergeExisting?.call(existing, remote);
        if (merged != null) {
          await target.updateLocal(merged);
          _replace(result, target, merged);
          logger.d('Merged remote into local: ${target.id(merged)}');
        }
      }
    }

    for (final entity in [...result]) {
      final remote = remoteMap[target.id(entity)];
      if (!target.isSynced(entity)) {
        final success =
            await target.createRemote(target.markSynced(entity, true));
        if (success) {
          final synced = target.markSynced(entity, true);
          await target.updateLocal(synced);
          _replace(result, target, synced);
          remoteMap[target.id(synced)] = synced;
          logger.d('Synced local -> remote: ${target.id(entity)}');
        } else {
          logger.e('Failed to sync local -> remote: ${target.id(entity)}');
        }
      } else if (remote != null && _isNewer(target, entity, remote)) {
        final success =
            await target.updateRemote(target.markSynced(entity, true));
        if (success) {
          logger.d('Updated remote with newer local: ${target.id(entity)}');
        } else {
          logger.e('Failed to update remote: ${target.id(entity)}');
        }
      }
    }

    final deleted = result
        .where(
            (e) => target.isSynced(e) && !remoteMap.containsKey(target.id(e)))
        .toList();
    for (final entity in deleted) {
      if (await target.deleteLocal(entity)) {
        result.removeWhere((e) => target.id(e) == target.id(entity));
        logger.d('Deleted local not found in remote: ${target.id(entity)}');
      } else {
        logger.e('Failed to delete local: ${target.id(entity)}');
      }
    }

    return result;
  }

  bool _isNewer<T>(SyncTarget<T> target, T a, T b) {
    final at = target.updatedAt(a);
    final bt = target.updatedAt(b);
    return at != null && bt != null && at.isAfter(bt);
  }

  void _replace<T>(List<T> list, SyncTarget<T> target, T entity) {
    final index = list.indexWhere((e) => target.id(e) == target.id(entity));
    if (index != -1) list[index] = entity;
  }
}
