part of 'card_cubit.dart';

class CardState extends Equatable {
  final CardEntity card;

  const CardState({
    this.card = const CardEntity(),
  });

  CardState copyWith({
    CardEntity? card,
  }) {
    return CardState(
      card: card ?? this.card,
    );
  }

  @override
  List<Object?> get props => [card];
}
