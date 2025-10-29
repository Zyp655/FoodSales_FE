import 'package:cnpm_ptpm/providers/user_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/cart_seller_group.dart';
import 'package:cnpm_ptpm/repositories/user_repository.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

@immutable
class CartState {
  final List<CartSellerGroup> sellerGroups;
  final bool isLoading;
  const CartState({this.sellerGroups = const [], this.isLoading = false});

  CartState copyWith({List<CartSellerGroup>? sellerGroups, bool? isLoading}) {
    return CartState(
        sellerGroups: sellerGroups ?? this.sellerGroups,
        isLoading: isLoading ?? this.isLoading);
  }

  double get grandTotal {
    return sellerGroups.fold(0.0, (sum, group) => sum + group.totalAmountBySeller);
  }

  int get totalItemCount {
    return sellerGroups.fold(0, (sum, group) => sum + group.items.length);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final Ref _ref;
  CartNotifier(this._ref) : super(const CartState());

  String? _getToken() {
    return _ref.read(authProvider).currentUser?.token;
  }

  UserRepository get _userRepo => _ref.read(userRepositoryProvider);

  Future<void> fetchCart() async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true);
    final groups = await _userRepo.getCart(token);
    state = state.copyWith(sellerGroups: groups, isLoading: false);
  }

  Future<void> addToCart(int productId, int quantity) async {
    final token = _getToken();
    if (token == null) return;
    try {
      await _userRepo.addToCart(token, productId, quantity);
      await fetchCart();
    } catch (e) {
      print("addToCart provider error: $e");
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    final token = _getToken();
    if (token == null) return;

    final List<CartSellerGroup> optimisticGroups = [];
    for (var group in state.sellerGroups) {
      final updatedItems = group.items.where((item) => item.id != cartItemId).toList();
      if (updatedItems.isNotEmpty) {
        optimisticGroups.add(CartSellerGroup(
            sellerId: group.sellerId,
            sellerName: group.sellerName,
            totalAmountBySeller: group.totalAmountBySeller,
            items: updatedItems));
      }
    }
    state = state.copyWith(sellerGroups: optimisticGroups);

    final success = await _userRepo.removeFromCart(token, cartItemId);
    await fetchCart();

    if (!success) {
      print("Failed to remove item from backend.");
    }
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref);
});