import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nfc_deck_tracker/data/datasource/api/api_client.dart';
import 'package:nfc_deck_tracker/data/datasource/api/scryfall.dart';
import 'package:nfc_deck_tracker/domain/value/remote_unavailable.dart';

class FakeTime {
  DateTime now = DateTime(2026);
  final slept = <Duration>[];
  Future<void> sleep(Duration d) async {
    slept.add(d);
    now = now.add(d);
  }
}

http.Response jsonResponse(String body, [int status = 200]) =>
    http.Response.bytes(body.codeUnits, status,
        headers: {'content-type': 'application/json; charset=utf-8'});

void main() {
  late FakeTime time;
  late List<http.Request> requests;

  ApiClient clientFor(FutureOr<http.Response> Function(http.Request) handler) {
    requests = [];
    return ApiClient(
      userAgent: 'test-agent',
      client: MockClient((request) async {
        requests.add(request);
        return handler(request);
      }),
      now: () => time.now,
      sleep: time.sleep,
    );
  }

  setUp(() => time = FakeTime());

  group('ApiClient', () {
    final url = Uri.parse('https://example.test/cards/1');

    test('concurrent identical requests share one call', () async {
      final client = clientFor((_) => jsonResponse('{"ok":true}'));
      final results =
          await Future.wait([client.getJson(url), client.getJson(url)]);
      expect(results, [
        {'ok': true},
        {'ok': true}
      ]);
      expect(requests, hasLength(1));
      expect(requests.single.headers['User-Agent'], 'test-agent');
    });

    test('a 404 is remembered for a while instead of refetched', () async {
      final client = clientFor((_) => jsonResponse('{}', 404));
      for (var i = 0; i < 2; i++) {
        await expectLater(
            client.getJson(url), throwsA(isA<ApiStatusException>()));
      }
      expect(requests, hasLength(1));
      time.now = time.now.add(const Duration(minutes: 11));
      await expectLater(
          client.getJson(url), throwsA(isA<ApiStatusException>()));
      expect(requests, hasLength(2));
    });

    test('rate limits and server errors are retried with backoff', () async {
      final statuses = [429, 503, 200];
      final client = clientFor((_) {
        final status = statuses.removeAt(0);
        return status == 429
            ? http.Response('', 429, headers: {'retry-after': '2'})
            : jsonResponse('{"ok":true}', status);
      });
      expect(await client.getJson(url), {'ok': true});
      expect(time.slept,
          [const Duration(seconds: 2), const Duration(milliseconds: 1000)]);
    });

    test('persistent failures and network errors become unavailable', () async {
      final failing = clientFor((_) => jsonResponse('{}', 502));
      await expectLater(
          failing.getJson(url), throwsA(isA<RemoteUnavailableException>()));
      expect(requests, hasLength(3));

      final offline = clientFor((_) => throw const SocketException('no route'));
      await expectLater(
          offline.getJson(url), throwsA(isA<RemoteUnavailableException>()));
    });

    test('requests to one host are spaced by the minimum interval', () async {
      final client = clientFor((_) => jsonResponse('{}'));
      const gap = Duration(milliseconds: 100);
      await client.getJson(Uri.parse('https://example.test/a'),
          minInterval: gap);
      await client.getJson(Uri.parse('https://example.test/b'),
          minInterval: gap);
      await client.getJson(Uri.parse('https://other.test/c'), minInterval: gap);
      expect(time.slept, [gap]);
    });
  });

  group('ScryfallApi', () {
    test('pages by has_more with the catalog query and request spacing',
        () async {
      final api = ScryfallApi(
          clientFor((request) => jsonResponse(
              '{"data":[{"id":"u1","name":"Katana","type_line":"Artifact",'
              '"mana_cost":"{1}{W}","image_uris":{"normal":"https://img/n.jpg"}}],'
              '"has_more":${request.url.queryParameters['page'] == '1'}}')),
          'https://api.example.test/');

      final first = await api.fetch({});
      final card = first.cards.single;
      expect(card.cardId, 'u1');
      expect(card.collectionId, 'magic');
      expect(card.imageUrl, 'https://img/n.jpg');
      expect(card.description, 'Artifact, {1}{W}');
      expect(first.next, {'page': 2});
      expect((await api.fetch(first.next!)).next, isNull);

      final query = requests.first.url.queryParameters;
      expect(requests.first.url.path, '/cards/search');
      expect(query['q'], 'game:paper');
      expect(time.slept, [ScryfallApi.requestSpacing]);
    });

    test('an unknown card is missing and a server error is unavailable',
        () async {
      final missing = ScryfallApi(
          clientFor((_) => jsonResponse('{}', 404)), 'https://example.test/');
      expect(await missing.find('nope'), isNull);

      final failing = ScryfallApi(clientFor((_) => jsonResponse('<html>', 502)),
          'https://example.test/');
      await expectLater(
          failing.find('x'), throwsA(isA<RemoteUnavailableException>()));
    });

    test('double-faced cards take the front face image', () async {
      final api = ScryfallApi(
          clientFor((_) => jsonResponse(
              '{"id":"d1","name":"Day // Night","type_line":"Saga // Creature",'
              '"card_faces":[{"name":"Day","oracle_text":"A","mana_cost":"{G}",'
              '"image_uris":{"normal":"https://img/day.jpg"}},'
              '{"name":"Night","oracle_text":"B"}]}')),
          'https://api.example.test/');

      final card = (await api.find('d1'))!;
      expect(card.imageUrl, 'https://img/day.jpg');
      expect(card.additionalData!['oracleText'], 'A\n//\nB');
      expect(requests.single.url.path, '/cards/d1');
    });
  });
}
