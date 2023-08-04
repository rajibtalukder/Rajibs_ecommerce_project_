// To parse this JSON data, do
//
//     final ingredientSupplierSingleItem = ingredientSupplierSingleItemFromJson(jsonString);

import 'dart:convert';

IngredientSupplierSingleItem ingredientSupplierSingleItemFromJson(String str) => IngredientSupplierSingleItem.fromJson(json.decode(str));

String ingredientSupplierSingleItemToJson(IngredientSupplierSingleItem data) => json.encode(data.toJson());

class IngredientSupplierSingleItem {
  IngredientSupplierSingleItem({
     this.data,
  });

  Data? data;

  factory IngredientSupplierSingleItem.fromJson(Map<String, dynamic> json) => IngredientSupplierSingleItem(
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data!.toJson(),
  };
}

class Data {
  Data({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.reference,
    required this.address,
    required this.idCardFront,
    required this.idCardBack,
    required this.status,
  });

  int id;
  String name;
  String email;
  String phone;
  String reference;
  String address;
  String idCardFront;
  String idCardBack;
  int status;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    name: json["name"],
    email: json["email"],
    phone: json["phone"],
    reference: json["reference"],
    address: json["address"],
    idCardFront: json["id_card_front"],
    idCardBack: json["id_card_back"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "reference": reference,
    "address": address,
    "id_card_front": idCardFront,
    "id_card_back": idCardBack,
    "status": status,
  };
}
