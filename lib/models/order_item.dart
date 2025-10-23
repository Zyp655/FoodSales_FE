import 'dart:convert';
import 'package:cnpm_ptpm/models/product.dart';

class OrderItem {
  int? id;
  int? orderId;
  int? productId;
  int? quantity;
  double? priceAtPurchase;
  Product? product;

  OrderItem({
    this.id,
    this.orderId,
    this.productId,
    this.quantity,
    this.priceAtPurchase,
    this.product,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: (map['id'] as num?)?.toInt(),
      orderId: (map['order_id'] as num?)?.toInt(),
      productId: (map['product_id'] as num?)?.toInt(),
      quantity: (map['quantity'] as num?)?.toInt(),
      priceAtPurchase: (map['price_at_purchase'] as num?)?.toDouble(),
      product:
      map['product'] != null ? Product.fromMap(map['product']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'quantity': quantity,
      'price_at_purchase': priceAtPurchase,
      'product': product?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  factory OrderItem.fromJson(String source) =>
      OrderItem.fromMap(json.decode(source));
}