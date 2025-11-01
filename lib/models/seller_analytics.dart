class TopProduct {
  final String productName;
  final int totalQuantity;

  TopProduct({required this.productName, required this.totalQuantity});

  factory TopProduct.fromMap(Map<String, dynamic> map) {
    return TopProduct(
      productName: map['product_name'] ?? 'Unknown',
      totalQuantity: (map['total_quantity'] as num?)?.toInt() ?? 0,
    );
  }
}

class SellerAnalytics {
  final double totalRevenue;
  final int completedOrders;
  final int pendingOrders;
  final int inTransitOrders;
  final int cancelledOrders;
  final List<TopProduct> topSellingProducts;

  SellerAnalytics({
    this.totalRevenue = 0.0,
    this.completedOrders = 0,
    this.pendingOrders = 0,
    this.inTransitOrders = 0,
    this.cancelledOrders = 0,
    this.topSellingProducts = const [],
  });

  factory SellerAnalytics.fromMap(Map<String, dynamic> map) {
    return SellerAnalytics(
      totalRevenue:
      double.tryParse(map['total_revenue']?.toString() ?? '0.0') ?? 0.0,
      completedOrders:
      int.tryParse(map['completed_orders']?.toString() ?? '0') ?? 0,
      pendingOrders:
      int.tryParse(map['pending_orders']?.toString() ?? '0') ?? 0,
      inTransitOrders:
      int.tryParse(map['in_transit_orders']?.toString() ?? '0') ?? 0,
      cancelledOrders:
      int.tryParse(map['cancelled_orders']?.toString() ?? '0') ?? 0,
      topSellingProducts: map['top_selling_products'] != null
          ? List<TopProduct>.from(
        (map['top_selling_products'] as List)
            .map((item) => TopProduct.fromMap(item)),
      )
          : [],
    );
  }
}