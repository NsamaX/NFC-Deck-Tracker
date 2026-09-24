import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:nfc_deck_tracker/domain/value/remote_unavailable.dart';
import 'package:nfc_deck_tracker/util/logger.dart';

class ApiStatusException implements Exception {
  final int statusCode;
  final String body;

  const ApiStatusException(this.statusCode, this.body);

  @override
  String toString() => 'ApiStatusException: $statusCode $body';
}

/// Shared HTTP access for every game API: one connection pool, a per-host
/// request spacing, retries for 429/5xx and network errors, one request for
/// concurrent identical GETs, and a short memory of 404 responses.
class ApiClient {
  final http.Client _client;
  final Map<String, String> _headers;
  final int _maxRetries;
  final Duration _timeout;
  final Duration _notFoundTtl;
  final DateTime Function() _now;
  final Future<void> Function(Duration) _sleep;

  final _inFlight = <Uri, Future<Object?>>{};
  final _notFound = <Uri, DateTime>{};
  final _nextSlot = <String, DateTime>{};

  ApiClient({
    http.Client? client,
    required String userAgent,
    int maxRetries = 2,
    Duration timeout = const Duration(seconds: 20),
    Duration notFoundTtl = const Duration(minutes: 10),
    DateTime Function()? now,
    Future<void> Function(Duration)? sleep,
  })  : _client = client ?? http.Client(),
        _headers = {
          'Accept': 'application/json',
          'Accept-Encoding': 'gzip',
          'User-Agent': userAgent,
        },
        _maxRetries = maxRetries,
        _timeout = timeout,
        _notFoundTtl = notFoundTtl,
        _now = now ?? DateTime.now,
        _sleep = sleep ?? Future.delayed;

  /// Decoded JSON body of a 200 response. Throws [ApiStatusException] for
  /// 4xx responses and [RemoteUnavailableException] when the API cannot be
  /// reached or keeps failing.
  Future<Object?> getJson(
    Uri url, {
    Duration minInterval = Duration.zero,
  }) {
    final missedAt = _notFound[url];
    if (missedAt != null) {
      if (_now().difference(missedAt) < _notFoundTtl) {
        return Future.error(const ApiStatusException(404, 'cached'));
      }
      _notFound.remove(url);
    }
    return _inFlight[url] ??= _get(url, minInterval).whenComplete(() {
      _inFlight.remove(url);
    });
  }

  Future<Object?> _get(Uri url, Duration minInterval) async {
    for (var attempt = 0;; attempt++) {
      await _throttle(url.host, minInterval);
      LoggerUtil.i('GET $url');

      final http.Response response;
      try {
        response = await _client.get(url, headers: _headers).timeout(_timeout);
      } catch (e) {
        if (attempt < _maxRetries) {
          await _sleep(_backoff(attempt));
          continue;
        }
        throw RemoteUnavailableException('GET $url: $e');
      }

      final status = response.statusCode;
      if (status == 200) {
        try {
          return json.decode(utf8.decode(response.bodyBytes));
        } on FormatException catch (e) {
          throw RemoteUnavailableException('GET $url: invalid JSON: $e');
        }
      }
      if (status == 404) _notFound[url] = _now();
      if (status == 429 || status >= 500) {
        if (attempt < _maxRetries) {
          await _sleep(_retryAfter(response) ?? _backoff(attempt));
          continue;
        }
        throw RemoteUnavailableException('GET $url: HTTP $status');
      }
      throw ApiStatusException(status, response.body);
    }
  }

  Future<void> _throttle(String host, Duration interval) async {
    if (interval == Duration.zero) return;
    final now = _now();
    final slot = _nextSlot[host];
    final start = slot == null || slot.isBefore(now) ? now : slot;
    _nextSlot[host] = start.add(interval);
    final wait = start.difference(now);
    if (wait > Duration.zero) await _sleep(wait);
  }

  Duration _backoff(int attempt) =>
      Duration(milliseconds: 500 * (1 << attempt));

  Duration? _retryAfter(http.Response response) {
    final seconds = int.tryParse(response.headers['retry-after'] ?? '');
    return seconds == null ? null : Duration(seconds: seconds);
  }

  void close() => _client.close();
}
