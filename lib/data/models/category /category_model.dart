class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final String icon;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    required this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String,
    );
  }
}