import '../../model/card.dart';

import '@service_factory.dart';

class DummyApi extends GameApi {
  @override
  Future<List<CardModel>> fetch(Map<String, dynamic> page) {
    throw Exception('❗ DummyApi.fetchCard() is not implemented');
  }

  @override
  Future<CardModel> find(String cardId) {
    throw Exception('❗ DummyApi.findCard() is not implemented');
  }
}

class DummyPagingStrategy implements PagingStrategy {
  @override
  Map<String, dynamic> buildPage({
    required Map<String, dynamic> current,
    required int offset,
  }) {
    throw Exception('❗ DummyPagingStrategy.buildPage() is not implemented');
  }
}
