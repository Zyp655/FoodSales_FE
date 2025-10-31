import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/order.dart';
import '../models/delivery_stats.dart';
import '../repositories/delivery_repository.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepository();
});

@immutable
class DeliveryState {
  final List<Order> availableOrders;
  final List<Order> assignedOrders;
  final DeliveryStats? stats;
  final bool isLoading;
  final String? error;

  const DeliveryState({
    this.availableOrders = const [],
    this.assignedOrders = const [],
    this.stats,
    this.isLoading = false,
    this.error,
  });

  DeliveryState copyWith({
    List<Order>? availableOrders,
    List<Order>? assignedOrders,
    DeliveryStats? stats,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return DeliveryState(
      availableOrders: availableOrders ?? this.availableOrders,
      assignedOrders: assignedOrders ?? this.assignedOrders,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DeliveryNotifier extends StateNotifier<DeliveryState> {
  final Ref _ref;
  DeliveryNotifier(this._ref) : super(const DeliveryState());

  String? _getToken() {
    return _ref.read(authProvider).currentUser?.token;
  }

  DeliveryRepository _getRepo() {
    return _ref.read(deliveryRepositoryProvider);
  }

  Future<void> fetchDeliveryStats() async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final stats = await _getRepo().getDeliveryStats(token);
      state = state.copyWith(isLoading: false, stats: stats);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchAvailableOrders() async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final orders = await _getRepo().getAvailableOrders(token);
      state = state.copyWith(isLoading: false, availableOrders: orders);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchAssignedOrders() async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final orders = await _getRepo().getAssignedOrders(token);
      state = state.copyWith(isLoading: false, assignedOrders: orders);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> acceptOrder(int orderId) async {
    final token = _getToken();
    if (token == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _getRepo().acceptOrder(token, orderId);
      await fetchAvailableOrders();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> updateDeliveryStatus(int orderId, String status) async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedOrder =
      await _getRepo().deliveryUpdateDeliveryStatus(token, orderId, status);

      state = state.copyWith(
        isLoading: false,
        assignedOrders: state.assignedOrders
            .where((order) => order.id != orderId)
            .toList(),
      );

      fetchDeliveryStats();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final deliveryProvider =
StateNotifierProvider<DeliveryNotifier, DeliveryState>((ref) {
  return DeliveryNotifier(ref);
});