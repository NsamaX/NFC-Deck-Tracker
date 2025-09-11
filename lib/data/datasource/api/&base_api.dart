import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:nfc_deck_tracker/util/logger.dart';

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

    try {
      final http.Response response = await client.get(
        url,
        headers: defaultHeaders,
      );

      _validateResponse(response: response);

      return response;
    } catch (e) {
      throw Exception('❌ Failed to send GET request to $url: $e');
    }
  }

  Map<String, dynamic> decodeResponse({
    required http.Response response,
  }) {
    try {
      return json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('❌ Failed to decode response: $e');
    }
  }

  Uri _buildUrl({
    required String path,
    Map<String, String>? queryParams,
  }) {
    return Uri.parse('$baseUrl/$path').replace(queryParameters: queryParams);
  }

  void _validateResponse({
    required http.Response response,
  }) {
    if (response.statusCode != 200) {
      final Map<String, dynamic> errorBody = decodeResponse(response: response);

      throw Exception('❌ API Error: ${response.statusCode}, ${response.reasonPhrase}, Response: $errorBody');
    }
  }
}
