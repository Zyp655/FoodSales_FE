import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/seller.dart';
import 'package:cnpm_ptpm/models/product.dart';
import 'package:cnpm_ptpm/models/category.dart';
import 'package:cnpm_ptpm/repositories/user_repository.dart';

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

final combinedSearchProvider =
FutureProvider.autoDispose.family<SearchResult, String>((ref, query) {
  final repo = ref.watch(userRepositoryProvider);
  return repo.searchAll(query);
});