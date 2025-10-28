import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'contact_info_screen.dart'; // Import new screen
import 'change_password_screen.dart'; // Import new screen
import 'package:cnpm_ptpm/providers/auth_provider.dart'; // For Logout
import 'package:cnpm_ptpm/features/auth/screens/login_screen.dart'; // For Logout

class SettingsScreen extends ConsumerWidget { // Can be ConsumerWidget now
  static const routeName = '/settings';
  const SettingsScreen({super.key});

  void _logout(BuildContext context, WidgetRef ref) {
    ref.read(authProvider.notifier).logout();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.contact_page_outlined),
            title: const Text('Contact Information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(ContactInfoScreen.routeName);
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(ChangePasswordScreen.routeName);
            },
          ),
          const Divider(height: 1),
          ListTile( // Optional: Logout here or keep in ProfileScreen AppBar
            leading: Icon(Icons.logout, color: Colors.red.shade700),
            title: Text('Logout', style: TextStyle(color: Colors.red.shade700)),
            onTap: () => _logout(context, ref),
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}