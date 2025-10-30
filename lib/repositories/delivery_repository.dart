import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cnpm_ptpm/models/order.dart';
import 'base_repository.dart';
class DeliveryRepository extends BaseRepository {

  Future<List<Order>> deliveryGetAssignedOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/delivery/orders'),
        headers: getAuthHeaders(token),
      );
      dynamic responseBody = handleResponse(response);
      if (responseBody is Map &&
          responseBody.containsKey('orders') &&
          responseBody['orders'] is List) {
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
    String token,
    int orderId,
    String status,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/delivery/orders/$orderId/status'),
        headers: getAuthHeaders(token),
        body: json.encode({'status': status}),
      );
      dynamic responseBody = handleResponse(response);
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
        Uri.parse('$baseUrl/delivery/available-orders'),
        headers: getAuthHeaders(token),
      );
      dynamic responseBody = handleResponse(response);
      if (responseBody is Map &&
          responseBody.containsKey('orders') &&
          responseBody['orders'] is List) {
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
        Uri.parse('$baseUrl/delivery/orders/$orderId/accept'),
        headers: getAuthHeaders(token),
      );
      dynamic responseBody = handleResponse(response);
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
