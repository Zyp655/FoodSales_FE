import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class BaseRepository {
  final String baseUrl = 'http://10.0.2.2:8000/api';

  Map<String, String> getAuthHeaders(String token, {bool isMultipart = false}) {
    var headers = {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    };
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  dynamic handleResponse(http.Response response) {
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
      // Log lỗi API
      print('API Error: ${response.statusCode} - ${response.body}');
      String errorMessage = 'API error: ${response.statusCode}';
      try {
        var decodedError = json.decode(response.body);
        if (decodedError is Map) {
          if (decodedError.containsKey('message')) {
            errorMessage = decodedError['message'];
          }
          if (decodedError.containsKey('errors') && decodedError['errors'] is Map) {
            var errorsMap = decodedError['errors'] as Map;
            if (errorsMap.isNotEmpty) {
              errorMessage += ': ${errorsMap.values.first.first}';
            }
          }
        } else {
          errorMessage = response.body;
        }
      } catch (_) {
        errorMessage = response.body;
      }
      throw Exception(errorMessage);
    }
  }
}