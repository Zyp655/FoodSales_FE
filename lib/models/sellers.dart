import 'dart:convert';

class Seller {
  int? id;
  String? name;
  String? image;
  String? email;
  String? address;
  String? description;

  Seller({
    this.id,
    this.name,
    this.image,
    this.email,
    this.address,
    this.description,
  });

  factory Seller.fromMap(Map<String, dynamic> map) {
    return Seller(
      id: (map['id'] as num?)?.toInt(),
      name: map['name'] as String?,
      image: map['image'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      description: map['description'] as String?,
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
    };
  }

  String toJson() => json.encode(toMap());

  factory Seller.fromJson(String source) =>
      Seller.fromMap(json.decode(source));
}