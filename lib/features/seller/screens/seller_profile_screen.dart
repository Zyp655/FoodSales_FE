import 'package:cnpm_ptpm/features/auth/screens/login_screen.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'seller_settings_screen.dart';
import 'seller_analytics_screen.dart';

class SellerProfileScreen extends ConsumerWidget {
  static const routeName = '/seller-profile';
  const SellerProfileScreen({super.key});

  void _logout(BuildContext context, WidgetRef ref) {
    ref.read(authProvider.notifier).logout();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _logout(context, ref),
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Not logged in.'))
          : ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: (user.image != null && user.image!.isNotEmpty)
                  ? NetworkImage('http://10.0.2.2:8000/storage/${user.image!}')
                  : null,
              onBackgroundImageError: (user.image != null && user.image!.isNotEmpty)
                  ? (e, s) {}
                  : null,
              child: (user.image == null || user.image!.isEmpty)
                  ? Text(
                  user.name?.substring(0, 1).toUpperCase() ?? 'S',
                  style: const TextStyle(fontSize: 40))
                  : null,
            ),
          ),
          const SizedBox(height: 20),
          Center(
              child: Text(user.name ?? 'No Name',
                  style: Theme.of(context).textTheme.headlineSmall)),
          Center(
              child: Text(user.email ?? 'No Email',
                  style: Theme.of(context).textTheme.bodyMedium)),
          const SizedBox(height: 40),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: const Text('Analytics'),
            subtitle: const Text('View your sales and profit'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(SellerAnalyticsScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            subtitle: const Text('Manage account and store info'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(SellerSettingsScreen.routeName);
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}