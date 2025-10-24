import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/user.dart';
import 'package:cnpm_ptpm/repositories/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
@immutable
class AuthState {
  final User? currentUser;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.currentUser,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? currentUser,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;

  AuthNotifier(this._authRepo) : super(const AuthState());

  String? get token => state.currentUser?.token;

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _authRepo.login(email, password);
      state = state.copyWith(isLoading: false, currentUser: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    if (token != null) {
      await _authRepo.logout(token!);
    }
    state = const AuthState();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepo);
});