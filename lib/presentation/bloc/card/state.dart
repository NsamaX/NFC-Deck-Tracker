part of 'bloc.dart';

class CardState extends Equatable {
  final CardEntity card;
  final String oldImageUrl;
  final String errorMessage;

  const CardState({
    this.card = const CardEntity(),
    this.oldImageUrl = '',
    this.errorMessage = '',
  });

  CardState copyWith({
    CardEntity? card,
    String? oldImageUrl,
    String? errorMessage,
  }) {
    return CardState(
      card: card ?? this.card,
      oldImageUrl: oldImageUrl ?? this.oldImageUrl,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [card, oldImageUrl, errorMessage];
}
