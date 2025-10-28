import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'store_info_screen.dart'; 
import 'seller_change_password_screen.dart';

class SellerSettingsScreen extends ConsumerWidget {
  static const routeName = '/seller-settings';
  const SellerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Store Settings')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.store_outlined),
            title: const Text('Store Information'),
            subtitle: const Text('Edit name, image, address, etc.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(StoreInfoScreen.routeName);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            subtitle: const Text('Update your account password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(SellerChangePasswordScreen.routeName);
            },
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}