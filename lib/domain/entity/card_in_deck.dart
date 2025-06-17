import 'package:equatable/equatable.dart';

import 'card.dart';

class CardInDeckEntity extends Equatable {
  final CardEntity card;
  final int count;

  const CardInDeckEntity({
    required this.card,
    required this.count,
  });

  CardInDeckEntity copyWith({
    CardEntity? card,
    int? count,
  }) =>
      CardInDeckEntity(
        card: card ?? this.card,
        count: count ?? this.count,
      );

  @override
  List<Object?> get props => [
        card,
        count,
      ];
}
