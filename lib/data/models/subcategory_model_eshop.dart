// This file contains all the model classes for the API response

class SubcategoryData {
  final int id;
  final String name;
  final String description;
  final String image;
  final String categoryName;

  SubcategoryData({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.categoryName,
  });

  factory SubcategoryData.fromJson(Map<String, dynamic> json) {
    return SubcategoryData(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      categoryName: json['category_name'],
    );
  }
}

class SubcategoryItem {
  final String message;
  final String code;
  final SubcategoryData data;

  SubcategoryItem({
    required this.message,
    required this.code,
    required this.data,
  });

  factory SubcategoryItem.fromJson(Map<String, dynamic> json) {
    return SubcategoryItem(
      message: json['message'],
      code: json['code'],
      data: SubcategoryData.fromJson(json['data']),
    );
  }
}

class SubcategoryApiResponse {
  final List<SubcategoryItem> content;
  final bool empty;
  final bool first;
  final bool last;
  final int number;
  final int numberOfElements;
  final int size;
  final int totalElements;
  final int totalPages;

  SubcategoryApiResponse({
    required this.content,
    required this.empty,
    required this.first,
    required this.last,
    required this.number,
    required this.numberOfElements,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory SubcategoryApiResponse.fromJson(Map<String, dynamic> json) {
    var list = json['content'] as List;
    List<SubcategoryItem> contentList =
    list.map((i) => SubcategoryItem.fromJson(i)).toList();

    return SubcategoryApiResponse(
      content: contentList,
      empty: json['empty'],
      first: json['first'],
      last: json['last'],
      number: json['number'],
      numberOfElements: json['numberOfElements'],
      size: json['size'],
      totalElements: json['totalElements'],
      totalPages: json['totalPages'],
    );
  }
}