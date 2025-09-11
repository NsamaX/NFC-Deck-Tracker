import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'package:nfc_deck_tracker/.config/player_action.dart';

import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/data.dart';
import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/record.dart';
import 'package:nfc_deck_tracker/domain/entity/share_record.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_record.dart';
import 'package:nfc_deck_tracker/domain/usecase/delete_record.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_record.dart';
import 'package:nfc_deck_tracker/domain/usecase/get_card_from_record.dart';
import 'package:nfc_deck_tracker/domain/usecase/import_record.dart';
import 'package:nfc_deck_tracker/domain/usecase/share_record.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_record.dart';

part 'event.dart';
part 'state.dart';

class RecordBloc extends Bloc<RecordEvent, RecordState> {
  final CreateRecordUsecase createRecordUsecase;
  final DeleteRecordUsecase deleteRecordUsecase;
  final FetchRecordUsecase fetchRecordUsecase;
  final GetCardFromRecordUsecase getCardFromRecordUsecase;
  final ImportRecordUsecase importRecordUsecase;
  final ShareRecordUsecase shareRecordUsecase;
  final UpdateRecordUsecase updateRecordUsecase;

  RecordBloc({
    required String deckId,
    required this.createRecordUsecase,
    required this.deleteRecordUsecase,
    required this.fetchRecordUsecase,
    required this.getCardFromRecordUsecase,
    required this.importRecordUsecase,
    required this.shareRecordUsecase,
    required this.updateRecordUsecase,
  }) : super(RecordState(
          currentRecord: RecordEntity(
            deckId: deckId,
            recordId: Uuid().v4(),
            data: [],
          ),
        )) {
    on<FetchRecordEvent>(_onFetchRecord);
    on<FindRecordEvent>(_onFindRecord);
    on<ImportRecordEvent>(_onImportRecord);
    on<ShareRecordEvent>(_onShareRecord);
    on<GetCardFromRecordEvent>(_onGetCardFromRecord);
    on<CreateRecordEvent>(_onCreateRecord);
    on<DeleteRecordEvent>(_onDeleteRecord);
    on<UpdateRecordEvent>(_onUpdateRecord);
    on<ResetRecordEvent>(_onResetRecord);
  }

  Future<void> _onFetchRecord(FetchRecordEvent event, Emitter<RecordState> emit) async {
    final records = await fetchRecordUsecase.call(userId: event.userId, deckId: event.deckId);
    emit(state.copyWith(records: records));
  }

  void _onFindRecord(FindRecordEvent event, Emitter<RecordState> emit) {
    final selected = state.records.firstWhere((r) => r.recordId == event.recordId);
    emit(state.copyWith(currentRecord: selected));
  }

  void _onImportRecord(ImportRecordEvent event, Emitter<RecordState> emit) async {
    final shareRecordEntity = await importRecordUsecase.call(userId: event.userId);

    final updatedData = [
      ...state.currentRecord.data,
      ...shareRecordEntity.data,
    ];
    updatedData.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    emit(state.copyWith(currentRecord: state.currentRecord.copyWith(data: updatedData)));
  }

  void _onShareRecord(ShareRecordEvent event, Emitter<RecordState> emit) async {
    final shareRecord = ShareRecordEntity(cards: event.cards, data: state.currentRecord.data);
    await shareRecordUsecase.call(userId: event.userId, shareRecord: shareRecord);
  }

  void _onGetCardFromRecord(GetCardFromRecordEvent event, Emitter<RecordState> emit) {
    final record = state.records.firstWhere((r) => r.recordId == event.recordId);
    final cards = getCardFromRecordUsecase.call(record: record, deck: event.deck);
    emit(state.copyWith(cards: cards));
  }

  PlayerAction getLastAction({
    required String collectionId,
    required String cardId,
  }) {
    if (state.currentRecord.data.isEmpty) return PlayerAction.none;
    final data = state.currentRecord.data.where((e) => e.collectionId == collectionId && e.cardId == cardId).toList();
    if (data.isEmpty) return PlayerAction.none;
    return data.last.playerAction;
  }

  Future<void> _onCreateRecord(CreateRecordEvent event, Emitter<RecordState> emit) async {
    emit(state.copyWith(currentRecord: state.currentRecord.copyWith(createdAt: DateTime.now())));
    await createRecordUsecase.call(userId: event.userId, record: state.currentRecord);
    final updatedRecords = [...state.records, state.currentRecord];
    emit(state.copyWith(records: updatedRecords));
  }

  Future<void> _onDeleteRecord(DeleteRecordEvent event, Emitter<RecordState> emit) async {
    await deleteRecordUsecase.call(userId: event.userId, recordId: event.recordId);
    emit(state.copyWith(records: state.records.where((r) => r.recordId != event.recordId).toList()));
  }

  void _onUpdateRecord(UpdateRecordEvent event, Emitter<RecordState> emit) {
    final newDataList = [...state.currentRecord.data, event.data];
    final updatedRecord = state.currentRecord.copyWith(data: newDataList);
    emit(state.copyWith(currentRecord: updatedRecord));
  }

  void _onResetRecord(ResetRecordEvent event, Emitter<RecordState> emit) {
    emit(state.copyWith(currentRecord: state.currentRecord.copyWith(data: [])));
  }
}
