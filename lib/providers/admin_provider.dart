import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/user.dart';
import 'package:cnpm_ptpm/models/seller.dart';
import 'package:cnpm_ptpm/models/order.dart';
import 'package:cnpm_ptpm/repositories/admin_repository.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

@immutable
class AdminState {
  final List<User> allUsers;
  final List<Seller> allSellers;
  final List<Order> allOrders;
  final bool isLoading;
  final String? error;

  const AdminState({
    this.allUsers = const [],
    this.allSellers = const [],
    this.allOrders = const [],
    this.isLoading = false,
    this.error,
  });

  AdminState copyWith({
    List<User>? allUsers,
    List<Seller>? allSellers,
    List<Order>? allOrders,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AdminState(
      allUsers: allUsers ?? this.allUsers,
      allSellers: allSellers ?? this.allSellers,
      allOrders: allOrders ?? this.allOrders,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AdminNotifier extends StateNotifier<AdminState> {
  final Ref _ref;
  AdminNotifier(this._ref) : super(const AdminState());

  String? _getToken() {
    return _ref.read(authProvider).currentUser?.token;
  }

  AdminRepository _getRepo() {
    return _ref.read(adminRepositoryProvider);
  }

  Future<void> fetchAllData() async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final usersFuture = _getRepo().adminListAllUsers(token);
      final sellersFuture = _getRepo().adminListAllSellers(token);
      final ordersFuture = _getRepo().adminGetAllOrders(token);

      final results = await Future.wait([usersFuture, sellersFuture, ordersFuture]);

      state = state.copyWith(
        isLoading: false,
        allUsers: results[0] as List<User>,
        allSellers: results[1] as List<Seller>,
        allOrders: results[2] as List<Order>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchAllOrders() async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final orders = await _getRepo().adminGetAllOrders(token);
      state = state.copyWith(isLoading: false, allOrders: orders);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> assignDriver(int orderId, int driverId) async {
    final token = _getToken();
    if (token == null) {
      state = state.copyWith(error: 'Not authenticated');
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _getRepo().adminAssignDriver(token, orderId, driverId);
      await fetchAllOrders();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }


  Future<void> updateSellerStatus(int sellerId, String status) async {
    final token = _getToken();
    if (token == null) return;
    try {
      await _getRepo().adminUpdateSellerStatus(token, sellerId, status);
      await fetchAllData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> adminUpdateUserRole(int userId, String role) async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true);
    try {
      await _getRepo().adminUpdateUserRole(token, userId, role);
      await fetchAllData();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final adminProvider =
StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref);
});

// Provider to get only users with role 'delivery'
final deliveryDriversProvider = Provider<List<User>>((ref) {
  final adminState = ref.watch(adminProvider);
  return adminState.allUsers.where((user) => user.role == 'delivery').toList();
});