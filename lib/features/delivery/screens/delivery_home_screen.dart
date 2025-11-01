import 'package:cnpm_ptpm/features/auth/screens/login_screen.dart';
import 'package:cnpm_ptpm/features/delivery/screens/available_orders_screen.dart';
import 'package:cnpm_ptpm/features/delivery/screens/assigned_orders_screen.dart';
import 'package:cnpm_ptpm/features/delivery/screens/delivery_profile_screen.dart';
import 'package:cnpm_ptpm/providers/auth_provider.dart';
import 'package:cnpm_ptpm/providers/delivery_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DeliveryHomeScreen extends ConsumerStatefulWidget {
  static const routeName = '/delivery-home';
  const DeliveryHomeScreen({super.key});

  @override
  ConsumerState<DeliveryHomeScreen> createState() => _DeliveryHomeScreenState();
}

class _DeliveryHomeScreenState extends ConsumerState<DeliveryHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchStats();
      }
    });
  }

  Future<void> _fetchStats() async {
    await ref.read(deliveryProvider.notifier).fetchDeliveryStats();
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
    final user = ref.watch(authProvider).currentUser;
    final deliveryState = ref.watch(deliveryProvider);
    final stats = deliveryState.stats;

    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: 0,
    );
    final earnings = currencyFormatter.format(stats?.totalEarnings ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Hi, ${user?.name ?? 'Driver'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).pushNamed(DeliveryProfileScreen.routeName);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchStats,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              elevation: 4,
              color: Colors.green,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'Earnings (Successfully Delivered)',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    if (deliveryState.isLoading && stats == null)
                      const CircularProgressIndicator(color: Colors.white)
                    else
                      Text(
                        '$earnings VNĐ',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatCard(
                  title: 'In Progress',
                  value: stats?.inProgressOrders.toString() ?? '...',
                  icon: Icons.delivery_dining,
                  color: Colors.blue,
                  isLoading: deliveryState.isLoading && stats == null,
                ),
                _StatCard(
                  title: 'Completed',
                  value: stats?.completedOrders.toString() ?? '...',
                  icon: Icons.check_circle,
                  color: Colors.green,
                  isLoading: deliveryState.isLoading && stats == null,
                ),
                _StatCard(
                  title: 'Canceled',
                  value: stats?.failedOrders.toString() ?? '...',
                  icon: Icons.cancel,
                  color: Colors.red,
                  isLoading: deliveryState.isLoading && stats == null,
                ),
                _StatCard(
                  title: 'Total Orders',
                  value: (stats != null)
                      ? (stats.inProgressOrders +
                      stats.completedOrders +
                      stats.failedOrders)
                      .toString()
                      : '...',
                  icon: Icons.receipt_long,
                  color: Colors.orange,
                  isLoading: deliveryState.isLoading && stats == null,
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                textStyle: const TextStyle(fontSize: 18),
              ),
              icon: const Icon(Icons.history),
              label: const Text('Current Deliveries'),
              onPressed: () {
                Navigator.of(context).pushNamed(AssignedOrdersScreen.routeName);
              },
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.teal,
                textStyle: const TextStyle(fontSize: 18),
              ),
              icon: const Icon(Icons.search),
              label: const Text('Find New Orders'),
              onPressed: () {
                Navigator.of(context).pushNamed(AvailableOrdersScreen.routeName);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isLoading;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                Icon(icon, color: color),
              ],
            ),
            const Spacer(),
            if (isLoading)
              const Center(child: CircularProgressIndicator(strokeWidth: 2))
            else
              Text(
                value,
                style:
                const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}