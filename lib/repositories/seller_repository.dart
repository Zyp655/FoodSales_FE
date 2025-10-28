import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cnpm_ptpm/models/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cnpm_ptpm/models/order.dart';

class SellerRepository {
  final String _baseUrl = 'http://10.0.2.2:8000/api';

  Map<String, String> _getAuthHeaders(String token, {bool isMultipart = false}) {
    var headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
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

  Future<List<Order>> getSellerOrders(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/seller/orders/'),
        headers: _getAuthHeaders(token),
      );
      dynamic responseBody = _handleResponse(response);

      if (responseBody is Map && responseBody.containsKey('orders') && responseBody['orders'] is List) {
        List<dynamic> orderList = responseBody['orders'];
        return orderList.map((data) => Order.fromMap(data)).toList();
      }
      return [];
    } catch (e) {
      print('getSellerOrders error: $e');
      return [];
    }
  }

  Future<List<Product>> getProductsBySeller(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/seller/product/'),
        headers: _getAuthHeaders(token),
      );
      dynamic responseBody = _handleResponse(response);

      print('DEBUG: Raw responseBody from /seller/product/: $responseBody');

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
      print('getProductsBySeller error: $e');
      return [];
    }
  }

  Future<Product> addProduct(
      String token, Product product, XFile? imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/seller/product/add'),
      );

      request.headers.addAll(_getAuthHeaders(token, isMultipart: true));

      request.fields['name'] = product.name ?? '';
      request.fields['price_per_kg'] = product.pricePerKg?.toString() ?? '0';
      request.fields['description'] = product.description ?? '';
      request.fields['category_id'] = product.categoryId?.toString() ?? '1';

      if (imageFile != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      dynamic responseBody = _handleResponse(response);
      if (responseBody is Map && responseBody.containsKey('product')) {
        return Product.fromMap(responseBody['product'] as Map<String, dynamic>);
      }
      throw Exception('Invalid response format after adding product');

    } catch (e) {
      print('addProduct error: $e');
      rethrow;
    }
  }

  Future<Order> updateSellerOrderStatus(String token, int orderId, String status) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/seller/orders/$orderId/status'),
        headers: _getAuthHeaders(token),
        body: json.encode({'status': status}),
      );
      dynamic responseBody = _handleResponse(response);
      if (responseBody is Map && responseBody.containsKey('order')) {
        return Order.fromMap(responseBody['order'] as Map<String, dynamic>);
      }
      throw Exception('Invalid response format after updating order status');
    } catch (e) {
      print('updateSellerOrderStatus error: $e');
      rethrow;
    }
  }

  Future<Product> updateProduct(
      String token, int productId, Product product, XFile? imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/seller/product/$productId'),
      );

      request.headers.addAll(_getAuthHeaders(token, isMultipart: true));

      request.fields['_method'] = 'PUT';

      request.fields['name'] = product.name ?? '';
      request.fields['price_per_kg'] = product.pricePerKg?.toString() ?? '0';
      request.fields['description'] = product.description ?? '';
      request.fields['category_id'] = product.categoryId?.toString() ?? '1';

      if (imageFile != null) {
        request.files
            .add(await http.MultipartFile.fromPath('image', imageFile.path));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      dynamic responseBody = _handleResponse(response);
      if (responseBody is Map && responseBody.containsKey('product')) {
        return Product.fromMap(responseBody['product'] as Map<String, dynamic>);
      }
      throw Exception('Invalid response format after updating product');
    } catch (e) {
      print('updateProduct error: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String token, int productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/seller/product/$productId'),
        headers: _getAuthHeaders(token),
      );
      _handleResponse(response);
    } catch (e) {
      print('deleteProduct error: $e');
      rethrow;
    }
  }
}