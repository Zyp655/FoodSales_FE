import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cnpm_ptpm/models/product.dart';
import 'package:cnpm_ptpm/models/seller.dart';
import 'package:cnpm_ptpm/models/cart_item.dart';
import 'package:cnpm_ptpm/models/order.dart';
import 'package:cnpm_ptpm/models/transaction.dart';
import 'package:cnpm_ptpm/models/category.dart';

import '../models/user.dart';

class UserRepository {
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
      return json.decode(response.body);
    } else {
      print('API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Lỗi API: ${response.statusCode}, ${response.body}');
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/gen/categories'));
      dynamic responseBody = _handleResponse(response);
      List<dynamic> categoryList = responseBody['categories'];
      return categoryList.map((data) => Category.fromMap(data)).toList();
    } catch (e) {
      print('getCategories error: ' + e.toString());
      rethrow;
    }
  }

  Future<List<Seller>> getSellers() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/gen/sellers'));
      dynamic responseBody = _handleResponse(response);
      List<dynamic> sellersList = responseBody['sellers'];
      return sellersList.map((data) => Seller.fromMap(data)).toList();
    } catch (e) {
      print('getSellers error: ' + e.toString());
      rethrow;
    }
  }

  Future<List<Product>> searchProducts({int? sellerId, String? query}) async {
    try {
      Map<String, String> queryParams = {};
      if (sellerId != null) {
        queryParams['seller_id'] = sellerId.toString();
      }
      if (query != null && query.isNotEmpty) {
        queryParams['query'] = query;
      }

      final uri = Uri.parse(
        '$_baseUrl/gen/products/search',
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      final response = await http.get(uri);
      dynamic responseBody = _handleResponse(response);
      List<dynamic> productsList = responseBody['products'];
      return productsList.map((data) => Product.fromMap(data)).toList();
    } catch (e) {
      print('searchProducts error: ' + e.toString());
      rethrow;
    }
  }

  Future<Product> getSingleProduct(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/product/$productId'),
      );
      dynamic responseBody = _handleResponse(response);
      return Product.fromMap(responseBody);
    } catch (e) {
      print('getSingleProduct error: $e');
      rethrow;
    }
  }

  Future<List<CartItem>> getCart(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cart/'),
        headers: _getAuthHeaders(token),
      );
      dynamic responseBody = _handleResponse(response);

      print('DEBUG: Raw responseBody from /cart/: $responseBody');

      List<CartItem> allCartItems = [];

      if (responseBody is Map && responseBody.containsKey('data')) {
        if (responseBody['data'] is List) {
          List<dynamic> sellerGroups = responseBody['data'];

          for (var sellerGroup in sellerGroups) {
            if (sellerGroup is Map && sellerGroup.containsKey('items')) {
              if (sellerGroup['items'] is List) {
                List<dynamic> itemsInGroup = sellerGroup['items'];
                for (var itemData in itemsInGroup) {
                  if (itemData is Map<String, dynamic>) {
                    allCartItems.add(CartItem.fromMap(itemData));
                  }
                }
              }
            }
          }
        }
      }

      print('DEBUG: Final combined cart items: ${allCartItems.length} items');
      return allCartItems;
    } catch (e) {
      print('getCart error: $e');
      return [];
    }
  }

  Future<CartItem> addToCart(String token, int productId, int quantity) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/cart/add'),
        headers: _getAuthHeaders(token),
        body: json.encode({'product_id': productId, 'quantity': quantity}),
      );
      dynamic responseBody = _handleResponse(response);
      return CartItem.fromMap(responseBody);
    } catch (e) {
      print('addToCart error: $e');
      rethrow;
    }
  }

  Future<CartItem> updateCartItem(
    String token,
    int cartItemId,
    int quantity,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/cart/update/$cartItemId'),
        headers: _getAuthHeaders(token),
        body: json.encode({'quantity': quantity}),
      );
      dynamic responseBody = _handleResponse(response);
      return CartItem.fromMap(responseBody);
    } catch (e) {
      print('updateCartItem error: $e');
      rethrow;
    }
  }

  Future<Order> createOrder(
    String token,
    String deliveryAddress,
    int sellerId,
    double totalAmount,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/order/create'),
        headers: _getAuthHeaders(token),
        body: json.encode({
          'delivery_address': deliveryAddress,
          'seller_id': sellerId,
          'total_amount': totalAmount,
        }),
      );
      dynamic responseBody = _handleResponse(response);
      return Order.fromMap(responseBody);
    } catch (e) {
      print('createOrder error: $e');
      rethrow;
    }
  }

  Future<List<Order>> getOrdersByUser(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/order/user'),
        headers: _getAuthHeaders(token),
      );
      dynamic responseBody = _handleResponse(response);
      List<dynamic> orderList = responseBody['orders'];
      return orderList.map((data) => Order.fromMap(data)).toList();
    } catch (e) {
      print('getOrdersByUser error: $e');
      rethrow;
    }
  }

  Future<Order> updateOrderStatus(
    String token,
    int orderId,
    String status,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/order/$orderId/status'),
        headers: _getAuthHeaders(token),
        body: json.encode({'status': status}),
      );
      dynamic responseBody = _handleResponse(response);
      return Order.fromMap(responseBody);
    } catch (e) {
      print('updateOrderStatus error: $e');
      rethrow;
    }
  }

  Future<Transaction> generateQrTransaction(String token, int orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/transaction/generate-qr'),
        headers: _getAuthHeaders(token),
        body: json.encode({'order_id': orderId}),
      );
      dynamic responseBody = _handleResponse(response);
      return Transaction.fromMap(responseBody);
    } catch (e) {
      print('generateQrTransaction error: $e');
      rethrow;
    }
  }

  Future<Transaction> updateTransactionStatus(
    String token,
    int transactionId,
    String status,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/transaction/$transactionId/status'),
        headers: _getAuthHeaders(token),
        body: json.encode({'status': status}),
      );
      dynamic responseBody = _handleResponse(response);
      return Transaction.fromMap(responseBody);
    } catch (e) {
      print('updateTransactionStatus error: $e');
      rethrow;
    }
  }
}
