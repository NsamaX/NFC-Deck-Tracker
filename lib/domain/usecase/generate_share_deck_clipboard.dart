import '../entity/deck.dart';

class GenerateShareDeckClipboardUsecase {
  String call({
    required DeckEntity deck,
    required String nameLabel,
    required String totalLabel,
  }) {
    final lines = <String>[
      '$nameLabel: ${deck.name}',
      '$totalLabel: ${deck.cards?.fold(0, (sum, e) => sum + e.count) ?? 0}',
      ...?deck.cards?.map((e) => '- [${e.count}] ${e.card.name}'),
    ];
    return lines.join('\n');
  }
}
