import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/user.dart';
import 'package:cnpm_ptpm/repositories/auth_repository.dart';
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
    bool clearError = false,
  }) {
    return AuthState(
      currentUser: currentUser ?? this.currentUser,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  AuthNotifier(this._authRepo) : super(const AuthState());

  String? get token => state.currentUser?.token;

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authRepo.login(email, password);
      state = state.copyWith(isLoading: false, currentUser: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    final currentToken = token;
    if (currentToken != null) {
      try {
        await _authRepo.logout(currentToken);
      } catch (e) {
        print("Logout API error: $e");
      }
    }
    state = const AuthState();
  }

  Future<bool> registerUser(Map<String, dynamic> userData) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepo.registerUser(userData);
      final user =
      await _authRepo.login(userData['email'], userData['password']);
      state = state.copyWith(isLoading: false, currentUser: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> registerSeller(Map<String, dynamic> sellerData) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepo.registerSeller(sellerData);
      final user =
      await _authRepo.login(sellerData['email'], sellerData['password']);
      state = state.copyWith(isLoading: false, currentUser: user);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updateProfile(String name, String phone) async {
    final currentToken = token;
    if (currentToken == null) return false;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedUser = await _authRepo.updateProfile(
        currentToken,
        name: name,
        phone: phone,
      );
      state = state.copyWith(isLoading: false, currentUser: updatedUser);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return AuthNotifier(authRepo);
});