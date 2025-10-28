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

    double? safePrice;
    var priceValue = map['price_at_purchase'];
    if (priceValue != null) {
      if (priceValue is num) {
        safePrice = priceValue.toDouble();
      } else if (priceValue is String) {
        safePrice = double.tryParse(priceValue);
      }
    }

    int? safeQuantity;
    var quantityValue = map['quantity'];
    if (quantityValue != null) {
      if (quantityValue is num) {
        safeQuantity = quantityValue.toInt();
      } else if (quantityValue is String) {
        safeQuantity = int.tryParse(quantityValue);
      }
    }

    return OrderItem(
      id: (map['id'] as num?)?.toInt(),
      orderId: (map['order_id'] as num?)?.toInt(),
      productId: (map['product_id'] as num?)?.toInt(),

      quantity: safeQuantity,
      priceAtPurchase: safePrice,

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