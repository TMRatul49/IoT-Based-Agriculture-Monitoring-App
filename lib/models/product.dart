class Product {
  int? id;
  String? name;
  String? description;
  double? address;
  int? user;

  Product({this.name, this.description, this.address, this.user});

  Product.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    address = json['address'];
    description = json['description'];
    user = json['user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'title': name,
      'description': description,
      'price': address,
      'user': user,
    };
    return data;
  }
}
