import 'package:cnpm_ptpm/providers/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/repositories/auth_repository.dart';
import 'package:cnpm_ptpm/repositories/user_repository.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user.dart';

@immutable
class AccountState {
  final bool isLoading;
  final String? error;
  final String? deliveryTicketStatus;

  const AccountState({this.isLoading = false, this.error, this.deliveryTicketStatus});

  AccountState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? deliveryTicketStatus,
    bool clearTicketStatus = false,
  }) {
    return AccountState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      deliveryTicketStatus: clearTicketStatus ? null : (deliveryTicketStatus ?? this.deliveryTicketStatus),
    );
  }
}

class AccountNotifier extends StateNotifier<AccountState> {
  final Ref _ref;

  AuthRepository get _authRepo => _ref.read(authRepositoryProvider);
  UserRepository get _userRepo => _ref.read(userRepositoryProvider);

  AuthNotifier get _authNotifier => _ref.read(authProvider.notifier);

  String? get _token => _ref.read(authProvider).currentUser?.token;

  AccountNotifier(this._ref) : super(const AccountState());

  Future<bool> _executeAuthAction(Future Function(String token) action) async {
    final token = _token;
    if (token == null) {
      state = state.copyWith(error: 'User not logged in.', clearError: false);
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await action(token);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  Future<bool> _executeAuthActionAndUpdateUser(
      Future<User> Function(String token) action,
      ) async {
    final token = _token;
    if (token == null) {
      state = state.copyWith(error: 'User not logged in.', clearError: false);
      return false;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final updatedUser = await action(token);
      _authNotifier.state = _authNotifier.state.copyWith(
        currentUser: updatedUser.copyWith(token: token),
      );
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, error: errorMessage);
      return false;
    }
  }

  Future<bool> updateAddress(String newAddress) {
    return _executeAuthActionAndUpdateUser(
          (token) => _authRepo.updateUserAddress(token, newAddress),
    );
  }

  Future<bool> updateContactInfo({String? phone, String? address}) {
    return _executeAuthActionAndUpdateUser(
          (token) => _authRepo.updateContact(token, phone: phone, address: address),
    );
  }

  Future<bool> changePassword(
      String currentPassword,
      String newPassword,
      String confirmPassword,
      ) {
    return _executeAuthAction(
          (token) => _authRepo.changePassword(
        token,
        currentPassword,
        newPassword,
        confirmPassword,
      ),
    );
  }

  Future<bool> updateSellerInfo({
    required String name,
    required String email,
    required String? phone,
    required String address,
    required String description,
    XFile? imageFile,
  }) {
    return _executeAuthActionAndUpdateUser(
          (token) => _authRepo.updateSellerInfo(
        token,
        name: name,
        email: email,
        phone: phone,
        address: address,
        description: description,
        imageFile: imageFile,
      ),
    );
  }

  Future<void> fetchDeliveryTicketStatus() async {
    final token = _token;
    if (token == null) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final status = await _userRepo.getDeliveryTicketStatus(token);
      state = state.copyWith(isLoading: false, deliveryTicketStatus: status);
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      state = state.copyWith(isLoading: false, error: errorMessage);
    }
  }

  Future<bool> submitDeliveryRequest({
    required String fullName,
    required String email,
    required String phone,
    required String idCardNumber,
    required XFile idCardImage,
  }) async {
    final success = await _executeAuthAction(
          (token) => _userRepo
          .submitDeliveryRequest(
        token: token,
        fullName: fullName,
        email: email,
        phone: phone,
        idCardNumber: idCardNumber,
        idCardImage: idCardImage,
      ),
    );

    if (success) {
      state = state.copyWith(deliveryTicketStatus: 'pending');
    }

    return success;
  }
}

final accountProvider = StateNotifierProvider<AccountNotifier, AccountState>((
    ref,
    ) {
  return AccountNotifier(ref);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});