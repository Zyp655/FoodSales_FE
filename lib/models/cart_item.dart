// lib/models/cart_item.dart
import 'dart:convert';

import 'package:cnpm_ptpm/models/product.dart';


class CartItem {
  int? id;
  int? userId;
  int? productId;
  int? quantity;
  Product? product;

  CartItem({
    this.id,
    this.userId,
    this.productId,
    this.quantity,
    this.product,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: (map['id'] as num?)?.toInt(),
      userId: (map['user_id'] as num?)?.toInt(),
      productId: (map['product_id'] as num?)?.toInt(),
      quantity: (map['quantity'] as num?)?.toInt(),
      product:
      map['product'] != null ? Product.fromMap(map['product']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'product': product?.toMap(),
    };
  }

  String toJson() => json.encode(toMap());

  factory CartItem.fromJson(String source) =>
      CartItem.fromMap(json.decode(source));
}