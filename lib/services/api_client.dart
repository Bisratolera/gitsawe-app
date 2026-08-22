import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Thrown when a request to the Gitsawe API fails, whether because of a
/// network problem, a timeout, or an unexpected response shape.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() =>
      statusCode != null ? 'ApiException($statusCode): $message' : 'ApiException: $message';
}

/// Thin wrapper around the published Gitsawe web API
/// (https://gitsawe-web.lovable.app), the same backend that powers the
/// website. All lookups the app needs live under /api/public/v1.
class ApiClient {
  ApiClient._internal();
  static final ApiClient instance = ApiClient._internal();

  static const String baseUrl = 'https://gitsawe-web.lovable.app/api/public/v1';
  static const Duration _timeout = Duration(seconds: 20);

  final http.Client _client = http.Client();

  Uri _uri(String path, Map<String, String>? query) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$baseUrl$normalizedPath').replace(queryParameters: query);
  }

  Future<dynamic> getJson(String path, {Map<String, String>? query}) async {
    final uri = _uri(path, query);
    http.Response response;
    try {
      debugPrint('ApiClient: GET $uri');
      response = await _client.get(uri).timeout(_timeout);
    } on SocketException catch (e) {
      throw ApiException('No internet connection reaching $path ($e)');
    } on HttpException catch (e) {
      throw ApiException('HTTP error calling $path ($e)');
    } on FormatException catch (e) {
      throw ApiException('Malformed response from $path ($e)');
    } on TimeoutException catch (e) {
      throw ApiException('Request to $path timed out ($e)');
    } catch (e) {
      throw ApiException('Failed to reach $path: $e');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      debugPrint('ApiClient: Error status ${response.statusCode} for $uri');
      throw ApiException('Request to $path failed', statusCode: response.statusCode);
    }

    try {
      final body = utf8.decode(response.bodyBytes);
      return jsonDecode(body);
    } catch (e) {
      debugPrint('ApiClient: JSON decode error for $uri: $e');
      throw ApiException('Could not parse response from $path: $e');
    }
  }

  Future<List<dynamic>> getList(String path, {Map<String, String>? query}) async {
    final data = await getJson(path, query: query);
    if (data is List) return data;
    throw ApiException('Expected a list from $path but got ${data.runtimeType}');
  }

  Future<Map<String, dynamic>> getMap(String path, {Map<String, String>? query}) async {
    final data = await getJson(path, query: query);
    if (data is Map<String, dynamic>) return data;
    throw ApiException('Expected an object from $path but got ${data.runtimeType}');
  }
}
