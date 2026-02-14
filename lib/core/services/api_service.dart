import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  String? _accessToken;
  String? _refreshToken;

  void setTokens(String access, String refresh) {
    _accessToken = access;
    _refreshToken = refresh;
  }

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  bool get isAuthenticated => _accessToken != null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      };

  Future<dynamic> get(String path,
      {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path')
        .replace(queryParameters: queryParams);
    final response = await http
        .get(uri, headers: _headers)
        .timeout(AppConfig.connectionTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> post(String path,
      {Map<String, dynamic>? body, Map<String, String>? queryParams}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path')
        .replace(queryParameters: queryParams);
    final response = await http
        .post(
          uri,
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(AppConfig.connectionTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> put(String path,
      {Map<String, dynamic>? body, Map<String, String>? queryParams}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path')
        .replace(queryParameters: queryParams);
    final response = await http
        .put(
          uri,
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(AppConfig.connectionTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> delete(String path, {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path')
        .replace(queryParameters: queryParams);
    final response = await http
        .delete(uri, headers: _headers)
        .timeout(AppConfig.connectionTimeout);
    return _handleResponse(response);
  }

  Future<dynamic> uploadFile(String path, String filePath) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path');
    final request = http.MultipartRequest('POST', uri);
    
    if (_accessToken != null) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }
    
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    
    final streamedResponse = await request.send().timeout(AppConfig.connectionTimeout);
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  Future<List<dynamic>> getList(String path,
      {Map<String, String>? queryParams}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path')
        .replace(queryParameters: queryParams);
    final response = await http
        .get(uri, headers: _headers)
        .timeout(AppConfig.connectionTimeout);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>;
    }
    throw Exception('API Error: ${response.statusCode}');
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return jsonDecode(utf8.decode(response.bodyBytes));
    }
    final error = response.body.isNotEmpty
        ? jsonDecode(utf8.decode(response.bodyBytes))
        : {'error': 'Server returned status ${response.statusCode} with empty body'};
    throw Exception(error['error'] ?? 'API Error: ${response.statusCode}');
  }
}
