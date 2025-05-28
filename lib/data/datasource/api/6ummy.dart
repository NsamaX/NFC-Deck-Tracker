import '_service_factory.dart';

import '../../model/card.dart';

class DummyApi extends GameApi {
  @override
  Future<List<CardModel>> fetchCard({
    required Map<String, dynamic> page,
  }) {
    throw Exception('❗ DummyApi.fetchCard() is not implemented');
  }

  @override
  Future<CardModel> findCard({
    required String cardId,
  }) {
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
