import 'package:cnpm_ptpm/features/user/screens/settings_screen.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cnpm_ptpm/features/auth/screens/login_screen.dart';

class ProfileScreen extends ConsumerWidget {
  static const routeName = '/profile';
  const ProfileScreen({super.key});

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
              child: Text(
                  user.name?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(fontSize: 40)),
            ),
          ),
          const SizedBox(height: 20),
          Center(
              child: Text(user.name ?? 'No Name',
                  style: Theme.of(context).textTheme.headlineSmall)),
          const SizedBox(height: 40),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(SettingsScreen.routeName);
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}