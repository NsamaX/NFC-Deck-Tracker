import '../../domain/repository/pending_delete.dart';
import '../../domain/value/sync_kind.dart';
import '../datasource/local/pending_delete.dart';

class PendingDeleteRepositoryImpl implements PendingDeleteRepository {
  final PendingDeleteLocalDatasource localDatasource;

  PendingDeleteRepositoryImpl({required this.localDatasource});

  @override
  Future<void> add({
    required String userId,
    required SyncKind kind,
    required String id,
  }) =>
      localDatasource.add(userId: userId, kind: kind.name, id: id);

  @override
  Future<Set<String>> ids({
    required String userId,
    required SyncKind kind,
  }) =>
      localDatasource.ids(userId: userId, kind: kind.name);

  @override
  Future<void> remove({
    required String userId,
    required SyncKind kind,
    required String id,
  }) =>
      localDatasource.remove(userId: userId, kind: kind.name, id: id);
}
