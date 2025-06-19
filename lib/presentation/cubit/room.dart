import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class RoomCubit extends Cubit<RoomState> {
  final CloseRoomUsecase closeRoomUsecase;
  final CreateRoomUsecase createRoomUsecase;
  final FetchRoomUsecase fetchRoomUsecase;
  final JoinRoomUsecase joinRoomUsecase;
  final UpdateRoomUsecase updateRoomUsecase;

  RoomCubit({
    required DeckEntity deck,
    required this.closeRoomUsecase,
    required this.createRoomUsecase,
    required this.fetchRoomUsecase,
    required this.joinRoomUsecase,
    required this.updateRoomUsecase,
  }) : super(RoomState(deck: deck));

  Future<void> closeRoom({
    required String roomId,
  }) async {
    emit(state.copyWith(isLoading: true));
    await closeRoomUsecase(roomId: roomId);
    emit(state.copyWith(isLoading: false));
  }

  Future<void> createRoom({
    required List<String> playerIds,
  }) async {
    emit(state.copyWith(isLoading: true));
    RoomEntity updatedRoom = RoomEntity(
      roomId: Uuid().v4(),
      playerIds: playerIds,
      cards: state.deck.cards!.map(
        (card) => CardEntity(cardId: card.card.cardId),
      ).toList(),
      record: RecordEntity(
        deckId: state.deck.deckId!,
        recordId: Uuid().v4(),
        createdAt: DateTime.now(),
        data: [],
      ),
    );
    await createRoomUsecase(room: updatedRoom);
    emit(state.copyWith(isLoading: false));
  }

  Future<void> joinRoom({
    required String roomId,
    required String userId,
  }) async {
    emit(state.copyWith(isLoading: true));
    await joinRoomUsecase(roomId: roomId, playerId: userId);
    emit(state.copyWith(isLoading: false));
  }

  Future<void> updateRoom({
    required RoomEntity room,
  }) async {
    emit(state.copyWith(isLoading: true));
    await updateRoomUsecase(roomId: room.roomId, updatedRoom: room);
    emit(state.copyWith(isLoading: false));
  }
}

class RoomState extends Equatable {
  final bool isLoading;

  final DeckEntity deck;
  final String roomId;
  final List<CardEntity> cards;
  final List<CardEntity> visibleCards;

  const RoomState({
    this.isLoading = false,
    required this.deck,
    this.roomId = '',
    this.cards = const [],
    this.visibleCards = const [],
  });

  RoomState copyWith({
    bool? isLoading,
    DeckEntity? deck,
    String? roomId,
    List<CardEntity>? cards,
    List<CardEntity>? visibleCards,
  }) {
    return RoomState(
      isLoading: isLoading ?? this.isLoading,
      deck: deck ?? this.deck,
      roomId: roomId ?? this.roomId,
      cards: cards ?? this.cards,
      visibleCards: visibleCards ?? this.visibleCards,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        deck,
        roomId,
        cards,
        visibleCards,
      ];
}
