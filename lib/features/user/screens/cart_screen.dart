import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:cnpm_ptpm/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/models/cart_item.dart';
import 'product_detail_screen.dart';

class CartScreen extends ConsumerStatefulWidget {
  static const routeName = '/cart';

  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isCreatingOrder = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(cartProvider.notifier).fetchCart();
      }
    });
  }

  Future<void> _createOrder(int sellerId, double totalAmount) async {
    final token = ref.read(authProvider).currentUser?.token;
    final user = ref.read(authProvider).currentUser;

    if (token == null ||
        user == null ||
        user.address == null ||
        user.address!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in and ensure your address is set.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isCreatingOrder = true;
    });

    try {
      final repo = ref.read(userRepositoryProvider);
      await repo.createOrder(token, user.address!, sellerId, totalAmount);

      if (mounted) {
        await ref.read(cartProvider.notifier).fetchCart();

        ref.refresh(userOrdersProvider);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created successfully!')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingOrder = false;
        });
      }
    }
  }

  void _onItemDismissed(CartItem item) {
    ref.read(cartProvider.notifier).removeFromCart(item.id!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.product?.name ?? 'Item'} removed from cart.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final sellerGroups = cartState.sellerGroups;
    final grandTotal = cartState.grandTotal;

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cartState.isLoading && sellerGroups.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : sellerGroups.isEmpty
          ? const Center(child: Text('Your cart is empty. Go shopping!'))
          : Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(cartProvider.notifier).fetchCart(),
              child: ListView.builder(
                itemCount: sellerGroups.length,
                itemBuilder: (ctx, groupIndex) {
                  final group = sellerGroups[groupIndex];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    elevation: 3,
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        Container(
                          color: Colors.grey.shade100,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.storefront,
                                color: Colors.grey[700],
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  group.sellerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: group.items.length,
                          itemBuilder: (ctx, itemIndex) {
                            final item = group.items[itemIndex];
                            final product = item.product;
                            if (product == null) {
                              return const SizedBox.shrink();
                            }

                            return Dismissible(
                              key: ValueKey(item.id),
                              direction: DismissDirection.endToStart,
                              onDismissed: (direction) {
                                _onItemDismissed(item);
                              },
                              background: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(
                                  right: 20.0,
                                ),
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: (product.image != null)
                                      ? NetworkImage(
                                    'http://10.0.2.2:8000/storage/${product.image!}',
                                  )
                                      : null,
                                  onBackgroundImageError:
                                  (product.image != null)
                                      ? (e, s) {}
                                      : null,
                                  child: (product.image == null)
                                      ? const Icon(Icons.shopping_bag)
                                      : null,
                                ),
                                title: Text(product.name ?? 'No Name'),
                                subtitle: Text(
                                  'Quantity: ${item.quantity}',
                                ),
                                trailing: Text(
                                  '${((product.pricePerKg ?? 0.0) * (item.quantity ?? 0)).toStringAsFixed(0)}đ',
                                ),
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    ProductDetailScreen.routeName,
                                    arguments: product,
                                  );
                                },
                              ),
                            );
                          },
                        ),

                        const Divider(height: 1, thickness: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '${group.totalAmountBySeller.toStringAsFixed(0)}đ',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _isCreatingOrder
                                    ? null
                                    : () => _createOrder(
                                  group.sellerId,
                                  group.totalAmountBySeller,
                                ),
                                child: _isCreatingOrder
                                    ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                    : const Text('Checkout'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Grand Total:',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text('${grandTotal.toStringAsFixed(0)}đ',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
