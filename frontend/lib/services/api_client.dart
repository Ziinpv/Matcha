import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ApiClient {
  static String baseUrl = const String.fromEnvironment('BACKEND_BASE_URL', defaultValue: 'http://10.0.2.2:4000');
  // For physical device over USB on same LAN, replace with your machine LAN IP, e.g. http://192.168.1.10:4000
  // For LDPlayer or other emulators, try: http://127.0.0.1:4000 or your machine's LAN IP

  static const Duration _timeout = Duration(seconds: 10);

  static String? _token;

  static void setToken(String token) {
    _token = token;
  }

  static Future<http.Response> post(String path, Map<String, dynamic> body, {bool auth = true}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (auth && _token != null) 'Authorization': 'Bearer $_token',
    };
    try {
      return await http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(_timeout, onTimeout: () {
        throw TimeoutException('Connection timed out after ${_timeout.inSeconds}s');
      });
    } on TimeoutException {
      rethrow;
    } on Exception catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<http.Response> get(String path, {bool auth = true}) async {
    final uri = Uri.parse('$baseUrl$path');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (auth && _token != null) 'Authorization': 'Bearer $_token',
    };
    try {
      return await http
          .get(uri, headers: headers)
          .timeout(_timeout, onTimeout: () {
        throw TimeoutException('Connection timed out after ${_timeout.inSeconds}s');
      });
    } on TimeoutException {
      rethrow;
    } on Exception catch (e) {
      throw Exception('Network error: $e');
    }
  }
}


