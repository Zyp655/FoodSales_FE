import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/user.dart';
import 'package:cnpm_ptpm/repositories/auth_repository.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cnpm_ptpm/providers/shared_preferences_provider.dart';

@immutable
class AuthState {
  final User? currentUser;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.currentUser,
    this.isLoading = true,
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
  final SharedPreferences _prefs;
  static const String _userKey = 'current_user';

  AuthNotifier(this._authRepo, this._prefs) : super(const AuthState()) {
    _initialize();
  }

  String? get token => state.currentUser?.token;

  Future<void> _initialize() async {
    final userJson = _prefs.getString(_userKey);

    if (userJson != null) {
      try {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        final currentUser = User.fromMap(userMap);

        state = state.copyWith(currentUser: currentUser, isLoading: false);

      } catch (e) {
        await _clearUserFromPrefs();
        state = state.copyWith(isLoading: false, currentUser: null);
      }
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _saveUserToPrefs(User user) async {
    final userMap = user.toMap();
    await _prefs.setString(_userKey, json.encode(userMap));
  }

  Future<void> _clearUserFromPrefs() async {
    await _prefs.remove(_userKey);
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authRepo.login(email, password);
      await _saveUserToPrefs(user);
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
    await _clearUserFromPrefs();
    state = const AuthState(isLoading: false, currentUser: null);
  }

  Future<bool> registerUser(Map<String, dynamic> userData) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _authRepo.registerUser(userData);
      final user = await _authRepo.login(userData['email'], userData['password']);
      await _saveUserToPrefs(user);
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
      final user = await _authRepo.login(sellerData['email'], sellerData['password']);
      await _saveUserToPrefs(user);
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
      await _saveUserToPrefs(updatedUser);
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
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(authRepo, prefs);
});