import 'dart:convert';

import '../models/seller.dart';
import 'package:http/http.dart' as http;
import 'package:cnpm_ptpm/models/user.dart';

class AuthRepository {
  final String _baseUrl = 'http://10.0.2.2/FOODSALES_BE/api';

  Map<String, String> _getAuthHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return json.decode(response.body);
    } else {
      print('API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Lỗi API: ${response.statusCode}, ${response.body}');
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );
      dynamic responseBody = _handleResponse(response);
      return User.fromMap(responseBody);
    } catch (e) {
      print('login error: $e');
      rethrow;
    }
  }

  Future<User> registerUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register/user'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode(userData),
      );
      dynamic responseBody = _handleResponse(response);
      return User.fromMap(responseBody);
    } catch (e) {
      print('registerUser error: $e');
      rethrow;
    }
  }

  Future<Seller> registerSeller(Map<String, dynamic> sellerData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register/seller'),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: json.encode(sellerData),
      );
      dynamic responseBody = _handleResponse(response);
      return Seller.fromMap(responseBody);
    } catch (e) {
      print('registerSeller error: $e');
      rethrow;
    }
  }

  Future<void> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/logout'),
        headers: _getAuthHeaders(token),
      );
      _handleResponse(response);
    } catch (e) {
      print('logout error: $e');
      rethrow;
    }
  }

  Future<User> getAuthenticatedUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/user'),
        headers: _getAuthHeaders(token),
      );
      dynamic responseBody = _handleResponse(response);
      return User.fromMap(responseBody);
    } catch (e) {
      print('getAuthenticatedUser error: $e');
      rethrow;
    }
  }
}