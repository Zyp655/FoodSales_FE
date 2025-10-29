import 'package:cnpm_ptpm/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/order.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';

final userOrdersProvider = FutureProvider<List<Order>>((ref) {
  final token = ref.watch(authProvider).currentUser?.token;
  if (token == null) return [];
  final repo = ref.read(userRepositoryProvider);
  return repo.getOrdersByUser(token);
});

final orderDetailProvider = FutureProvider.family<Order?, int>((ref, orderId) async {
  final token = ref.watch(authProvider).currentUser?.token;
  if (token == null) {
    throw Exception('Not authenticated');
  }
  final repo = ref.read(userRepositoryProvider);
  return repo.getOrderDetails(token, orderId);
});