import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/api/api_constants.dart';

class AuthApiService {
  final String _authUrl = "${ApiConstants.baseUrl}/auth";

  /// Sends login credentials and returns the token map
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_authUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Expected: {"token": "..."}
      } else if (response.statusCode == 403) {
        throw Exception("Invalid username or password");
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Connection failed: $e");
    }
  }

  /// Registers a new user
  Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_authUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'role': 'USER', // Default role for app signups
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data;
      } else {
        throw data['message'] ?? "Registration failed";
      }
    } catch (e) {
      throw e.toString();
    }
  }
}