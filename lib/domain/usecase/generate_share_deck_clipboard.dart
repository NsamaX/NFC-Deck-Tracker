import '../entity/deck.dart';

class GenerateShareDeckClipboardUsecase {
  String call({
    required DeckEntity deck,
    required String nameLabel,
    required String totalLabel,
  }) {
    final cardList = deck.cards ?? [];
    final totalCount = cardList.fold<int>(0, (sum, e) => sum + e.count);

    final lines = <String>[
      '$nameLabel: ${deck.name}',
      totalLabel.replaceAll('{card}', totalCount.toString()),
      ...cardList.map((e) => '- [${e.count}] ${e.card.name}'),
    ];

    return lines.join('\n');
  }
}
