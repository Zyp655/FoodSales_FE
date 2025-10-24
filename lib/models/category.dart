import 'dart:convert';

class Category {
  final int id;
  final String name;
  final String? slug;
  final String? description;

  Category({
    required this.id,
    required this.name,
    this.slug,
    this.description,
  });

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
      slug: map['slug'] as String?,
      description: map['description'] as String?,
    );
  }

  factory Category.fromJson(String source) =>
      Category.fromMap(json.decode(source) as Map<String, dynamic>);
}