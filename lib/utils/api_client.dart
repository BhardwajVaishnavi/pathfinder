import 'dart:convert';
import 'package:http/http.dart' as http;

enum HttpMethod { get, post, put, delete, patch }

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final int statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.error,
    required this.statusCode,
  });
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  final String baseUrl = ''; // Set your API base URL here if needed
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal();

  void setAuthToken(String token) {
    _headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    _headers.remove('Authorization');
  }

  Future<ApiResponse<T>> request<T>({
    required String endpoint,
    required HttpMethod method,
    Map<String, dynamic>? queryParams,
    dynamic body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    final Uri uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParams,
    );

    final Map<String, String> requestHeaders = {..._headers};
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    http.Response response;

    try {
      switch (method) {
        case HttpMethod.get:
          response = await http.get(uri, headers: requestHeaders);
          break;
        case HttpMethod.post:
          response = await http.post(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case HttpMethod.put:
          response = await http.put(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case HttpMethod.delete:
          response = await http.delete(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case HttpMethod.patch:
          response = await http.patch(
            uri,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return ApiResponse<T>(
            success: true,
            statusCode: response.statusCode,
          );
        }

        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        
        if (fromJson != null) {
          final T data = fromJson(jsonResponse);
          return ApiResponse<T>(
            success: true,
            data: data,
            statusCode: response.statusCode,
          );
        } else {
          return ApiResponse<T>(
            success: true,
            data: jsonResponse as T,
            statusCode: response.statusCode,
          );
        }
      } else {
        String errorMessage;
        try {
          final Map<String, dynamic> errorResponse = jsonDecode(response.body);
          errorMessage = errorResponse['message'] ?? errorResponse['error'] ?? 'Unknown error';
        } catch (e) {
          errorMessage = 'Error: ${response.statusCode}';
        }

        return ApiResponse<T>(
          success: false,
          error: errorMessage,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse<T>(
        success: false,
        error: 'Network error: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
}
