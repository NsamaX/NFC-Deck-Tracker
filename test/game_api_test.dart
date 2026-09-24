import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nfc_deck_tracker/data/datasource/api/pokemon.dart';
import 'package:nfc_deck_tracker/domain/value/remote_unavailable.dart';

PokemonApi apiReturning(Future<http.Response> Function() respond) => PokemonApi(
    baseUrl: 'https://example.test/v2', client: MockClient((_) => respond()));

void main() {
  test('an unknown card id is reported as missing', () async {
    final api = apiReturning(() async => http.Response('{}', 404));
    expect(await api.find(cardId: 'nope'), isNull);
  });

  test('server errors and network failures are reported as unavailable',
      () async {
    final failing = apiReturning(() async => http.Response('<html>', 502));
    await expectLater(
        failing.find(cardId: 'x'), throwsA(isA<RemoteUnavailableException>()));
    final offline =
        apiReturning(() async => throw const SocketException('no route'));
    await expectLater(
        offline.find(cardId: 'x'), throwsA(isA<RemoteUnavailableException>()));
  });

  test('a found card is parsed and an empty page ends the catalog', () async {
    final api = apiReturning(() async => http.Response(
        '{"data":{"id":"xy1-1","name":"Venusaur","supertype":"Pokémon"}}', 200,
        headers: {'content-type': 'application/json; charset=utf-8'}));
    expect((await api.find(cardId: 'xy1-1'))!.name, 'Venusaur');

    final empty = apiReturning(() async => http.Response('{"data":[]}', 200));
    expect((await empty.fetch(page: {'page': 9})).hasMore, isFalse);
  });
}
