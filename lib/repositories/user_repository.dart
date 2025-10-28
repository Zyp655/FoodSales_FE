import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cnpm_ptpm/models/product.dart';
import 'package:cnpm_ptpm/models/seller.dart';
import 'package:cnpm_ptpm/models/cart_item.dart';
import 'package:cnpm_ptpm/models/order.dart';
import 'package:cnpm_ptpm/models/transaction.dart';
import 'package:cnpm_ptpm/models/category.dart';

import '../models/cart_seller_group.dart';

class SearchResult {
  final List<Product> products;
  final List<Seller> sellers;
  SearchResult({required this.products, required this.sellers});
}

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

  Future<List<Category>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/gen/categories'));
      dynamic responseBody = _handleResponse(response);
      if (responseBody is Map && responseBody.containsKey('categories') && responseBody['categories'] is List) {
        List<dynamic> categoryList = responseBody['categories'];
        return categoryList.map((data) => Category.fromMap(data)).toList();
      }
      return[];
    } catch (e) {
      print('getCategories error: $e');
      return [];
    }
  }

  Future<List<Seller>> getSellers() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/gen/sellers'));
      dynamic responseBody = _handleResponse(response);
      if (responseBody is Map && responseBody.containsKey('sellers') && responseBody['sellers'] is List) {
        List<dynamic> sellersList = responseBody['sellers'];
        return sellersList.map((data) => Seller.fromMap(data)).toList();
      }
      return [];
    } catch (e) {
      print('getSellers error: $e');
      return [];
    }
  }

  Future<List<Product>> searchProducts({int? sellerId, String? query}) async {
    try {
      Map<String, String> queryParams = {};
      if (sellerId != null) {
        queryParams['seller_id'] = sellerId.toString();
      }
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      final uri = Uri.parse(
        '$_baseUrl/gen/products/search',
      ).replace(queryParameters: queryParams.isEmpty ? null : queryParams);

      final response = await http.get(uri);
      dynamic responseBody = _handleResponse(response);
      if (responseBody is Map && responseBody.containsKey('products') && responseBody['products'] is List) {
        List<dynamic> productsList = responseBody['products'];
        return productsList.map((data) => Product.fromMap(data)).toList();
      }
      return [];
    } catch (e) {
      print('searchProducts error: $e');
      return [];
    }
  }

  Future<Product> getSingleProduct(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/product/$productId'),
      );
      dynamic responseBody = _handleResponse(response);
      if (responseBody is Map && responseBody.containsKey('data') && responseBody['data'] is Map) {
        return Product.fromMap(responseBody['data'] as Map<String, dynamic>);
      } else if (responseBody is Map<String, dynamic>) {
        return Product.fromMap(responseBody);
      }
      throw Exception('Invalid format for single product');
    } catch (e) {
      print('getSingleProduct error: $e');
      rethrow;
    }
  }

  Future<List<CartSellerGroup>> getCart(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/cart/'),
        headers: _getAuthHeaders(token),
      );
      dynamic responseBody = _handleResponse(response);

      print('DEBUG: Raw responseBody from /cart/: $responseBody');

      List<CartSellerGroup> sellerGroupsList = [];

      if (responseBody is Map && responseBody.containsKey('data')) {
        if (responseBody['data'] is List) {
          List<dynamic> rawSellerGroups = responseBody['data'];

          for (var groupData in rawSellerGroups) {
            if (groupData is Map<String, dynamic>) {
              try {
                sellerGroupsList.add(CartSellerGroup.fromMap(groupData));
              } catch (e) {
                print('Error parsing seller cart group: $groupData. Error: $e');
              }
            }
          }
        }
      }
      print('DEBUG: Final seller cart groups: ${sellerGroupsList.length} groups');
      return sellerGroupsList;
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
      if (responseBody is Map<String, dynamic>) {
        return CartItem.fromMap(responseBody['cart_item'] ?? responseBody);
      }
      throw Exception('Invalid format for add to cart response');
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
      if (responseBody is Map<String, dynamic>) {
        return CartItem.fromMap(responseBody['cart_item'] ?? responseBody);
      }
      throw Exception('Invalid format for update cart item response');
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
      if (responseBody is Map<String, dynamic>) {
        final orderData = responseBody['order'] ?? responseBody;
        if (orderData is Map<String, dynamic>) {
          return Order.fromMap(orderData);
        }
      }
      throw Exception('Invalid format for create order response');
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
      if (responseBody is Map && responseBody.containsKey('orders') && responseBody['orders'] is List) {
        List<dynamic> orderList = responseBody['orders'];
        return orderList.map((data) => Order.fromMap(data)).toList();
      }
      return [];
    } catch (e) {
      print('getOrdersByUser error: $e');
      return [];
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
      if (responseBody is Map<String, dynamic>) {
        final orderData = responseBody['order'] ?? responseBody;
        if (orderData is Map<String, dynamic>) {
          return Order.fromMap(orderData);
        }
      }
      throw Exception('Invalid format for update order status response');
    } catch (e) {
      print('updateOrderStatus error: $e');
      rethrow;
    }
  }

  Future<SearchResult> searchAll(String query) async {
    if (query.trim().isEmpty) {
      return SearchResult(products: [], sellers: []);
    }
    try {
      final uri = Uri.parse('$_baseUrl/gen/search').replace(queryParameters: {'q': query});
      final response = await http.get(uri);
      dynamic responseBody = _handleResponse(response);

      List<Product> products = [];
      List<Seller> sellers = [];

      if (responseBody is Map && responseBody['results'] is Map) {
        final results = responseBody['results'] as Map<String, dynamic>;

        if (results['products'] is List) {
          products = (results['products'] as List)
              .map((data) => Product.fromMap(data))
              .toList();
        }
        if (results['sellers'] is List) {
          sellers = (results['sellers'] as List)
              .map((data) => Seller.fromMap(data))
              .toList();
        }
      }
      return SearchResult(products: products, sellers: sellers);
    } catch (e) {
      print('searchAll error: $e');
      return SearchResult(products: [], sellers: []);
    }
  }

  Future<bool> removeFromCart(String token, int cartItemId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/cart/remove/$cartItemId'),
        headers: _getAuthHeaders(token),
      );
      _handleResponse(response);
      return true;
    } catch (e) {
      print('removeFromCart error: $e');
      return false;
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
      if (responseBody is Map<String, dynamic>) {
        final txData = responseBody['transaction'] ?? responseBody;
        if (txData is Map<String, dynamic>) {
          return Transaction.fromMap(txData);
        }
      }
      throw Exception('Invalid format for generate QR response');
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
      if (responseBody is Map<String, dynamic>) {
        final txData = responseBody['transaction'] ?? responseBody;
        if (txData is Map<String, dynamic>) {
          return Transaction.fromMap(txData);
        }
      }
      throw Exception('Invalid format for update transaction status response');
    } catch (e) {
      print('updateTransactionStatus error: $e');
      rethrow;
    }
  }
}