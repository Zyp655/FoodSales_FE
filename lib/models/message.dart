import 'dart:convert';
import 'package:cnpm_ptpm/models/user.dart';

class Message {
  final int id;
  final String body;
  final int conversationId;
  final String senderType;
  final int senderId;
  final User? sender;
  final DateTime createdAt;
  final bool isMe;

  Message({
    required this.id,
    required this.body,
    required this.conversationId,
    required this.senderType,
    required this.senderId,
    this.sender,
    required this.createdAt,
    this.isMe = false,
  });

  Message copyWith({
    int? id,
    String? body,
    int? conversationId,
    String? senderType,
    int? senderId,
    User? sender,
    DateTime? createdAt,
    bool? isMe,
  }) {
    return Message(
      id: id ?? this.id,
      body: body ?? this.body,
      conversationId: conversationId ?? this.conversationId,
      senderType: senderType ?? this.senderType,
      senderId: senderId ?? this.senderId,
      sender: sender ?? this.sender,
      createdAt: createdAt ?? this.createdAt,
      isMe: isMe ?? this.isMe,
    );
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as int,
      body: map['body'] as String,
      conversationId: map['conversation_id'] as int,
      senderType: map['sender_type'] as String,
      senderId: map['sender_id'] as int,
      sender: map['sender'] != null
          ? User.fromMap(map['sender'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      isMe: map['isMe'] ?? false,
    );
  }

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);
}