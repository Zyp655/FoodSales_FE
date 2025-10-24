import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/order.dart';
import 'package:cnpm_ptpm/repositories/delivery_repository.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

final deliveryRepositoryProvider = Provider<DeliveryRepository>((ref) {
  return DeliveryRepository();
});

@immutable
class DeliveryState {
  final List<Order> assignedOrders;
  final bool isLoading;
  final String? error;

  const DeliveryState({
    this.assignedOrders = const [],
    this.isLoading = false,
    this.error,
  });

  DeliveryState copyWith({
    List<Order>? assignedOrders,
    bool? isLoading,
    String? error,
  }) {
    return DeliveryState(
      assignedOrders: assignedOrders ?? this.assignedOrders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      final orders = await _getRepo().deliveryGetAssignedOrders(token);
      state = state.copyWith(isLoading: false, assignedOrders: orders);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateDeliveryStatus(int orderId, String status) async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true);
    await _getRepo().deliveryUpdateDeliveryStatus(token, orderId, status);
    fetchAssignedOrders();
  }
}

final deliveryProvider =
StateNotifierProvider<DeliveryNotifier, DeliveryState>((ref) {
  return DeliveryNotifier(ref);
});