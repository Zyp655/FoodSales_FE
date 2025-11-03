import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/providers/chat_provider.dart';
import 'package:cnpm_ptpm/models/chat_message.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String receiverType;
  final int receiverId;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.receiverType,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    ref.read(chatProvider({
      'type': widget.receiverType,
      'id': widget.receiverId,
    }).notifier).sendMessage(_messageController.text);

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider({
      'type': widget.receiverType,
      'id': widget.receiverId,
    }));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        bottom: chatState.isConnecting
            ? const PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: LinearProgressIndicator(),
        )
            : null,
      ),
      body: Column(
        children: [
          if (chatState.error != null)
            Container(
              color: Colors.red.shade100,
              padding: const EdgeInsets.all(8),
              child: Text(chatState.error!, textAlign: TextAlign.center),
            ),
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: const EdgeInsets.all(8.0),
              itemCount: chatState.messages.length,
              itemBuilder: (ctx, index) {
                final message = chatState.messages[index];
                return _MessageBubble(message: message);
              },
            ),
          ),
          _MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final alignment =
    message.isMe ? Alignment.centerRight : Alignment.centerLeft;
    final color = message.isMe
        ? Theme.of(context).colorScheme.primary
        : Colors.grey.shade300;
    final textColor = message.isMe ? Colors.white : Colors.black87;

    return Align(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message.message, style: TextStyle(color: textColor)),
      ),
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
            onPressed: onSend,
          ),
        ],
      ),
    );
  }
}

