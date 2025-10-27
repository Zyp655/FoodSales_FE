import 'dart:convert';
import '../models/seller.dart';
import 'package:http/http.dart' as http;
import 'package:cnpm_ptpm/models/user.dart';

class AuthRepository {
  final String _baseUrl = 'http://10.0.2.2:8000/api';

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
      try {
        final decoded = json.decode(response.body);
        if (decoded is Map) {
          return decoded.cast<String, dynamic>();
        } else if (decoded is List) {
          return decoded;
        }
        return decoded;
      } catch (e) {
        print('API Error: Failed to decode JSON response - ${response.body}');
        throw Exception('Invalid JSON response from server.');
      }
    } else {
      print('API Error: ${response.statusCode} - ${response.body}');
      String errorMessage = 'API error: ${response.statusCode}';
      try {
        var decodedError = json.decode(response.body);
        if (decodedError is Map && decodedError.containsKey('message')) {
          errorMessage = decodedError['message'];
        } else {
          errorMessage = response.body;
        }
      } catch (_) {
        errorMessage = response.body;
      }
      throw Exception(errorMessage);
    }
  }

  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}),
      );
      dynamic responseBody = _handleResponse(response);
      if (responseBody == null ||
          responseBody is! Map<String, dynamic> ||
          !responseBody.containsKey('user')) {
        throw Exception('Invalid login response format.');
      }
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(userData),
      );
      dynamic responseBody = _handleResponse(response);
      if (responseBody == null ||
          responseBody is! Map<String, dynamic> ||
          !responseBody.containsKey('user')) {
        throw Exception('Invalid register response format.');
      }
      return User.fromMap(responseBody);
    } catch (e) {
      print('registerUser error: $e');
      rethrow;
    }
  }

  Future<User> updateUserAddress(String token, String newAddress) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/user/address'),
        headers: _getAuthHeaders(token),
        body: json.encode({'address': newAddress}),
      );
      print('DEBUG: Update Address Status Code: ${response.statusCode}');
      print('DEBUG: Update Address Response Body: ${response.body}');
      dynamic responseBody = _handleResponse(response);
      if (responseBody == null ||
          responseBody is! Map<String, dynamic> ||
          !responseBody.containsKey('user')) {
        throw Exception('Invalid update address response format.');
      }
      return User.fromMap(responseBody);
    } catch (e) {
      print('updateUserAddress error: $e');
      rethrow;
    }
  }

  Future<User> updateContact(
    String token, {
    String? phone,
    String? address,
  }) async {
    try {
      Map<String, dynamic> body = {};
      if (phone != null) {
        body['phone'] = phone;
      }
      if (address != null) {
        body['address'] = address;
      }

      if (body.isEmpty) {
        return getAuthenticatedUser(token);
      }

      final response = await http.put(
        Uri.parse('$_baseUrl/user/contact'),
        headers: _getAuthHeaders(token),
        body: json.encode(body),
      );
      print('DEBUG: Update Contact Status Code: ${response.statusCode}');
      print('DEBUG: Update Contact Response Body: ${response.body}');
      dynamic responseBody = _handleResponse(response);
      if (responseBody == null ||
          responseBody is! Map<String, dynamic> ||
          !responseBody.containsKey('user')) {
        throw Exception('Invalid update contact response format.');
      }
      return User.fromMap(responseBody);
    } catch (e) {
      print('updateContact error: $e');
      rethrow;
    }
  }

  Future<void> changePassword(
    String token,
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/user/password'),
        headers: _getAuthHeaders(token),
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        }),
      );
      print('DEBUG: Change Password Status Code: ${response.statusCode}');
      print('DEBUG: Change Password Response Body: ${response.body}');
      _handleResponse(response);
    } catch (e) {
      print('changePassword error: $e');
      rethrow;
    }
  }

  Future<Seller> registerSeller(Map<String, dynamic> sellerData) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register/seller'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(sellerData),
      );
      dynamic responseBody = _handleResponse(response);
      if (responseBody == null ||
          responseBody is! Map<String, dynamic> ||
          !responseBody.containsKey('seller')) {
        throw Exception('Invalid register seller response format.');
      }
      return Seller.fromMap(responseBody['seller'] as Map<String, dynamic>);
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
      if (responseBody == null || responseBody is! Map) {
        throw Exception('Invalid authenticated user response format.');
      }
      return User.fromMap(responseBody as Map<String, dynamic>);
    } catch (e) {
      print('getAuthenticatedUser error: $e');
      rethrow;
    }
  }
}
