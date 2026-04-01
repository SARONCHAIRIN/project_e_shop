class AddressModel {

  final int? id;
  final String city;
  final String country;
  final String addressline1;
  final String zipcode;
  final bool isdefault;

  AddressModel({
     this.id,
    required this.city,
    required this.country,
    required this.addressline1,
    required this.zipcode,
    required this.isdefault,

});

  factory AddressModel.fromJson(Map<String , dynamic> json){
    return AddressModel(
      id:  json['id'],
      city: json['city'],
      country: json['country'],
      addressline1: json['address_line1'],
      zipcode: json['zip_code'],
      isdefault: json['is_default']
    );
  }

  Map<String , dynamic> toJson() {
    return {
      'city' : city,
      'country' : country,
      'address_line1' : addressline1,
      'zip_code' : zipcode,
      'is_default' : isdefault,
  };
  }
}