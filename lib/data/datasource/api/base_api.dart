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

abstract class BaseApi {
  final String baseUrl;
  final http.Client client;

  static final Map<String, String> defaultHeaders = {
    'Accept-Encoding': 'gzip',
    'Content-Type': 'application/json',
  };

  BaseApi({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  Future<http.Response> getRequest({
    required String path,
    Map<String, String>? queryParams,
  }) async {
    final Uri url = _buildUrl(
      path: path,
      queryParams: queryParams,
    );

    LoggerUtil.i('Sending GET request to: $url');

    final http.Response response;
    try {
      response = await client.get(url, headers: defaultHeaders);
    } catch (e) {
      throw RemoteUnavailableException('GET $url: $e');
    }
    if (response.statusCode != 200) {
      throw ApiStatusException(response.statusCode, response.body);
    }
    return response;
  }

  Map<String, dynamic> decodeResponse({
    required http.Response response,
  }) {
    try {
      return json.decode(utf8.decode(response.bodyBytes))
          as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to decode response: $e');
    }
  }

  Uri _buildUrl({
    required String path,
    Map<String, String>? queryParams,
  }) {
    return Uri.parse('$baseUrl/$path').replace(queryParameters: queryParams);
  }
}
