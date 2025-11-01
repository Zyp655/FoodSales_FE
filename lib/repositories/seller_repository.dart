import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cnpm_ptpm/models/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cnpm_ptpm/models/order.dart';
import '../models/seller_analytics.dart';
import 'base_repository.dart';

class SellerRepository extends BaseRepository {
  Future<List<Order>> getSellerOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/seller/orders/'),
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
      rethrow;
    }
  }

  Future<List<Product>> getProductsBySeller(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/seller/product/'),
        headers: getAuthHeaders(token),
      );
      dynamic responseBody = handleResponse(response);

      if (responseBody is Map && responseBody.containsKey('data')) {
        if (responseBody['data'] is List) {
          List<dynamic> productList = responseBody['data'];
          return productList.map((data) => Product.fromMap(data)).toList();
        }
      } else if (responseBody is List) {
        List<dynamic> productList = responseBody;
        return productList.map((data) => Product.fromMap(data)).toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> addProduct(
      String token,
      Product product,
      XFile? imageFile,
      ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/seller/product/add'),
      );

      request.headers.addAll(getAuthHeaders(token, isMultipart: true));

      request.fields['name'] = product.name ?? '';
      request.fields['price_per_kg'] = product.pricePerKg?.toString() ?? '0';
      request.fields['description'] = product.description ?? '';
      request.fields['category_id'] = product.categoryId?.toString() ?? '1';

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      dynamic responseBody = handleResponse(response);
      if (responseBody is Map && responseBody.containsKey('product')) {
        return Product.fromMap(responseBody['product'] as Map<String, dynamic>);
      }
      throw Exception('Invalid response format after adding product');
    } catch (e) {
      rethrow;
    }
  }

  Future<Order> updateSellerOrderStatus(
      String token,
      int orderId,
      String status,
      ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/seller/orders/$orderId/status'),
        headers: getAuthHeaders(token),
        body: json.encode({'status': status}),
      );
      dynamic responseBody = handleResponse(response);
      if (responseBody is Map && responseBody.containsKey('order')) {
        return Order.fromMap(responseBody['order'] as Map<String, dynamic>);
      }
      throw Exception('Invalid response format after updating order status');
    } catch (e) {
      rethrow;
    }
  }

  Future<Product> updateProduct(
      String token,
      int productId,
      Product product,
      XFile? imageFile,
      ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/seller/product/$productId'),
      );

      request.headers.addAll(getAuthHeaders(token, isMultipart: true));

      request.fields['_method'] = 'PUT';

      request.fields['name'] = product.name ?? '';
      request.fields['price_per_kg'] = product.pricePerKg?.toString() ?? '0';
      request.fields['description'] = product.description ?? '';
      request.fields['category_id'] = product.categoryId?.toString() ?? '1';

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      dynamic responseBody = handleResponse(response);
      if (responseBody is Map && responseBody.containsKey('product')) {
        return Product.fromMap(responseBody['product'] as Map<String, dynamic>);
      }
      throw Exception('Invalid response format after updating product');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String token, int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/seller/product/$productId'),
        headers: getAuthHeaders(token),
      );
      handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<SellerAnalytics> getAnalytics(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/seller/orders/analytics'),
        headers: getAuthHeaders(token),
      );
      dynamic responseBody = handleResponse(response);
      if (responseBody is Map && responseBody.containsKey('stats')) {
        return SellerAnalytics.fromMap(responseBody['stats']);
      }
      throw Exception('Failed to load seller analytics');
    } catch (e) {
      print('getAnalytics error: $e');
      rethrow;
    }
  }
}