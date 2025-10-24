import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/product.dart';
import 'package:cnpm_ptpm/repositories/seller_repository.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

final sellerRepositoryProvider = Provider<SellerRepository>((ref) {
  return SellerRepository();
});

@immutable
class SellerState {
  final List<Product> myProducts;
  final bool isLoading;
  final String? error;

  const SellerState({
    this.myProducts = const [],
    this.isLoading = false,
    this.error,
  });

  SellerState copyWith({
    List<Product>? myProducts,
    bool? isLoading,
    String? error,
  }) {
    return SellerState(
      myProducts: myProducts ?? this.myProducts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class SellerNotifier extends StateNotifier<SellerState> {
  final Ref _ref;
  SellerNotifier(this._ref) : super(const SellerState());

  String? _getToken() {
    return _ref.read(authProvider).currentUser?.token;
  }

  SellerRepository _getRepo() {
    return _ref.read(sellerRepositoryProvider);
  }

  Future<void> fetchMyProducts() async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final products = await _getRepo().getProductsBySeller(token);
      state = state.copyWith(isLoading: false, myProducts: products);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addProduct(Product product) async {
    final token = _getToken();
    if (token == null) return;
    state = state.copyWith(isLoading: true);
    await _getRepo().addProduct(token, product);
    fetchMyProducts();
  }
}

final sellerProvider =
StateNotifierProvider<SellerNotifier, SellerState>((ref) {
  return SellerNotifier(ref);
});