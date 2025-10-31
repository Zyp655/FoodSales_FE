class DeliveryStats {
  final double totalEarnings;
  final int completedOrders;
  final int inProgressOrders;
  final int failedOrders;

  DeliveryStats({
    this.totalEarnings = 0.0,
    this.completedOrders = 0,
    this.inProgressOrders = 0,
    this.failedOrders = 0,
  });

  factory DeliveryStats.fromMap(Map<String, dynamic> map) {
    return DeliveryStats(
      totalEarnings: double.tryParse(map['total_earnings']?.toString() ?? '0.0') ?? 0.0,
      completedOrders: int.tryParse(map['completed_orders']?.toString() ?? '0') ?? 0,
      inProgressOrders: int.tryParse(map['in_progress_orders']?.toString() ?? '0') ?? 0,
      failedOrders: int.tryParse(map['failed_orders']?.toString() ?? '0') ?? 0,
    );
  }
}