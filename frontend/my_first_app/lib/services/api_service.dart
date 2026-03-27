import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models.dart';
import '../utils/api_config.dart';
import '../utils/session_manager.dart';

class ApiResult<T> {
  final T? data;
  final String? error;
  bool get success => error == null && data != null;

  const ApiResult.ok(this.data) : error = null;
  const ApiResult.err(this.error) : data = null;
}

class ApiService {
  static Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await SessionManager.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static ApiResult<Map<String, dynamic>> _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      try {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        return ApiResult.ok(body);
      } catch (_) {
        return const ApiResult.err('Invalid response from server');
      }
    }

    try {
      final body = jsonDecode(res.body);
      final detail = body['detail'];
      if (detail is String) return ApiResult.err(detail);
      if (detail is List && detail.isNotEmpty) {
        return ApiResult.err(detail.first['msg'] ?? 'Validation error');
      }
    } catch (_) {}

    return ApiResult.err('Server error (${res.statusCode})');
  }

  static Future<ApiResult<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl$kEndpointLogin'),
        headers: await _headers(),
        body: jsonEncode({'email': email, 'password': password}),
      );
      final result = _handle(res);
      if (result.success) {
        final token = result.data!['access_token'] as String?;
        final name = result.data!['user']?['name'] as String? ?? 'Parent';
        if (token != null) {
          await SessionManager.saveToken(token);
          await SessionManager.saveUserName(name);
        }
      }
      return result;
    } catch (e) {
      return ApiResult.err('Cannot connect to server. Check your network.');
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl$kEndpointSignup'),
        headers: await _headers(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );
      final result = _handle(res);
      if (result.success) {
        final token = result.data!['access_token'] as String?;
        if (token != null) {
          await SessionManager.saveToken(token);
          await SessionManager.saveUserName(name);
        }
      }
      return result;
    } catch (e) {
      return ApiResult.err('Cannot connect to server. Check your network.');
    }
  }

  static Future<void> logout() async {
    try {
      final headers = await _headers(auth: true);
      await http.post(Uri.parse('$kBaseUrl$kEndpointLogout'), headers: headers);
    } catch (_) {}
    await SessionManager.clearToken();
  }

  static Future<ApiResult<List<ChildModel>>> fetchChildren() async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl$kEndpointChildren'),
        headers: await _headers(auth: true),
      );
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        final children = list
            .map((json) => ChildModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return ApiResult.ok(children);
      }
      return ApiResult.err('Failed to load children (${res.statusCode})');
    } catch (e) {
      return ApiResult.err('Cannot connect to server.');
    }
  }

  static Future<ApiResult<Map<String, dynamic>>> addChild(
      Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('$kBaseUrl$kEndpointChildren'),
        headers: await _headers(auth: true),
        body: jsonEncode(data),
      );
      return _handle(res);
    } catch (e) {
      return ApiResult.err('Cannot connect to server.');
    }
  }

  static Future<ApiResult<List<Map<String, dynamic>>>> fetchAlerts() async {
    try {
      final res = await http.get(
        Uri.parse('$kBaseUrl$kEndpointAlerts'),
        headers: await _headers(auth: true),
      );
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body) as List<dynamic>;
        return ApiResult.ok(list.cast<Map<String, dynamic>>());
      }
      return ApiResult.err('Failed to load alerts (${res.statusCode})');
    } catch (e) {
      return ApiResult.err('Cannot connect to server.');
    }
  }
}
