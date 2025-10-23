import 'dart:convert';

class Category {
  int? id;
  String? name;
  String? slug;
  String? description;

  Category({
    this.id,
    this.name,
    this.slug,
    this.description,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: (map['id'] as num?)?.toInt(),
      name: map['name'] as String?,
      slug: map['slug'] as String?,
      description: map['description'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
    };
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String source) =>
      Category.fromMap(json.decode(source));
}