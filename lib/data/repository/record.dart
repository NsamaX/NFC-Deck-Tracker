import '../../domain/entity/record.dart';
import '../../domain/entity/share_record.dart';
import '../../domain/repository/record.dart';
import '../mapper/record.dart';
import '../mapper/share_record.dart';
import '../datasource/local/record.dart';
import '../datasource/remote/record.dart';

class RecordRepositoryImpl implements RecordRepository {
  final RecordLocalDatasource localDatasource;
  final RecordRemoteDatasource remoteDatasource;

  RecordRepositoryImpl({
    required this.localDatasource,
    required this.remoteDatasource,
  });

  @override
  Future<void> createForLocal({
    required RecordEntity record,
  }) async {
    await localDatasource.create(record: RecordMapper.toModel(record));
  }

  @override
  Future<bool> createForRemote({
    required String userId,
    required RecordEntity record,
  }) async {
    return await remoteDatasource.create(
        userId: userId, record: RecordMapper.toModel(record));
  }

  @override
  Future<bool> deleteForLocal({
    required String recordId,
  }) async {
    return await localDatasource.delete(recordId: recordId);
  }

  @override
  Future<bool> deleteForRemote({
    required String userId,
    required String recordId,
  }) async {
    return await remoteDatasource.delete(userId: userId, recordId: recordId);
  }

  @override
  Future<List<RecordEntity>> fetchForLocal({
    required String deckId,
  }) async {
    return (await localDatasource.fetch(deckId: deckId))
        .map(RecordMapper.toEntity)
        .toList();
  }

  @override
  Future<List<RecordEntity>> fetchForRemote({
    required String userId,
    required String deckId,
  }) async {
    return (await remoteDatasource.fetch(userId: userId, deckId: deckId))
        .map(RecordMapper.toEntity)
        .toList();
  }

  @override
  Future<ShareRecordEntity?> import({
    required String userId,
  }) async {
    final shareRecord = await remoteDatasource.import(userId: userId);
    if (shareRecord == null) return null;
    return ShareRecordMapper.toEntity(shareRecord);
  }

  @override
  Future<bool> share({
    required String userId,
    required ShareRecordEntity shareRecord,
  }) async {
    return await remoteDatasource.share(
        userId: userId, shareRecord: ShareRecordMapper.toModel(shareRecord));
  }

  @override
  Future<void> updateForLocal({
    required RecordEntity record,
  }) async {
    await localDatasource.update(record: RecordMapper.toModel(record));
  }

  @override
  Future<bool> updateForRemote({
    required String userId,
    required RecordEntity record,
  }) async {
    return await remoteDatasource.update(
        userId: userId, record: RecordMapper.toModel(record));
  }
}
