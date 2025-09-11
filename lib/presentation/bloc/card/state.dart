part of 'bloc.dart';

class CardState extends Equatable {
  final CardEntity card;
  final String oldImageUrl;

  const CardState({
    this.card = const CardEntity(),
    this.oldImageUrl = '',
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
