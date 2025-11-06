import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_repository.dart';
import 'package:cnpm_ptpm/models/conversation.dart';
import 'package:cnpm_ptpm/models/message.dart';

class ChatRepository extends BaseRepository {
  Future<Conversation> getOrCreateConversation(
      String token, {
        required String receiverType,
        required int receiverId,
      }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/conversations'),
        headers: getAuthHeaders(token),
        body: json.encode({
          'receiver_type': receiverType,
          'receiver_id': receiverId,
        }),
      );
      final data = handleResponse(response);
      return Conversation.fromMap(data);
    } catch (e) {
      print('getOrCreateConversation error: $e');
      rethrow;
    }
  }

  Future<Message> sendMessage(
      String token, {
        required int conversationId,
        required String message,
      }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/conversations/$conversationId/messages'),
        headers: getAuthHeaders(token),
        body: json.encode({
          'body': message,
        }),
      );
      final data = handleResponse(response);
      return Message.fromMap(data);
    } catch (e) {
      print('sendMessage error: $e');
      rethrow;
    }
  }

  Future<List<Message>> getMessages(String token, int conversationId,
      {int page = 1}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/conversations/$conversationId/messages?page=$page'),
        headers: getAuthHeaders(token),
      );
      final data = handleResponse(response);
      final messagesData = data['data'] as List;
      return messagesData
          .map((msg) => Message.fromMap(msg as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('getMessages error: $e');
      rethrow;
    }
  }
}