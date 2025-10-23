import 'dart:convert';

class Product {
  int? id;
  int? sellerId;
  int? categoryId;
  String? name;
  String? image;
  double? pricePerKg;
  String? description;
  int? interactionCount;

  Product({
    this.id,
    this.sellerId,
    this.categoryId,
    this.name,
    this.image,
    this.pricePerKg,
    this.description,
    this.interactionCount,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] as num?)?.toInt(),
      sellerId: (map['seller_id'] as num?)?.toInt(),
      categoryId: (map['category_id'] as num?)?.toInt(),
      name: map['name'] as String?,
      image: map['image'] as String?,
      // Dùng (num?)?.toDouble() để an toàn cho cả int và double từ JSON
      pricePerKg: (map['price_per_kg'] as num?)?.toDouble(),
      description: map['description'] as String?,
      interactionCount: (map['interaction_count'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'seller_id': sellerId,
      'category_id': categoryId,
      'name': name,
      'image': image,
      'price_per_kg': pricePerKg,
      'description': description,
      'interaction_count': interactionCount,
    };
  }

  String toJson() => json.encode(toMap());

  factory Product.fromJson(String source) =>
      Product.fromMap(json.decode(source));
}