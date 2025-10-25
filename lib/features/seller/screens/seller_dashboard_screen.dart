import 'package:cnpm_ptpm/features/seller/screens/manage_products_screen.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:cnpm_ptpm/providers/seller_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/features/auth/screens/login_screen.dart';
import 'seller_orders_screen.dart';

class SellerDashboardScreen extends ConsumerStatefulWidget {
  static const routeName = '/seller-dashboard';
  const SellerDashboardScreen({super.key});

  @override
  ConsumerState<SellerDashboardScreen> createState() =>
      _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends ConsumerState<SellerDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const _SellerProductsTab(),
    const SellerOrdersScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout() {
    ref.read(authProvider.notifier).logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (ctx) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIndex == 0 ? 'My Products' : 'Incoming Orders'), // Title changes based on tab
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (ctx) => const ManageProductsScreen(),
          ));
        },
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}

class _SellerProductsTab extends ConsumerStatefulWidget {
  const _SellerProductsTab();

  @override
  ConsumerState<_SellerProductsTab> createState() => _SellerProductsTabState();
}

class _SellerProductsTabState extends ConsumerState<_SellerProductsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(sellerProvider).myProducts.isEmpty && !ref.read(sellerProvider).isLoading) {
        ref.read(sellerProvider.notifier).fetchMyProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sellerState = ref.watch(sellerProvider);
    final products = sellerState.myProducts;

    if (sellerState.isLoading && products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (sellerState.error != null) {
      return Center(child: Text('Error loading products: ${sellerState.error}'));
    }
    if (products.isEmpty) {
      return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('You have no products yet. Add one!'),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
                onPressed: () => ref.read(sellerProvider.notifier).fetchMyProducts(),
              )
            ],
          )
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(sellerProvider.notifier).fetchMyProducts(),
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (ctx, index) {
          final product = products[index];
          return ListTile(
              leading: CircleAvatar(
                backgroundImage: (product.image != null)
                    ? NetworkImage(
                    'http://10.0.2.2:8000/storage/${product.image!}')
                    : null,
                onBackgroundImageError: (exception, stackTrace) {},
                child: (product.image == null)
                    ? const Icon(Icons.shopping_bag)
                    : null,
              ),
              title: Text(product.name ?? 'No Name'),
              subtitle: Text('Price: \$${product.pricePerKg?.toStringAsFixed(2) ?? '0.00'} / kg'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Edit',
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) =>
                            ManageProductsScreen(product: product),
                      ));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Delete',
                    onPressed: () {
                      ref.read(sellerProvider.notifier).deleteProduct(product.id!);
                      print('Delete product ${product.id} (Not implemented)');
                    },
                  ),
                ],
              )
          );
        },
      ),
    );
  }
}