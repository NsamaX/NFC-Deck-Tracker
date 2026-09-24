import '../../model/card.dart';

class CardPage {
  final List<CardModel> cards;
  final bool hasMore;

  const CardPage({required this.cards, required this.hasMore});
}

abstract class GameApi {
  Future<CardPage> fetch({
    required Map<String, dynamic> page,
  });
  Future<CardModel?> find({
    required String cardId,
  });
}

abstract class PagingStrategy {
  Map<String, dynamic> buildPage({
    required Map<String, dynamic> current,
    required int offset,
  });
}
