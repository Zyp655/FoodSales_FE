import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/user.dart';
import 'package:cnpm_ptpm/repositories/admin_repository.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/seller.dart';

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository();
});

@immutable
class AdminState {
  final List<User> allUsers;
  final List<Seller> allSellers;
  final bool isLoading;
  final String? error;

  const AdminState({
    this.allUsers = const [],
    this.allSellers = const [],
    this.isLoading = false,
    this.error,
  });

  AdminState copyWith({
    List<User>? allUsers,
    List<Seller>? allSellers,
    bool? isLoading,
    String? error,
  }) {
    return AdminState(
      allUsers: allUsers ?? this.allUsers,
      allSellers: allSellers ?? this.allSellers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
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
    state = state.copyWith(isLoading: true, error: null);
    try {
      final usersFuture = _getRepo().adminListAllUsers(token);
      final sellersFuture = _getRepo().adminListAllSellers(token);

      final results = await Future.wait([usersFuture, sellersFuture]);

      state = state.copyWith(
        isLoading: false,
        allUsers: results[0] as List<User>,
        allSellers: results[1] as List<Seller>,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateSellerStatus(int sellerId, String status) async {
    final token = _getToken();
    if (token == null) return;
    await _getRepo().adminUpdateSellerStatus(token, sellerId, status);
    fetchAllData();
  }
}

final adminProvider =
StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref);
});