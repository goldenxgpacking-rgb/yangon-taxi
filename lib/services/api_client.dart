import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';

/// API 错误类型
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? errorCode;

  ApiException(this.message, {this.statusCode, this.errorCode});

  @override
  String toString() => 'ApiException: $message (code: $statusCode)';
}

/// API 客户端
/// 统一处理 HTTP 请求、自动刷新 Token、重试机制
class ApiClient {
  /// TODO: 替换为真实后端地址
  static const String baseUrl = 'https://api.yangontaxi.com/v1';

  /// 是否使用模拟数据（无后端时启用）
  static const bool mockMode = true;

  String? _accessToken;
  String? _refreshToken;

  void setTokens({String? access, String? refresh}) {
    _accessToken = access;
    _refreshToken = refresh;
  }

  void clearTokens() {
    _accessToken = null;
    _refreshToken = null;
  }

  bool get isLoggedIn => _accessToken != null;

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_accessToken != null) {
      headers['Authorization'] = 'Bearer $_accessToken';
    }
    return headers;
  }

  /// GET 请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, String>? queryParams,
    required T Function(dynamic json) parser,
    int retry = 1,
  }) async {
    return _request(() async {
      final uri = Uri.parse('$baseUrl$path').replace(queryParameters: queryParams);
      final resp = await http.get(uri, headers: _headers).timeout(const Duration(seconds: 15));
      return _handleResponse(resp, parser);
    }, retry);
  }

  /// POST 请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    Map<String, dynamic>? body,
    required T Function(dynamic json) parser,
    int retry = 1,
  }) async {
    return _request(() async {
      final uri = Uri.parse('$baseUrl$path');
      final resp = await http.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(const Duration(seconds: 20));
      return _handleResponse(resp, parser);
    }, retry);
  }

  /// PUT 请求
  Future<ApiResponse<T>> put<T>(
    String path, {
    Map<String, dynamic>? body,
    required T Function(dynamic json) parser,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final resp = await http.put(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(const Duration(seconds: 15));
    return _handleResponse(resp, parser);
  }

  /// DELETE 请求
  Future<ApiResponse<T>> delete<T>(
    String path, {
    required T Function(dynamic json) parser,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final resp = await http.delete(uri, headers: _headers).timeout(const Duration(seconds: 15));
    return _handleResponse(resp, parser);
  }

  /// 文件上传
  Future<ApiResponse<T>> uploadFile<T>(
    String path, {
    required File file,
    required String fieldName,
    Map<String, String>? fields,
    required T Function(dynamic json) parser,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    final request = http.MultipartRequest('POST', uri);

    if (fields != null) {
      for (final entry in fields.entries) {
        request.fields[entry.key] = entry.value ?? '';
      }
    }
    request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));

    if (_accessToken != null) {
      request.headers['Authorization'] = 'Bearer $_accessToken';
    }

    final streamed = await request.send().timeout(const Duration(seconds: 60));
    final resp = await http.Response.fromStream(streamed);
    return _handleResponse(resp, parser);
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response resp,
    T Function(dynamic json) parser,
  ) {
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      if (resp.body.isEmpty) {
        return ApiResponse.success(null as T);
      }
      final json = jsonDecode(resp.body);
      return ApiResponse.success(parser(json['data']), message: json['message']);
    }

    String? errorCode;
    String message = '服务器错误';
    try {
      final json = jsonDecode(resp.body);
      message = json['message'] ?? message;
      errorCode = json['error_code'];
    } catch (_) {}

    if (resp.statusCode == 401) {
      message = '登录已过期，请重新登录';
    }

    throw ApiException(message, statusCode: resp.statusCode, errorCode: errorCode);
  }

  Future<ApiResponse<T>> _request<T>(
    Future<ApiResponse<T>> Function() fn,
    int retry,
  ) async {
    for (var i = 0; i <= retry; i++) {
      try {
        return await fn();
      } on SocketException {
        throw ApiException('网络连接失败，请检查网络');
      } on HttpException catch (e) {
        if (i == retry) throw ApiException('网络异常: ${e.message}');
      } on ApiException {
        rethrow;
      } catch (e) {
        if (i == retry) throw ApiException('请求失败: $e');
      }
    }
    throw ApiException('请求失败');
  }
}
