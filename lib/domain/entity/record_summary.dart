import 'package:equatable/equatable.dart';

class RecordSummary extends Equatable {
  final int totalDraw;
  final int totalReturn;
  final double percentagePlayed;
  final int unusedCardCount;

  const RecordSummary({
    this.totalDraw = 0,
    this.totalReturn = 0,
    this.percentagePlayed = 0,
    this.unusedCardCount = 0,
  });

  @override
  List<Object?> get props =>
      [totalDraw, totalReturn, percentagePlayed, unusedCardCount];
}
