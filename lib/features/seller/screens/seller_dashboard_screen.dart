import 'package:cnpm_ptpm/features/seller/screens/manage_products_screen.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/features/auth/screens/login_screen.dart';
import '../widgets/seller_product_list.dart';
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
    const SellerProductList(),
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
        title: Text(_selectedIndex == 0 ? 'My Products' : 'Incoming Orders'),
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