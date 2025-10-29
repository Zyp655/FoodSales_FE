import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/order.dart';
import '../repositories/delivery_repository.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepository();
});

@immutable
class DeliveryState {
  final List<Order> assignedOrders;
  final List<Order> availableOrders;
  final bool isLoading;
  final String? error;

  const DeliveryState({
    this.assignedOrders = const [],
    this.availableOrders = const [],
    this.isLoading = false,
    this.error,
  });

  DeliveryState copyWith({
    List<Order>? assignedOrders,
    List<Order>? availableOrders,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return DeliveryState(
      assignedOrders: assignedOrders ?? this.assignedOrders,
      availableOrders: availableOrders ?? this.availableOrders,
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

  Future<void> fetchAssignedOrders() async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final orders = await _getRepo().deliveryGetAssignedOrders(token);
      state = state.copyWith(isLoading: false, assignedOrders: orders);
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

  Future<bool> acceptOrder(int orderId) async {
    final token = _getToken();
    if (token == null) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _getRepo().acceptOrder(token, orderId);
      await fetchAssignedOrders();
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
      await _getRepo().deliveryUpdateDeliveryStatus(token, orderId, status);
      await fetchAssignedOrders();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    } finally {
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }
}

final deliveryProvider =
StateNotifierProvider<DeliveryNotifier, DeliveryState>((ref) {
  return DeliveryNotifier(ref);
});