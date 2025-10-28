import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/seller.dart';
import 'package:cnpm_ptpm/models/product.dart';
import 'package:cnpm_ptpm/models/order.dart';
import 'package:cnpm_ptpm/models/category.dart';
import 'package:cnpm_ptpm/repositories/user_repository.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:cnpm_ptpm/models/cart_seller_group.dart';
import 'package:flutter_riverpod/legacy.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final categoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(userRepositoryProvider).getCategories();
});

final sellersProvider = FutureProvider<List<Seller>>((ref) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getSellers();
});

final productSearchProvider =
FutureProvider.family<List<Product>, ({int? sellerId, String? query})>(
        (ref, params) {
      final repo = ref.watch(userRepositoryProvider);
      return repo.searchProducts(
          sellerId: params.sellerId, query: params.query);
    });

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

  Future<void> fetchCart() async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(userRepositoryProvider);
    final groups = await repo.getCart(token);
    state = state.copyWith(sellerGroups: groups, isLoading: false);
  }

  Future<void> addToCart(int productId, int quantity) async {
    final token = _getToken();
    if (token == null) return;
    final repo = _ref.read(userRepositoryProvider);
    try {
      await repo.addToCart(token, productId, quantity);
      await fetchCart();
    } catch (e) {
      print("addToCart provider error: $e");
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    final token = _getToken();
    if (token == null) return;
    final repo = _ref.read(userRepositoryProvider);

    final List<CartSellerGroup> optimisticGroups = [];
    for (var group in state.sellerGroups) {
      final updatedItems =
      group.items.where((item) => item.id != cartItemId).toList();
      if (updatedItems.isNotEmpty) {
        optimisticGroups.add(CartSellerGroup(
            sellerId: group.sellerId,
            sellerName: group.sellerName,
            totalAmountBySeller: group.totalAmountBySeller,
            items: updatedItems));
      }
    }
    state = state.copyWith(sellerGroups: optimisticGroups);

    final success = await repo.removeFromCart(token, cartItemId);
    await fetchCart();

    if (!success) {
      print("Failed to remove item from backend.");
    }
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

final combinedSearchProvider =
FutureProvider.autoDispose.family<SearchResult, String>((ref, query) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.searchAll(query);
});