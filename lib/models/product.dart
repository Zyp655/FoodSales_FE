import 'dart:convert';
import 'seller.dart'; // <<< IMPORT SELLER MODEL

class Product {
  int? id;
  int? sellerId;
  int? categoryId;
  String? name;
  String? image;
  double? pricePerKg;
  String? description;
  int? interactionCount;
  Seller? seller;

  Product({
    this.id,
    this.sellerId,
    this.categoryId,
    this.name,
    this.image,
    this.pricePerKg,
    this.description,
    this.interactionCount,
    this.seller,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    double? price;
    if (map['price_per_kg'] != null) {
      if (map['price_per_kg'] is String) {
        price = double.tryParse(map['price_per_kg']);
      } else if (map['price_per_kg'] is num) {
        price = (map['price_per_kg'] as num).toDouble();
      }
    }

    int? interaction;
    if (map['interaction_count'] != null) {
      interaction = int.tryParse(map['interaction_count'].toString()) ?? 0;
    } else {
      interaction = 0;
    }


    return Product(
      id: (map['id'] as num?)?.toInt(),
      sellerId: (map['seller_id'] as num?)?.toInt(),
      categoryId: (map['category_id'] as num?)?.toInt(),
      name: map['name'] as String?,
      image: map['image'] as String?,
      pricePerKg: price,
      description: map['description'] as String?,
      interactionCount: interaction,
      seller: map['seller'] != null && map['seller'] is Map
          ? Seller.fromMap(map['seller'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'image': image,
      'price_per_kg': pricePerKg,
      'description': description,
      'category_id': categoryId,
    };
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source) as Map<String, dynamic>);
}