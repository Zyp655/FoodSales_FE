import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cnpm_ptpm/models/product.dart';
import 'package:cnpm_ptpm/models/user.dart';
import 'package:cnpm_ptpm/models/order.dart';
import '../models/delivery_ticket.dart';
import '../models/seller.dart';
import 'base_repository.dart';

class AdminRepository extends BaseRepository {
  Future<List<Order>> adminGetAllOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/orders'),
        headers: getAuthHeaders(token),
      );
      dynamic responseBody = handleResponse(response);

      List<dynamic> orderList = [];
      if (responseBody is Map && responseBody.containsKey('orders')) {
        if (responseBody['orders'] is Map &&
            responseBody['orders'].containsKey('data')) {
          orderList = responseBody['orders']['data'];
        } else if (responseBody['orders'] is List) {
          orderList = responseBody['orders'];
        }
      }
      return orderList.map((data) => Order.fromMap(data)).toList();
    } catch (e) {
      print('adminGetAllOrders error: $e');
      return [];
    }
  }

  Future<List<Seller>> adminListAllSellers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/sellers'),
        headers: getAuthHeaders(token),
      );
      dynamic responseBody = handleResponse(response);

      List<dynamic> sellerList = [];
      if (responseBody is Map && responseBody.containsKey('data')) {
        if (responseBody['data'] is Map &&
            responseBody['data'].containsKey('data')) {
          sellerList = responseBody['data']['data'];
        } else if (responseBody['data'] is List) {
          sellerList = responseBody['data'];
        }
      } else if (responseBody is List) {
        sellerList = responseBody;
      }

      return sellerList.map((data) => Seller.fromMap(data)).toList();
    } catch (e) {
      print('adminListAllSellers error: $e');
      rethrow;
    }
  }

  Future<List<DeliveryTicket>> adminGetAllDeliveryTickets(
      String token, {
        String status = 'pending',
      }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl/admin/delivery-tickets',
      ).replace(queryParameters: {'status': status});
      final response = await http.get(uri, headers: getAuthHeaders(token));
      dynamic responseBody = handleResponse(response);

      if (responseBody is Map &&
          responseBody.containsKey('tickets') &&
          responseBody['tickets'] is Map &&
          responseBody['tickets'].containsKey('data')) {
        List<dynamic> ticketList = responseBody['tickets']['data'];
        return ticketList.map((data) => DeliveryTicket.fromMap(data)).toList();
      } else if (responseBody is Map &&
          responseBody.containsKey('tickets') &&
          responseBody['tickets'] is List) {
        List<dynamic> ticketList = responseBody['tickets'];
        return ticketList.map((data) => DeliveryTicket.fromMap(data)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<DeliveryTicket> adminUpdateDeliveryTicketStatus(
      String token, int ticketId, String newStatus) async {
    if (newStatus != 'approved' && newStatus != 'rejected') {
      throw Exception('Invalid status. Must be "approved" or "rejected".');
    }
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/delivery-tickets/$ticketId/status'),
        headers: getAuthHeaders(token),
        body: json.encode({'status': newStatus}),
      );
      dynamic responseBody = handleResponse(response);

      if (responseBody is Map && responseBody.containsKey('ticket')) {
        return DeliveryTicket.fromMap(
            responseBody['ticket'] as Map<String, dynamic>);
      }
      throw Exception('Invalid response format after updating ticket status');
    } catch (e) {
      rethrow;
    }
  }

  Future<Seller> adminUpdateSellerStatus(
      String token,
      int sellerId,
      String status,
      ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/sellers/$sellerId/status'),
        headers: getAuthHeaders(token),
        body: json.encode({'status': status}),
      );
      dynamic responseBody = handleResponse(response);
      return Seller.fromMap(responseBody['seller'] ?? responseBody);
    } catch (e) {
      print('adminUpdateSellerStatus error: $e');
      rethrow;
    }
  }

  Future<List<User>> adminListAllUsers(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/users'),
        headers: getAuthHeaders(token),
      );
      dynamic responseBody = handleResponse(response);

      List<dynamic> userList = [];
      if (responseBody is Map && responseBody.containsKey('data')) {
        if (responseBody['data'] is Map &&
            responseBody['data'].containsKey('data')) {
          userList = responseBody['data']['data'];
        } else if (responseBody['data'] is List) {
          userList = responseBody['data'];
        }
      } else if (responseBody is List) {
        userList = responseBody;
      }

      return userList.map((data) => User.fromMap(data)).toList();
    } catch (e) {
      print('adminListAllUsers error: $e');
      rethrow;
    }
  }

  Future<User> adminUpdateUserRole(
      String token,
      int userId,
      String role,
      ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/users/$userId/role'),
        headers: getAuthHeaders(token),
        body: json.encode({'role': role}),
      );
      dynamic responseBody = handleResponse(response);
      return User.fromMap(responseBody['user'] ?? responseBody);
    } catch (e) {
      print('adminUpdateUserRole error: $e');
      rethrow;
    }
  }

  Future<List<Product>> adminListAllProducts(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/products'),
        headers: getAuthHeaders(token),
      );
      dynamic responseBody = handleResponse(response);
      if (responseBody is Map &&
          responseBody.containsKey('data') &&
          responseBody['data'] is List) {
        List<dynamic> productList = responseBody['data'];
        return productList.map((data) => Product.fromMap(data)).toList();
      } else if (responseBody is List) {
        return responseBody.map((data) => Product.fromMap(data)).toList();
      }
      return [];
    } catch (e) {
      print('adminListAllProducts error: $e');
      rethrow;
    }
  }

  Future<void> adminDestroyProduct(String token, int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/admin/products/$productId'),
        headers: getAuthHeaders(token),
      );
      handleResponse(response);
    } catch (e) {
      print('adminDestroyProduct error: $e');
      rethrow;
    }
  }

  Future<Order> adminAssignDriver(
      String token,
      int orderId,
      int driverId,
      ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/orders/$orderId/assign-driver'),
        headers: getAuthHeaders(token),
        body: json.encode({'driver_id': driverId}),
      );
      dynamic responseBody = handleResponse(response);
      return Order.fromMap(responseBody['order'] ?? responseBody);
    } catch (e) {
      print('adminAssignDriver error: $e');
      rethrow;
    }
  }
}