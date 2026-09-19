import '../../domain/entity/record.dart';
import '../../domain/entity/share_record.dart';
import '../../domain/repository/record.dart';
import '../datasource/local/create_record.dart';
import '../datasource/local/delete_record.dart';
import '../datasource/local/fetch_record.dart';
import '../datasource/local/update_record.dart';
import '../datasource/remote/create_record.dart';
import '../datasource/remote/delete_record.dart';
import '../datasource/remote/fetch_record.dart';
import '../datasource/remote/import_record.dart';
import '../datasource/remote/share_record.dart';
import '../datasource/remote/update_record.dart';
import '../mapper/record.dart';
import '../mapper/share_record.dart';

class RecordRepositoryImpl implements RecordRepository {
  final CreateRecordLocalDatasource createRecordLocalDatasource;
  final CreateRecordRemoteDatasource createRecordRemoteDatasource;
  final DeleteRecordLocalDatasource deleteRecordLocalDatasource;
  final DeleteRecordRemoteDatasource deleteRecordRemoteDatasource;
  final FetchRecordLocalDatasource fetchRecordLocalDatasource;
  final FetchRecordRemoteDatasource fetchRecordRemoteDatasource;
  final ImportRecordRemoteDatasource importRecordRemoteDatasource;
  final ShareRecordRemoteDatasource shareRecordRemoteDatasource;
  final UpdateRecordLocalDatasource updateRecordLocalDatasource;
  final UpdateRecordRemoteDatasource updateRecordRemoteDatasource;

  RecordRepositoryImpl({
    required this.createRecordLocalDatasource,
    required this.createRecordRemoteDatasource,
    required this.deleteRecordLocalDatasource,
    required this.deleteRecordRemoteDatasource,
    required this.fetchRecordLocalDatasource,
    required this.fetchRecordRemoteDatasource,
    required this.importRecordRemoteDatasource,
    required this.shareRecordRemoteDatasource,
    required this.updateRecordLocalDatasource,
    required this.updateRecordRemoteDatasource,
  });

  @override
  Future<void> createForLocal({
    required RecordEntity record,
  }) async {
    await createRecordLocalDatasource.create(
        record: RecordMapper.toModel(record));
  }

  @override
  Future<bool> createForRemote({
    required String userId,
    required RecordEntity record,
  }) async {
    return await createRecordRemoteDatasource.create(
        userId: userId, record: RecordMapper.toModel(record));
  }

  @override
  Future<bool> deleteForLocal({
    required String recordId,
  }) async {
    return await deleteRecordLocalDatasource.delete(recordId: recordId);
  }

  @override
  Future<bool> deleteForRemote({
    required String userId,
    required String recordId,
  }) async {
    return await deleteRecordRemoteDatasource.delete(
        userId: userId, recordId: recordId);
  }

  @override
  Future<List<RecordEntity>> fetchForLocal({
    required String deckId,
  }) async {
    return (await fetchRecordLocalDatasource.fetch(deckId: deckId))
        .map(RecordMapper.toEntity)
        .toList();
  }

  @override
  Future<List<RecordEntity>> fetchForRemote({
    required String userId,
    required String deckId,
  }) async {
    return (await fetchRecordRemoteDatasource.fetch(
            userId: userId, deckId: deckId))
        .map(RecordMapper.toEntity)
        .toList();
  }

  @override
  Future<ShareRecordEntity> import({
    required String userId,
  }) async {
    final shareRecord =
        await importRecordRemoteDatasource.import(userId: userId);
    return ShareRecordMapper.toEntity(shareRecord!);
  }

  @override
  Future<bool> share({
    required String userId,
    required ShareRecordEntity shareRecord,
  }) async {
    return await shareRecordRemoteDatasource.share(
        userId: userId, shareRecord: ShareRecordMapper.toModel(shareRecord));
  }

  @override
  Future<void> updateForLocal({
    required RecordEntity record,
  }) async {
    await updateRecordLocalDatasource.update(
        record: RecordMapper.toModel(record));
  }

  @override
  Future<bool> updateForRemote({
    required String userId,
    required RecordEntity record,
  }) async {
    return await updateRecordRemoteDatasource.update(
        userId: userId, record: RecordMapper.toModel(record));
  }
}
