import '../../../providers/seller_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'seller_orders_screen.dart';

class SellerAnalyticsScreen extends ConsumerStatefulWidget {
  static const routeName = '/seller-analytics';
  const SellerAnalyticsScreen({super.key});

  @override
  ConsumerState<SellerAnalyticsScreen> createState() =>
      _SellerAnalyticsScreenState();
}

class _SellerAnalyticsScreenState extends ConsumerState<SellerAnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    await ref.read(sellerProvider.notifier).fetchAnalytics();
  }

  void _navigateToFilteredOrders(String filterStatus) {
    Navigator.of(context).pushNamed(
      SellerOrdersScreen.routeName,
      arguments: filterStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sellerState = ref.watch(sellerProvider);
    final stats = sellerState.analytics;

    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: 'VNĐ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Analytics'),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: (sellerState.isAnalyticsLoading && stats == null)
            ? const Center(child: CircularProgressIndicator())
            : stats == null
            ? const Center(child: Text('No analytics data available.'))
            : ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              elevation: 4,
              color: Colors.green.shade700,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    const Text(
                      'Total Revenue (Delivered)',
                      style: TextStyle(
                          fontSize: 18, color: Colors.white70),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currencyFormatter.format(stats.totalRevenue),
                      style: const TextStyle(
                        fontSize: 34,
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
              crossAxisSpacing: 2,
              childAspectRatio: 1.7,
              children: [
                _StatCard(
                  title: 'Completed Orders',
                  value: stats.completedOrders.toString(),
                  icon: Icons.check_circle,
                  color: Colors.green,
                  onTap: () => _navigateToFilteredOrders('Completed'),
                ),
                _StatCard(
                  title: 'Pending Orders',
                  value: stats.pendingOrders.toString(),
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                  onTap: () => _navigateToFilteredOrders('Pending'),
                ),
                _StatCard(
                  title: 'In Transit',
                  value: stats.inTransitOrders.toString(),
                  icon: Icons.local_shipping,
                  color: Colors.blue,
                  onTap: () => _navigateToFilteredOrders('InTransit'),
                ),
                _StatCard(
                  title: 'Cancelled',
                  value: stats.cancelledOrders.toString(),
                  icon: Icons.cancel,
                  color: Colors.red,
                  onTap: () => _navigateToFilteredOrders('Cancelled'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Top 5 Selling Products',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    if (stats.topSellingProducts.isEmpty)
                      const Center(child: Text('No sales data yet.'))
                    else
                      ...stats.topSellingProducts.map((product) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading:
                          const Icon(Icons.inventory_2_outlined),
                          title: Text(product.productName),
                          trailing: Text(
                            '${product.totalQuantity} sold',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
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
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 2, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              Text(
                value,
                style:
                const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}