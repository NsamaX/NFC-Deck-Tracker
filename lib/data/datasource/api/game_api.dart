import '../../model/card.dart';

abstract class GameApi {
  Future<List<CardModel>> fetch({
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
