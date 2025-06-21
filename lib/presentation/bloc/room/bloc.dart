import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

import 'package:nfc_deck_tracker/domain/entity/deck.dart';
import 'package:nfc_deck_tracker/domain/entity/record.dart';
import 'package:nfc_deck_tracker/domain/entity/card.dart';
import 'package:nfc_deck_tracker/domain/entity/room.dart';
import 'package:nfc_deck_tracker/domain/usecase/close_room.dart';
import 'package:nfc_deck_tracker/domain/usecase/create_room.dart';
import 'package:nfc_deck_tracker/domain/usecase/fetch_room.dart';
import 'package:nfc_deck_tracker/domain/usecase/join_room.dart';
import 'package:nfc_deck_tracker/domain/usecase/update_room.dart';

part 'event.dart';
part 'state.dart';

class RoomBloc extends Bloc<RoomEvent, RoomState> {
  final CloseRoomUsecase closeRoomUsecase;
  final CreateRoomUsecase createRoomUsecase;
  final FetchRoomUsecase fetchRoomUsecase;
  final JoinRoomUsecase joinRoomUsecase;
  final UpdateRoomUsecase updateRoomUsecase;

  RoomBloc({
    required DeckEntity deck,
    required this.closeRoomUsecase,
    required this.createRoomUsecase,
    required this.fetchRoomUsecase,
    required this.joinRoomUsecase,
    required this.updateRoomUsecase,
  }) : super(RoomState(deck: deck)) {
    on<CloseRoomEvent>(_onCloseRoom);
    on<CreateRoomEvent>(_onCreateRoom);
    on<JoinRoomEvent>(_onJoinRoom);
    on<UpdateRoomEvent>(_onUpdateRoom);
  }

  Future<void> _onCloseRoom(CloseRoomEvent event, Emitter<RoomState> emit) async {
    emit(state.copyWith(isLoading: true));
    await closeRoomUsecase(roomId: event.roomId);
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _onCreateRoom(CreateRoomEvent event, Emitter<RoomState> emit) async {
    emit(state.copyWith(isLoading: true));

    final newRoom = RoomEntity(
      roomId: const Uuid().v4(),
      playerIds: event.playerIds,
      cards: state.deck.cards!
          .map((c) => CardEntity(cardId: c.card.cardId))
          .toList(),
      record: RecordEntity(
        deckId: state.deck.deckId!,
        recordId: const Uuid().v4(),
        createdAt: DateTime.now(),
        data: [],
      ),
    );

    await createRoomUsecase(room: newRoom);
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _onJoinRoom(JoinRoomEvent event, Emitter<RoomState> emit) async {
    emit(state.copyWith(isLoading: true));
    await joinRoomUsecase(roomId: event.roomId, playerId: event.userId);
    emit(state.copyWith(isLoading: false));
  }

  Future<void> _onUpdateRoom(UpdateRoomEvent event, Emitter<RoomState> emit) async {
    emit(state.copyWith(isLoading: true));
    await updateRoomUsecase(
      roomId: event.room.roomId,
      updatedRoom: event.room,
    );
    emit(state.copyWith(isLoading: false));
  }
}
