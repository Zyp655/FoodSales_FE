import 'dart:convert';

class Seller {
  int? id;
  String? name;
  String? image;
  String? email;
  String? address;
  String? description;
  String? phone;

  Seller({
    this.id,
    this.name,
    this.image,
    this.email,
    this.address,
    this.description,
    this.phone,
  });

  factory Seller.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> sellerData = map['seller'] ?? map;
    return Seller(
      id: (sellerData['id'] as num?)?.toInt(),
      name: sellerData['name'] as String?,
      image: sellerData['image'] as String?,
      email: sellerData['email'] as String?,
      address: sellerData['address'] as String?,
      description: sellerData['description'] as String?,
      phone: sellerData['phone'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'email': email,
      'address': address,
      'description': description,
      'phone': phone,
    };
  }

  String toJson() => json.encode(toMap());

  factory Seller.fromJson(String source) =>
      Seller.fromMap(json.decode(source));
}

extension SellerCopyWith on Seller {
  Seller copyWith({
    int? id,
    String? name,
    String? image,
    String? email,
    String? address,
    String? description,
    String? phone,
  }) {
    return Seller(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      email: email ?? this.email,
      address: address ?? this.address,
      description: description ?? this.description,
      phone: phone ?? this.phone,
    );
  }
}