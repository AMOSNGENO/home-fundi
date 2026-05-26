import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../storage/token_storage.dart';

class ApiException implements Exception {
  ApiException({
    required this.statusCode,
    required this.message,
    this.payload,
    this.uri,
  });

  final int statusCode;
  final String message;
  final dynamic payload;
  final Uri? uri;

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient({
    http.Client? client,
    TokenStorage? tokenStorage,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        tokenStorage = tokenStorage ?? TokenStorage(),
        baseUrl = _normalizeBaseUrl(baseUrl ?? ApiConfig.baseUrl);

  final http.Client _client;
  final TokenStorage tokenStorage;
  final String baseUrl;
  static const Duration requestTimeout = Duration(seconds: 8);

  void dispose() {
    _client.close();
  }

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) {
    return requestJson(
      'GET',
      path,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) {
    return requestJson(
      'POST',
      path,
      body: body,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) {
    return requestJson(
      'PUT',
      path,
      body: body,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) {
    return requestJson(
      'PATCH',
      path,
      body: body,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) {
    return requestJson(
      'DELETE',
      path,
      body: body,
      queryParameters: queryParameters,
      authenticated: authenticated,
    );
  }

  Future<Map<String, dynamic>> requestJson(
    String method,
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    bool authenticated = true,
  }) async {
    final uri = _buildUri(path, queryParameters: queryParameters);
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (authenticated) {
      final token = await tokenStorage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final encodedBody = body == null ? null : jsonEncode(body);
    late final http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response =
            await _client.get(uri, headers: headers).timeout(requestTimeout);
        break;
      case 'POST':
        response = await _client
            .post(uri, headers: headers, body: encodedBody)
            .timeout(requestTimeout);
        break;
      case 'PUT':
        response = await _client
            .put(uri, headers: headers, body: encodedBody)
            .timeout(requestTimeout);
        break;
      case 'PATCH':
        response = await _client
            .patch(uri, headers: headers, body: encodedBody)
            .timeout(requestTimeout);
        break;
      case 'DELETE':
        response = await _client
            .delete(uri, headers: headers, body: encodedBody)
            .timeout(requestTimeout);
        break;
      default:
        throw ArgumentError.value(method, 'method', 'Unsupported HTTP method');
    }

    if (response.statusCode == 204 || response.body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = _decode(response.body);
    final payload = _unwrap(decoded);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (payload is Map<String, dynamic>) {
        return payload;
      }
      return <String, dynamic>{'data': payload};
    }

    final message = _messageFromPayload(payload) ??
        response.reasonPhrase ??
        'Request failed';
    throw ApiException(
      statusCode: response.statusCode,
      message: message,
      payload: decoded,
      uri: uri,
    );
  }

  Uri _buildUri(String path, {Map<String, String>? queryParameters}) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$baseUrl$normalizedPath');
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: queryParameters);
  }

  dynamic _decode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  dynamic _unwrap(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      for (final key in ['data', 'result', 'payload', 'items', 'records']) {
        final value = decoded[key];
        if (value != null) {
          return value;
        }
      }
      return decoded;
    }
    return decoded;
  }

  String? _messageFromPayload(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      for (final key in ['message', 'error', 'detail', 'title']) {
        final value = payload[key];
        if (value != null) return value.toString();
      }
    }
    return payload?.toString();
  }

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return ApiConfig.baseUrl;
    }
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }
}
