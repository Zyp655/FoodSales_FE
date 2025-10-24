import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cnpm_ptpm/models/product.dart';
import 'package:image_picker/image_picker.dart';

class SellerRepository {
  final String _baseUrl = 'http://10.0.2.2/FOODSALES_BE/api';

  Map<String, String> _getAuthHeaders(String token) {
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      print('API Error: ${response.statusCode} - ${response.body}');
      throw Exception('Lỗi API: ${response.statusCode}, ${response.body}');
    }
  }

  Future<List<Product>> getProductsBySeller(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/seller/product/'),
        headers: _getAuthHeaders(token),
      );
      dynamic responseBody = _handleResponse(response);
      List<dynamic> productList = responseBody;
      return productList.map((data) => Product.fromMap(data)).toList();
    } catch (e) {
      print('getProductsBySeller error: $e');
      rethrow;
    }
  }

  Future<Product> addProduct(
      String token, Product product, XFile? imageFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/seller/product/add'),
      );

      request.headers.addAll(_getAuthHeaders(token));

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
      return Product.fromMap(responseBody);
    } catch (e) {
      print('addProduct error: $e');
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

      request.headers.addAll(_getAuthHeaders(token));

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
      return Product.fromMap(responseBody);
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