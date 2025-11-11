import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/conversation.dart';
import 'package:cnpm_ptpm/models/message.dart';
import 'package:cnpm_ptpm/models/user.dart';
import 'package:cnpm_ptpm/repositories/chat_repository.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:cnpm_ptpm/services/chat_service.dart';
import 'package:flutter_riverpod/legacy.dart';

final chatRepositoryProvider = Provider((ref) => ChatRepository());

@immutable
class ChatState {
  final List<Message> messages;
  final bool isConnecting;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isConnecting = true,
    this.error,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isConnecting,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isConnecting: isConnecting ?? this.isConnecting,
      error: error ?? this.error,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  final Conversation _conversation;
  late final ChatRepository _repo;
  late final ChatService _chatService;
  late final int _myId;
  late final User _myUser;
  StreamSubscription? _messageSubscription;

  ChatNotifier(this._ref, this._conversation) : super(const ChatState()) {
    _repo = _ref.read(chatRepositoryProvider);
    _chatService = _ref.read(chatServiceProvider);

    final currentUser = _ref.read(authProvider).currentUser;

    if (currentUser == null || currentUser.id == null) {
      state = state.copyWith(
        isConnecting: false,
        error: 'User not authenticated. Cannot initialize chat.',
      );
      return;
    }

    _myUser = currentUser;
    _myId = _myUser.id!;
    _initialize();
  }

  void _initialize() async {
    await _fetchMessages();

    _chatService.subscribeToConversation(_conversation.id);

    _messageSubscription = _chatService.messageStream.listen((message) {
      if (message.conversationId == _conversation.id) {
        if (mounted) {
          state = state.copyWith(
              messages: [message.copyWith(isMe: false), ...state.messages]);
        }
      }
    });
  }

  Future<void> _fetchMessages() async {
    final token = _ref.read(authProvider).currentUser?.token;
    if (token == null) return;
    try {
      final messages = await _repo.getMessages(token, _conversation.id);
      if (mounted) {
        final processedMessages =
        messages.map((m) => m.copyWith(isMe: m.senderId == _myId)).toList();
        state =
            state.copyWith(messages: processedMessages, isConnecting: false);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(isConnecting: false, error: e.toString());
      }
    }
  }

  Future<void> sendMessage(String messageText) async {
    final token = _ref.read(authProvider).currentUser?.token;
    if (token == null || messageText.trim().isEmpty) return;

    final optimisticMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch,
      body: messageText.trim(),
      conversationId: _conversation.id,
      senderType: _myUser.role ?? 'user',
      senderId: _myId,
      createdAt: DateTime.now(),
      isMe: true,
      sender: _myUser,
    );

    if (mounted) {
      state = state.copyWith(messages: [optimisticMessage, ...state.messages]);
    }

    try {
      await _repo.sendMessage(
        token,
        conversationId: _conversation.id,
        message: messageText.trim(),
      );
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: e.toString());
      }
    }
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}

final chatProvider = StateNotifierProvider.autoDispose
    .family<ChatNotifier, ChatState, Conversation>((ref, conversation) {
  return ChatNotifier(ref, conversation);
});