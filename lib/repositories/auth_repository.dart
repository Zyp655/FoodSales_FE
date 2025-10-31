import 'dart:convert';
import '../models/seller.dart';
import 'package:http/http.dart' as http;
import 'package:cnpm_ptpm/models/user.dart';
import 'package:image_picker/image_picker.dart';
import 'base_repository.dart';

class AuthRepository extends BaseRepository {
  Future<User> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({'email': email, 'password': password}),
      );
      dynamic responseBody = handleResponse(response);
      if (responseBody == null ||
          responseBody is! Map ||
          !responseBody.containsKey('user')) {
        throw Exception('Invalid login response format.');
      }
      return User.fromMap(responseBody as Map<String, dynamic>);
    } catch (e) {
      print('login error: $e');
      rethrow;
    }
  }

  Future<User> registerUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(userData),
      );
      dynamic responseBody = handleResponse(response);
      if (responseBody == null ||
          responseBody is! Map ||
          !responseBody.containsKey('user')) {
        throw Exception('Invalid register response format.');
      }
      return User.fromMap(responseBody as Map<String, dynamic>);
    } catch (e) {
      print('registerUser error: $e');
      rethrow;
    }
  }

  Future<User> updateUserAddress(String token, String newAddress) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/address'),
        headers: getAuthHeaders(token),
        body: json.encode({'address': newAddress}),
      );
      dynamic responseBody = handleResponse(response);
      if (responseBody == null ||
          responseBody is! Map ||
          !responseBody.containsKey('user')) {
        throw Exception('Invalid update address response format.');
      }
      return User.fromMap(responseBody as Map<String, dynamic>);
    } catch (e) {
      print('updateUserAddress error: $e');
      rethrow;
    }
  }

  Future<User> updateProfile(
    String token, {
    String? name,
    String? phone,
    String? address,
  }) async {
    try {
      Map<String, dynamic> body = {};
      if (name != null) body['name'] = name;
      if (phone != null) body['phone'] = phone;
      if (body.isEmpty) return getAuthenticatedUser(token);

      final response = await http.put(
        Uri.parse('$baseUrl/user/profile'),
        headers: getAuthHeaders(token),
        body: json.encode(body),
      );
      dynamic responseBody = handleResponse(response);
      if (responseBody == null ||
          responseBody is! Map ||
          !responseBody.containsKey('user')) {
        throw Exception('Invalid update profile response format.');
      }
      return User.fromMap(responseBody as Map<String, dynamic>);
    } catch (e) {
      print('updateProfile error: $e');
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
        Uri.parse('$baseUrl/user/password'),
        headers: getAuthHeaders(token),
        body: json.encode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        }),
      );
      handleResponse(response);
    } catch (e) {
      print('changePassword error: $e');
      rethrow;
    }
  }

  Future<User> updateSellerInfo(
    String token, {
    required String name,
    required String email,
    required String? phone,
    required String address,
    required String description,
    XFile? imageFile,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/seller/info'),
      );

      request.headers.addAll(getAuthHeaders(token, isMultipart: true));

      request.fields['_method'] = 'PUT';
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['address'] = address;
      request.fields['description'] = description;
      if (phone != null && phone.isNotEmpty) {
        request.fields['phone'] = phone;
      }

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('DEBUG: Update Seller Info Status Code: ${response.statusCode}');
      print('DEBUG: Update Seller Info Response Body: ${response.body}');

      dynamic responseBody = handleResponse(response);
      if (responseBody == null ||
          responseBody is! Map ||
          !responseBody.containsKey('user')) {
        throw Exception('Invalid update seller info response format.');
      }
      return User.fromMap(responseBody as Map<String, dynamic>);
    } catch (e) {
      print('updateSellerInfo error: $e');
      rethrow;
    }
  }

  Future<Seller> registerSeller(Map<String, dynamic> sellerData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register/seller'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(sellerData),
      );
      dynamic responseBody = handleResponse(response);
      if (responseBody == null ||
          responseBody is! Map ||
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
        Uri.parse('$baseUrl/auth/logout'),
        headers: getAuthHeaders(token),
      );
      handleResponse(response);
    } catch (e) {
      print('logout error: $e');
      rethrow;
    }
  }

  Future<User> getAuthenticatedUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: getAuthHeaders(token),
      );
      dynamic responseBody = handleResponse(response);
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
