import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:physical_activity_log_app/dtos/error_response_dto.dart';
import 'package:physical_activity_log_app/exceptions/api_exception.dart';

class HttpService {
  final http.Client _client;

  HttpService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _handleResponse(
      await _client.post(
        Uri.parse(url),
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    return _handleResponse(
      await _client.get(
        Uri.parse(url),
        headers: _buildHeaders(headers),
      ),
    );
  }

  Future<List<dynamic>> getList(
    String url, {
    Map<String, String>? headers,
  }) async {
    return _handleListResponse(
      await _client.get(
        Uri.parse(url),
        headers: _buildHeaders(headers),
      ),
    );
  }

  Future<Map<String, dynamic>> put(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _handleResponse(
      await _client.put(
        Uri.parse(url),
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      ),
    );
  }

  Future<void> delete(
    String url, {
    Map<String, String>? headers,
  }) async {
    final response = await _client.delete(
      Uri.parse(url),
      headers: _buildHeaders(headers),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw _parseError(response);
  }

  Map<String, String> _buildHeaders(Map<String, String>? headers) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw _parseError(response);
  }

  Future<List<dynamic>> _handleListResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return [];
      }
      return jsonDecode(response.body) as List<dynamic>;
    }

    throw _parseError(response);
  }

  ApiException _parseError(http.Response response) {
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final error = ErrorResponseDto.fromJson(json);
      return ApiException(
        message: error.message,
        statusCode: response.statusCode,
      );
    } catch (_) {
      if (response.statusCode >= 500) {
        return ApiException(
          message: 'Error del servidor. Intenta de nuevo más tarde.',
          statusCode: response.statusCode,
        );
      }
      return ApiException(
        message: 'Ocurrió un error inesperado. Intenta de nuevo.',
        statusCode: response.statusCode,
      );
    }
  }

  void dispose() => _client.close();
}
