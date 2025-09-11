import '../entity/deck.dart';

class GenerateShareDeckClipboardUsecase {
  String call({
    required DeckEntity deck,
    required String nameLabel,
    required String totalLabel,
  }) {
    final cardList = deck.cards ?? [];
    final totalCount = cardList.fold<int>(0, (sum, e) => sum + e.count);

    final lines = <String>[];

    lines.add('$nameLabel: ${deck.name}');
    lines.add('${totalLabel.replaceAll('{total}', totalCount.toString())}');
    lines.add('Card List:');

    for (final cardInDeck in cardList) {
      final name = cardInDeck.card.name?.trim();
      final count = cardInDeck.count;
      lines.add('   • ${name ?? "Unknown"} × $count');
    }

    return lines.join('\n');
  }
}
