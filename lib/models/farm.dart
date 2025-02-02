class Farm {
  int? id;
  String? name;
  String? address;
  String? description;
  int? user;

  Farm({this.id, this.name, this.address, this.description, this.user});

  Farm.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    address = json['address'];
    description = json['description'];
    user = json['user'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['address'] = this.address;
    data['description'] = this.description;
    data['user'] = this.user;
    return data;
  }
}