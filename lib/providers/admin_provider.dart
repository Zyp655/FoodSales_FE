import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/order.dart';
import 'package:cnpm_ptpm/models/delivery_ticket.dart';
import 'package:cnpm_ptpm/models/account.dart';
import 'package:cnpm_ptpm/models/category.dart';
import 'package:cnpm_ptpm/repositories/admin_repository.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

@immutable
class AdminState {
  final List<Account> allAccounts;
  final List<Order> allOrders;
  final List<DeliveryTicket> deliveryTickets;
  final List<Category> allCategories;
  final bool isLoading;
  final bool isTicketProcessing;
  final String? error;
  final String accountFilter;

  const AdminState({
    this.allAccounts = const [],
    this.allOrders = const [],
    this.deliveryTickets = const [],
    this.allCategories = const [],
    this.isLoading = false,
    this.isTicketProcessing = false,
    this.error,
    this.accountFilter = 'all',
  });

  AdminState copyWith({
    List<Account>? allAccounts,
    List<Order>? allOrders,
    List<DeliveryTicket>? deliveryTickets,
    List<Category>? allCategories,
    bool? isLoading,
    bool? isTicketProcessing,
    String? error,
    bool clearError = false,
    String? accountFilter,
  }) {
    return AdminState(
      allAccounts: allAccounts ?? this.allAccounts,
      allOrders: allOrders ?? this.allOrders,
      deliveryTickets: deliveryTickets ?? this.deliveryTickets,
      allCategories: allCategories ?? this.allCategories,
      isLoading: isLoading ?? this.isLoading,
      isTicketProcessing: isTicketProcessing ?? this.isTicketProcessing,
      error: clearError ? null : (error ?? this.error),
      accountFilter: accountFilter ?? this.accountFilter,
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
      final accountsFuture =
      _getRepo().adminGetAccounts(token, type: state.accountFilter);
      final ordersFuture = _getRepo().adminGetAllOrders(token);
      final ticketsFuture = _getRepo().adminGetAllDeliveryTickets(token);
      final categoriesFuture = _getRepo().adminGetCategories(token);

      final results = await Future.wait(
          [accountsFuture, ordersFuture, ticketsFuture, categoriesFuture]);

      state = state.copyWith(
        isLoading: false,
        allAccounts: results[0] as List<Account>,
        allOrders: results[1] as List<Order>,
        deliveryTickets: results[2] as List<DeliveryTicket>,
        allCategories: results[3] as List<Category>,
      );
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, error: errorMessage);
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
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> fetchDeliveryTickets({String status = 'pending'}) async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tickets =
      await _getRepo().adminGetAllDeliveryTickets(token, status: status);
      state = state.copyWith(isLoading: false, deliveryTickets: tickets);
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<bool> updateDeliveryTicketStatus(int ticketId, String status) async {
    final token = _getToken();
    if (token == null) {
      state = state.copyWith(error: 'Not authenticated');
      return false;
    }
    state = state.copyWith(isTicketProcessing: true, clearError: true);
    try {
      await _getRepo().adminUpdateDeliveryTicketStatus(token, ticketId, status);

      state = state.copyWith(
        isTicketProcessing: false,
        deliveryTickets:
        state.deliveryTickets.where((t) => t.id != ticketId).toList(),
      );

      if (status == 'approved') {
        await fetchAllData();
      }

      return true;
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isTicketProcessing: false, error: errorMessage);
      return false;
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
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  Future<void> setAccountFilter(String filter) async {
    state = state.copyWith(accountFilter: filter);
    await fetchAllData();
  }

  Future<void> deleteAccount(Account account) async {
    final token = _getToken();
    if (token == null) return;

    state = state.copyWith(isLoading: true);
    try {
      if (account.type == 'user') {
        await _getRepo().adminDeleteUser(token, account.id);
      } else if (account.type == 'seller') {
        await _getRepo().adminDeleteSeller(token, account.id);
      }
      await fetchAllData();
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> adminUpdateAccountRole(Account account, String newRole) async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true);
    try {
      if (account.type == 'user') {
        await _getRepo().adminUpdateUserRole(token, account.id, newRole);
      } else if (account.type == 'seller') {
        await _getRepo().adminUpdateSellerRole(token, account.id, newRole);
      }

      state = state.copyWith(
        isLoading: false,
        allAccounts: state.allAccounts.map((acc) {
          if (acc.id == account.id && acc.type == account.type) {
            return Account(
                id: acc.id,
                name: acc.name,
                email: acc.email,
                avatar: acc.avatar,
                type: acc.type,
                role: newRole,
                status: acc.status);
          }
          return acc;
        }).toList(),
      );
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> adminCreateCategory(String name, String? description) async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final newCategory =
      await _getRepo().adminCreateCategory(token, name, description);
      state = state.copyWith(
        isLoading: false,
        allCategories: [...state.allCategories, newCategory],
      );
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> adminUpdateCategory(
      int id, String name, String? description) async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final updatedCategory =
      await _getRepo().adminUpdateCategory(token, id, name, description);
      state = state.copyWith(
        isLoading: false,
        allCategories: state.allCategories
            .map((c) => c.id == id ? updatedCategory : c)
            .toList(),
      );
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<void> adminDeleteCategory(int id) async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true);
    try {
      await _getRepo().adminDeleteCategory(token, id);
      state = state.copyWith(
        isLoading: false,
        allCategories: state.allCategories.where((c) => c.id != id).toList(),
      );
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }
}

final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref);
});

final deliveryDriversProvider = Provider<List<Account>>((ref) {
  final adminState = ref.watch(adminProvider);
  return adminState.allAccounts
      .where((account) => account.role == 'delivery')
      .toList();
});

final pendingDeliveryTicketsProvider = Provider<List<DeliveryTicket>>((ref) {
  return ref.watch(adminProvider).deliveryTickets;
});