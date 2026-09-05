class CategoryIconResponse {
  final String message;
  final String code;
  final CategoryIcon category;

  CategoryIconResponse({
    required this.message,
    required this.code,
    required this.category,
  });

  factory CategoryIconResponse.fromJson(Map<String, dynamic> json) {
    return CategoryIconResponse(
      message: json["message"],
      code: json["code"],
      category: CategoryIcon.fromJson(json["data"]),
    );
  }
}

class CategoryIcon {
  final int? id;
  final String name;
  final String url;

  CategoryIcon({
    required this.id,
    required this.name,
    required this.url,
  });

  factory CategoryIcon.fromJson(Map<String, dynamic> json) {
    return CategoryIcon(
      id: json["id"],
      name: json["name"],
      url: json["url"],
    );
  }
}