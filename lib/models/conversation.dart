import 'dart:convert';

import 'package:cnpm_ptpm/models/seller.dart';
import 'package:cnpm_ptpm/models/user.dart';

import 'message.dart';


class Conversation {
  final int id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Message? lastMessage;
  final List<dynamic> participants;

  Conversation({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessage,
    this.participants = const [],
  });

  factory Conversation.fromMap(Map<String, dynamic> map) {
    List<dynamic> parseParticipants(List<dynamic>? participantList) {
      if (participantList == null) return [];
      return participantList.map((p) {
        final participantData = p['participant'];
        if (participantData == null) return null;

        final type = p['participant_type'] as String?;

        if (type != null && type.endsWith('Seller')) {
          return Seller.fromMap(participantData as Map<String, dynamic>);
        } else if (type != null && type.endsWith('User')) {
          return User.fromMap(participantData as Map<String, dynamic>);
        }
        return null;
      }).where((p) => p != null).toList();
    }

    return Conversation(
      id: map['id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      lastMessage: map['last_message'] != null
          ? Message.fromMap(map['last_message'] as Map<String, dynamic>)
          : null,
      participants: parseParticipants(map['participants'] as List?),
    );
  }

  factory Conversation.fromJson(String source) =>
      Conversation.fromMap(json.decode(source) as Map<String, dynamic>);
}