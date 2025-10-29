import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cnpm_ptpm/models/order.dart';

class DeliveryRepository {
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
      if (response.body.isEmpty) return null;
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

  Future<List<Order>> deliveryGetAssignedOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/delivery/orders'),
        headers: _getAuthHeaders(token),
      );
      dynamic responseBody = _handleResponse(response);
      if (responseBody is Map && responseBody.containsKey('orders') && responseBody['orders'] is List) {
        List<dynamic> orderList = responseBody['orders'];
        return orderList.map((data) => Order.fromMap(data)).toList();
      }
      return [];
    } catch (e) {
      print('deliveryGetAssignedOrders error: $e');
      return [];
    }
  }

  Future<Order> deliveryUpdateDeliveryStatus(
      String token, int orderId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/delivery/orders/$orderId/status'),
        headers: _getAuthHeaders(token),
        body: json.encode({'status': status}),
      );
      dynamic responseBody = _handleResponse(response);
      if (responseBody is Map && responseBody.containsKey('order')) {
        return Order.fromMap(responseBody['order'] as Map<String, dynamic>);
      }
      throw Exception('Invalid response format after updating order status');
    } catch (e) {
      print('deliveryUpdateDeliveryStatus error: $e');
      rethrow;
    }
  }

  Future<List<Order>> getAvailableOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/delivery/available-orders'),
        headers: _getAuthHeaders(token),
      );
      dynamic responseBody = _handleResponse(response);
      if (responseBody is Map && responseBody.containsKey('orders') && responseBody['orders'] is List) {
        List<dynamic> orderList = responseBody['orders'];
        return orderList.map((data) => Order.fromMap(data)).toList();
      }
      return [];
    } catch (e) {
      print('getAvailableOrders error: $e');
      return [];
    }
  }

  Future<Order> acceptOrder(String token, int orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/delivery/orders/$orderId/accept'),
        headers: _getAuthHeaders(token),
      );
      dynamic responseBody = _handleResponse(response);
      if (responseBody is Map && responseBody.containsKey('order')) {
        return Order.fromMap(responseBody['order'] as Map<String, dynamic>);
      }
      throw Exception(responseBody['message'] ?? 'Failed to accept order');
    } catch (e) {
      print('acceptOrder error: $e');
      rethrow;
    }
  }
}