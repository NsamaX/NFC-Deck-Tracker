import '../../model/card.dart';

class CardPage {
  final List<CardModel> cards;

  /// Cursor for the following page, or null when this was the last one.
  final Map<String, dynamic>? next;

  const CardPage({required this.cards, required this.next});
}

abstract class GameApi {
  /// Fetch the page at [cursor]; an empty cursor is the first page.
  Future<CardPage> fetch(Map<String, dynamic> cursor);

  /// The card with [cardId], or null when the API has no such card.
  Future<CardModel?> find(String cardId);
}
