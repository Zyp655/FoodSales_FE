import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/seller.dart';
import 'package:cnpm_ptpm/models/product.dart';
import 'package:cnpm_ptpm/models/cart_item.dart';
import 'package:cnpm_ptpm/models/order.dart';
import 'package:cnpm_ptpm/models/category.dart';
import 'package:cnpm_ptpm/repositories/user_repository.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(userRepositoryProvider).getCategories();
});

// final sellersProvider = FutureProvider<List<Seller>>((ref) {
//   final repo = ref.watch(userRepositoryProvider);
//   return repo.getSellers();
// });

final productSearchProvider =
FutureProvider.family<List<Product>, ({int? sellerId, String? query})>(
        (ref, params) {
      final repo = ref.watch(userRepositoryProvider);
      return repo.searchProducts(
          sellerId: params.sellerId, query: params.query);
    });

@immutable
class CartState {
  final List<CartItem> items;
  final bool isLoading;
  const CartState({this.items = const [], this.isLoading = false});
  CartState copyWith({List<CartItem>? items, bool? isLoading}) {
    return CartState(
        items: items ?? this.items, isLoading: isLoading ?? this.isLoading);
  }
}

class CartNotifier extends StateNotifier<CartState> {
  final Ref _ref;
  CartNotifier(this._ref) : super(const CartState());

  String? _getToken() {
    return _ref.read(authProvider).currentUser?.token;
  }

  Future<void> fetchCart() async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(userRepositoryProvider);
    final items = await repo.getCart(token);
    state = state.copyWith(items: items, isLoading: false);
  }

  Future<void> addToCart(int productId, int quantity) async {
    final token = _getToken();
    if (token == null) return;
    final repo = _ref.read(userRepositoryProvider);
    await repo.addToCart(token, productId, quantity);
    fetchCart();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier(ref);
});

final userOrdersProvider = FutureProvider<List<Order>>((ref) {
  final token = ref.watch(authProvider).currentUser?.token;
  if (token == null) return [];
  final repo = ref.read(userRepositoryProvider);
  return repo.getOrdersByUser(token);
});