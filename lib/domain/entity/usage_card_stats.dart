import 'package:equatable/equatable.dart';

class UsageCardStats extends Equatable {
  final String cardName;
  final int drawCount;
  final int returnCount;

  const UsageCardStats({
    required this.cardName,
    required this.drawCount,
    required this.returnCount,
  });

  UsageCardStats copyWith({
    String? cardName,
    int? drawCount,
    int? returnCount,
  }) =>
      UsageCardStats(
        cardName: cardName ?? this.cardName,
        drawCount: drawCount ?? this.drawCount,
        returnCount: returnCount ?? this.returnCount,
      );

  @override
  List<Object?> get props => [
        cardName,
        drawCount,
        returnCount,
      ];
}
