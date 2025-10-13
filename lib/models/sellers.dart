class Sellers {
  int? id;
  String? name;
  String? image;
  String? email;
  String? address;
  String? description;

  Sellers.fromMap(Map<dynamic , dynamic> map){
    id= int.parse(map['id']);
    name= map['name'];
    image= map['image'];
    email= map['email'];
    address=map['address'];
    description= map['description'];


  }
}