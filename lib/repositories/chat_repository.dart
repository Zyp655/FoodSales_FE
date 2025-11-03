import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_repository.dart';

class ChatRepository extends BaseRepository {
  Future<void> sendMessage(
      String token, {
        required String message,
        required String receiverType,
        required int receiverId,
      }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/send'),
        headers: getAuthHeaders(token),
        body: json.encode({
          'message': message,
          'receiver_type': receiverType,
          'receiver_id': receiverId,
        }),
      );
      handleResponse(response);
    } catch (e) {
      print('sendMessage error: $e');
      rethrow;
    }
  }

}