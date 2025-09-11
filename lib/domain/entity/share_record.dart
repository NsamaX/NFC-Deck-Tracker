import 'package:equatable/equatable.dart';

import 'card.dart';
import 'data.dart';

class ShareRecordEntity extends Equatable {
  final List<CardEntity> cards;
  final List<DataEntity> data;

  const ShareRecordEntity({
    required this.cards,
    required this.data,
  });

  ShareRecordEntity copyWith({
    List<CardEntity>? cards,
    List<DataEntity>? data,
  }) {
    return ShareRecordEntity(
      cards: cards ?? this.cards,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [
        cards,
        data,
      ];
}
