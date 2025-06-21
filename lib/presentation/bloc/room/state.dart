part of 'bloc.dart';

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
