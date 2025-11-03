class ChatMessage {
  final String message;
  final String senderType;
  final int senderId;
  final bool isMe; 

  ChatMessage({
    required this.message,
    required this.senderType,
    required this.senderId,
    required this.isMe,
  });

  factory ChatMessage.fromBroadcastEvent(Map<String, dynamic> data, int myId) {
    int senderId = (data['senderId'] as num).toInt();
    return ChatMessage(
      message: data['message'] ?? '',
      senderType: data['senderType'] ?? 'user',
      senderId: senderId,
      isMe: senderId == myId,
    );
  }
}