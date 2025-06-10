part of 'room_cubit.dart';

class RoomState extends Equatable {
  final bool isLoading;

  final String roomId;
  final List<CardEntity> cards;
  final List<CardEntity> visibleCards;

  const RoomState({
    this.isLoading = false,
    this.roomId = '',
    this.cards = const [],
    this.visibleCards = const [],
  });

  RoomState copyWith({
    bool? isLoading,
    String? roomId,
    List<CardEntity>? cards,
    List<CardEntity>? visibleCards,
  }) {
    return RoomState(
      isLoading: isLoading ?? this.isLoading,
      roomId: roomId ?? this.roomId,
      cards: cards ?? this.cards,
      visibleCards: visibleCards ?? this.visibleCards,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        roomId,
        cards,
        visibleCards,
      ];
}
