class SearchProductModel {
  final int id;
  final String name;
  final double price;


  SearchProductModel({
    required this.id,
    required this.name,
    required this.price,

});

  factory SearchProductModel.fromJson(Map<String , dynamic> json ){
    return SearchProductModel(
        id : json['id'],
      name: json['name'],
      price: json['price'],
    );
  }
}