import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:cnpm_ptpm/models/chat_message.dart';
import 'package:cnpm_ptpm/repositories/chat_repository.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:cnpm_ptpm/constants/pusher_config.dart';
import 'package:pusher_client_socket/pusher_client_socket.dart' as pusher;
import 'dart:convert';

final chatRepositoryProvider = Provider((ref) => ChatRepository());

@immutable
class ChatState {
  final List<ChatMessage> messages;
  final bool isConnecting;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isConnecting = true,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
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
  pusher.PusherClient? _pusher;
  pusher.Channel? _channel;
  String _channelName = '';
  final String _receiverType;
  final int _receiverId;
  late int _myId;
  late String _myRole;

  ChatNotifier(this._ref, this._receiverType, this._receiverId)
      : super(const ChatState()) {
    _initialize();
  }

  void _initialize() {
    final user = _ref.read(authProvider).currentUser;
    if (user == null) {
      state = state.copyWith(isConnecting: false, error: 'Not authenticated');
      return;
    }

    _myId = user.id!;
    _myRole = user.role ?? 'user';
    _connectToPusher();
  }

   String _getChannelName() {
    final senderIdentifier = "$_myRole-$_myId";
    final receiverIdentifier = "$_receiverType-$_receiverId";

    final participants = [senderIdentifier, receiverIdentifier];
    participants.sort();

    _channelName = 'private-chat.${participants[0]}.${participants[1]}';
    return _channelName;
  }

  Future<void> _connectToPusher() async {
    final token = _ref.read(authProvider).currentUser?.token;
    if (token == null) return;

    final options = pusher.PusherOptions(
      key: PusherConfig.appKey,
      cluster: PusherConfig.cluster,
      host: PusherConfig.host,
      wsPort: PusherConfig.port,
      encrypted: false,

      authOptions: pusher.PusherAuthOptions(
        PusherConfig.authEndpoint,
        headers: () async {
          return {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          };
        },
      ),

      autoConnect: false,
    );

    _pusher = pusher.PusherClient(options: options);

    _pusher!.connect();

    _pusher!.onConnectionStateChange((change) {
      if (change is pusher.Connected) {
        _subscribeToChannel();
      } else if (change is pusher.Disconnected) {
        if (mounted) {
          state = state.copyWith(isConnecting: false, error: 'Disconnected');
        }
      }
    });

    _pusher!.onConnectionError((error) {
      if (mounted) {
        state = state.copyWith(isConnecting: false, error: error?.message);
      }
    });
  }

  void _subscribeToChannel() {
    if (_pusher == null) return;

    final channelName = _getChannelName();
    _channel = _pusher!.subscribe(channelName);

    _channel!.bind('new-message', (event) {
      if (event?.data != null) {
        try {
          final data = jsonDecode(event!.data!) as Map<String, dynamic>;
          final message = ChatMessage.fromBroadcastEvent(data, _myId);

          if (mounted) {
            state = state.copyWith(messages: [message, ...state.messages]);
          }
        } catch (e) {
          print('Error decoding JSON from Pusher: $e');
        }
      }
    });

    _channel!.bind('pusher:subscription_succeeded', (event) {
      if (mounted) {
        state = state.copyWith(isConnecting: false, error: null);
      }
    });

    _channel!.bind('pusher:subscription_error', (event) {
      if (mounted) {
        state = state.copyWith(isConnecting: false, error: 'Subscription Error: ${event?.data}');
      }
    });
  }

  Future<void> sendMessage(String message) async {
    final token = _ref.read(authProvider).currentUser?.token;
    if (token == null || message.trim().isEmpty) return;

    final repo = _ref.read(chatRepositoryProvider);

    final myMessage = ChatMessage(
      message: message.trim(),
      senderType: _myRole,
      senderId: _myId,
      isMe: true,
    );
    if (mounted) {
      state = state.copyWith(messages: [myMessage, ...state.messages]);
    }

    try {
      await repo.sendMessage(
        token,
        message: message.trim(),
        receiverType: _receiverType,
        receiverId: _receiverId,
      );
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: e.toString());
      }
    }
  }

  @override
  void dispose() {
    _channel?.unbind('new-message');
    _channel?.unbind('pusher:subscription_succeeded');
    _channel?.unbind('pusher:subscription_error');
    _pusher?.unsubscribe(_channelName);
    _pusher?.disconnect();
    super.dispose();
  }
}

final chatProvider =
StateNotifierProvider.autoDispose.family<ChatNotifier, ChatState, Map<String, dynamic>>(
      (ref, receiver) {
    final receiverType = receiver['type'] as String;
    final receiverId = receiver['id'] as int;
    return ChatNotifier(ref, receiverType, receiverId);
  },
);