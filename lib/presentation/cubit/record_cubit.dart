import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/data.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/player_action.dart';
import 'package:nfc_deck_tracker/domain/entity/record.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_record.dart';
import 'package:nfc_deck_tracker/domain/usecase/delete_record.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_record.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_record.dart';

part 'record_state.dart';

class RecordCubit extends Cubit<RecordState> {
  final CreateRecordUsecase createRecordUsecase;
  final DeleteRecordUsecase deleteRecordUsecase;
  final FetchRecordUsecase fetchRecordUsecase;
  final UpdateRecordUsecase updateRecordUsecase;

  RecordCubit({
    required String deckId,
    required this.createRecordUsecase,
    required this.deleteRecordUsecase,
    required this.fetchRecordUsecase,
    required this.updateRecordUsecase,
  }) : super(RecordState(
        currentRecord: RecordEntity(
          deckId: deckId,
          recordId: Uuid().v4(),
          createdAt: DateTime.now(),
          data: [],
        ),
      ));

  void safeEmit(RecordState newState) {
    if (!isClosed) emit(newState);
  }

  void toggleResetRecord() {
    safeEmit(state.copyWith(records: []));
  }

  void createRecord({
    required String userId,
  }) async {
    await createRecordUsecase.call(userId: userId, record: state.currentRecord);
  }

  void removeRecord({
    required String userId,
    required String recordId,
  }) async {
    await deleteRecordUsecase.call(userId: userId, recordId: recordId);
  }

  void fetchRecord({
    required String userId,
    required String deckId,
  }) async {
    safeEmit(state.copyWith(isLoading: true));
    final records = await fetchRecordUsecase.call(userId: userId, deckId: deckId);
    safeEmit(state.copyWith(records: records, isLoading: false));
  }
  
  void findRecord({
    required String recordId,
  }) {
    final selected = state.records.firstWhere((r) => r.recordId == recordId);
    safeEmit(state.copyWith(currentRecord: selected));
  }

  void saveRecord({
    required String userId,
  }) async {
    await updateRecordUsecase.call(userId: userId, record: state.currentRecord);
  }

  List<CardEntity> getCardFromRecord({
    required String recordId,
    required DeckEntity deck,
  }) {
    final record = state.records.firstWhere((r) => r.recordId == recordId);

    return record.data
        .map((data) =>
            deck.cards?.firstWhere((card) => card.card.cardId == data.cardId).card)
        .whereType<CardEntity>()
        .toList();
  }

  Future<void> selectRecord({
    required String recordId,
  }) async {
    final selected = state.records.firstWhere((r) => r.recordId == recordId);
    safeEmit(state.copyWith(currentRecord: selected));
  }

  void clearActiveRecordData() {
    safeEmit(state.copyWith(
      currentRecord: state.currentRecord.copyWith(
        data: [],
      ),
    ));
  }

  void appendDataToRecord({
    required DataEntity data,
  }) {
    final newDataList = [...state.currentRecord.data, data];
    safeEmit(state.copyWith(
      currentRecord: state.currentRecord.copyWith(
        data: newDataList,
      ),
    ));
  }

  bool? wasLastActionDraw({
    required String cardId,
    required String collectionId,
  }) {
    try {
      final last = state.currentRecord.data.lastWhere(
        (entry) => entry.cardId == cardId && entry.collectionId == collectionId,
      );

      return switch (last.playerAction) {
        PlayerAction.draw => true,
        PlayerAction.returnToDeck => false,
        _ => null,
      };
    } catch (_) {
      return null;
    }
  }
}
