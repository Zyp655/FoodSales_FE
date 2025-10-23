import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cnpm_ptpm/models/order.dart';

class DeliveryRepository {
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

  Future<List<Order>> deliveryGetAssignedOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/delivery/orders'),
        headers: _getAuthHeaders(token),
      );
      dynamic responseBody = _handleResponse(response);
      List<dynamic> orderList = responseBody;
      return orderList.map((data) => Order.fromMap(data)).toList();
    } catch (e) {
      print('deliveryGetAssignedOrders error: $e');
      rethrow;
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
      return Order.fromMap(responseBody);
    } catch (e) {
      print('deliveryUpdateDeliveryStatus error: $e');
      rethrow;
    }
  }
}