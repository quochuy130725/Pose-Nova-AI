import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'api_config.dart';

/// Standardized API Exception from PoseNova Back-End
class ApiException implements Exception {
  final int statusCode;
  final String code;
  final String message;
  final dynamic details;

  const ApiException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'ApiException($statusCode, $code): $message';
}

/// Core HTTP Network Client for PoseNova AI (TSK-20)
/// - Injects Bearer JWT tokens automatically for the active role (Client / Stylist)
/// - Auto-discovers working Back-End URL (`localhost:3000` or `10.0.2.2:3000`)
/// - Parses unified `{ success, message, data }` responses from Express Back-End
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  String? _activeToken;
  String? _clientToken;
  String? _stylistToken;
  bool _hasResolvedHost = false;

  String? get activeToken => _activeToken;
  String? get clientToken => _clientToken;
  String? get stylistToken => _stylistToken;

  /// Sets the JWT token for a specific role and activates it
  void setRoleToken({required String role, required String token}) {
    if (role.toUpperCase() == 'STYLIST') {
      _stylistToken = token;
    } else {
      _clientToken = token;
    }
    _activeToken = token;
  }

  /// Switches the active JWT token when toggling between Client & Stylist on the same device
  void activateRole(String role) {
    if (role.toUpperCase() == 'STYLIST' && _stylistToken != null) {
      _activeToken = _stylistToken;
    } else if (role.toUpperCase() != 'STYLIST' && _clientToken != null) {
      _activeToken = _clientToken;
    }
  }

  void clearTokens() {
    _activeToken = null;
    _clientToken = null;
    _stylistToken = null;
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? queryParameters,
    String? overrideToken,
    Duration timeout = const Duration(seconds: 6),
  }) {
    return _request(
      'GET',
      path,
      queryParameters: queryParameters,
      overrideToken: overrideToken,
      timeout: timeout,
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    String? overrideToken,
    Duration timeout = const Duration(seconds: 8),
  }) {
    return _request(
      'POST',
      path,
      body: body,
      overrideToken: overrideToken,
      timeout: timeout,
    );
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    String? overrideToken,
    Duration timeout = const Duration(seconds: 6),
  }) {
    return _request(
      'PUT',
      path,
      body: body,
      overrideToken: overrideToken,
      timeout: timeout,
    );
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
    String? overrideToken,
    required Duration timeout,
  }) async {
    final candidates = _hasResolvedHost
        ? <String>[
            ApiConfig.baseUrl,
            ...ApiConfig.candidateBaseUrls.where((u) => u != ApiConfig.baseUrl),
          ]
        : ApiConfig.candidateBaseUrls;

    Object? lastError;

    for (final base in candidates) {
      try {
        final uri = _buildUri(base, path, queryParameters);
        final response = await _executeHttp(
          method: method,
          uri: uri,
          body: body,
          token: overrideToken ?? _activeToken,
          timeout: timeout,
        );

        _hasResolvedHost = true;
        ApiConfig.setActiveBaseUrl(base);
        return response;
      } on SocketException catch (e) {
        lastError = e;
        continue;
      } on TimeoutException catch (e) {
        lastError = e;
        continue;
      } on HttpException catch (e) {
        lastError = e;
        continue;
      }
    }

    throw ApiException(
      statusCode: 503,
      code: 'BACKEND_UNREACHABLE',
      message: 'Không thể kết nối tới máy chủ Back-End (${ApiConfig.baseUrl}). Chi tiết: $lastError',
    );
  }

  Uri _buildUri(String baseUrl, String path, Map<String, String>? queryParameters) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final rawUrl = '$baseUrl$normalizedPath';
    final uri = Uri.parse(rawUrl);
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }
    return uri.replace(queryParameters: queryParameters);
  }

  Future<Map<String, dynamic>> _executeHttp({
    required String method,
    required Uri uri,
    Map<String, dynamic>? body,
    String? token,
    required Duration timeout,
  }) async {
    final client = HttpClient();
    client.connectionTimeout = timeout;

    try {
      final HttpClientRequest request = await client.openUrl(method, uri).timeout(timeout);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json; charset=utf-8');

      if (token != null && token.isNotEmpty) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }

      if (body != null && (method == 'POST' || method == 'PUT' || method == 'PATCH')) {
        final encoded = utf8.encode(jsonEncode(body));
        request.contentLength = encoded.length;
        request.add(encoded);
      }

      final HttpClientResponse response = await request.close().timeout(timeout);
      final String responseText = await response.transform(utf8.decoder).join().timeout(timeout);

      Map<String, dynamic> decoded = {};
      if (responseText.trim().isNotEmpty) {
        final parsed = jsonDecode(responseText);
        if (parsed is Map<String, dynamic>) {
          decoded = parsed;
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return decoded;
      }

      final errorObj = decoded['error'];
      final String errCode = (errorObj is Map ? errorObj['code']?.toString() : null) ??
          decoded['code']?.toString() ??
          'HTTP_${response.statusCode}';
      final String errMsg = (errorObj is Map ? errorObj['message']?.toString() : null) ??
          decoded['message']?.toString() ??
          'Yêu cầu thất bại với mã HTTP ${response.statusCode}';

      if (kDebugMode) {
        debugPrint('[ApiClient] HTTP ${response.statusCode} on $method $uri -> $errCode: $errMsg');
      }

      throw ApiException(
        statusCode: response.statusCode,
        code: errCode,
        message: errMsg,
        details: errorObj is Map ? errorObj['details'] : null,
      );
    } finally {
      client.close(force: false);
    }
  }
}
