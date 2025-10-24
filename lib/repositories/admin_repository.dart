import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cnpm_ptpm/models/product.dart';
import 'package:cnpm_ptpm/models/user.dart';
import 'package:cnpm_ptpm/models/order.dart';

import '../models/seller.dart';

class AdminRepository {
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

  Future<List<Seller>> adminListAllSellers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/sellers'),
        headers: _getAuthHeaders(token),
      );
      dynamic responseBody = _handleResponse(response);
      List<dynamic> sellerList = responseBody;
      return sellerList.map((data) => Seller.fromMap(data)).toList();
    } catch (e) {
      print('adminListAllSellers error: $e');
      rethrow;
    }
  }

  Future<Seller> adminUpdateSellerStatus(
      String token, int sellerId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/sellers/$sellerId/status'),
        headers: _getAuthHeaders(token),
        body: json.encode({'status': status}),
      );
      dynamic responseBody = _handleResponse(response);
      return Seller.fromMap(responseBody);
    } catch (e) {
      print('adminUpdateSellerStatus error: $e');
      rethrow;
    }
  }

  Future<List<User>> adminListAllUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/users'),
        headers: _getAuthHeaders(token),
      );
      dynamic responseBody = _handleResponse(response);
      List<dynamic> userList = responseBody;
      return userList.map((data) => User.fromMap(data)).toList();
    } catch (e) {
      print('adminListAllUsers error: $e');
      rethrow;
    }
  }

  Future<User> adminUpdateUserRole(String token, int userId, String role) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/users/$userId/role'),
        headers: _getAuthHeaders(token),
        body: json.encode({'role': role}),
      );
      dynamic responseBody = _handleResponse(response);
      return User.fromMap(responseBody);
    } catch (e) {
      print('adminUpdateUserRole error: $e');
      rethrow;
    }
  }

  Future<List<Product>> adminListAllProducts(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/admin/products'),
        headers: _getAuthHeaders(token),
      );
      dynamic responseBody = _handleResponse(response);
      List<dynamic> productList = responseBody;
      return productList.map((data) => Product.fromMap(data)).toList();
    } catch (e) {
      print('adminListAllProducts error: $e');
      rethrow;
    }
  }

  Future<void> adminDestroyProduct(String token, int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/admin/products/$productId'),
        headers: _getAuthHeaders(token),
      );
      _handleResponse(response);
    } catch (e) {
      print('adminDestroyProduct error: $e');
      rethrow;
    }
  }

  Future<Order> adminAssignDriver(
      String token, int orderId, int driverId) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/admin/orders/$orderId/assign-driver'),
        headers: _getAuthHeaders(token),
        body: json.encode({'driver_id': driverId}),
      );
      dynamic responseBody = _handleResponse(response);
      return Order.fromMap(responseBody);
    } catch (e) {
      print('adminAssignDriver error: $e');
      rethrow;
    }
  }
}