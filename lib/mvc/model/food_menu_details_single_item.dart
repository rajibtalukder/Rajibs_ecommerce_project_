// To parse this JSON data, do
//
//     final fooodMenueDetailsSingleItem = fooodMenueDetailsSingleItemFromJson(jsonString);

import 'dart:convert';

import 'package:klio_staff/mvc/model/food_menu_addons.dart';

FooodMenueDetailsSingleItem fooodMenueDetailsSingleItemFromJson(String str) => FooodMenueDetailsSingleItem.fromJson(json.decode(str));

String fooodMenueDetailsSingleItemToJson(FooodMenueDetailsSingleItem data) => json.encode(data.toJson());

class FooodMenueDetailsSingleItem {
  FooodMenueDetailsSingleItem({
    this.data,
  });

  SingleMenuDetailsData? data;

  factory FooodMenueDetailsSingleItem.fromJson(Map<String, dynamic> json) => FooodMenueDetailsSingleItem(
    data: SingleMenuDetailsData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data!.toJson(),
  };
}

class SingleMenuDetailsData {
  SingleMenuDetailsData({
    this.id,
    this.name,
    this.image,
    this.price,
    this.calories,
    this.processingTime,
    this.taxVat,
    this.description,
    this.addons,
    this.variants,
    this.variant,
    this.mealPeriods,
    this.allergies,
    this.categories
  });

  int ? id;
  String ? name;
  String ? image;
  String ? price;
  String ? calories;
  int ? processingTime;
  String? taxVat;
  String? description;
  Addons? addons;
  Addons? variants;
  String? variant;
  MealPeriods? mealPeriods;
  Allergies? allergies;
  Categories? categories;

  factory SingleMenuDetailsData.fromJson(Map<String, dynamic> json) => SingleMenuDetailsData(
    id: json["id"],
    name: json["name"],
    image: json["image"],
    price: json["price"],
    calories: json["calorie"],
    processingTime: json["processing_time"],
    taxVat: json["tax_vat"],
    description: json["description"],
    addons: Addons.fromJson(json["addons"]),
    variant: json["variant"] ?? " ",
    mealPeriods : MealPeriods.fromJson(json["mealPeriods"]),
    allergies : Allergies.fromJson(json["allergies"]),
    categories : Categories.fromJson(json["categories"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "price": price,
    "tax_vat": taxVat,
    "description": description,
    "addons": addons!.toJson(),
    "variants": variants!.toJson(),
    "variant": variant,
    "mealPeriods" : mealPeriods!.toJson(),
    "allergies" : allergies!.toJson(),
    "categories" : categories!.toJson(),
  };
}
class MealPeriods {
  MealPeriods({
    required this.data,
  });
  late final List<MenuAddon> data;

  MealPeriods.fromJson(Map<String, dynamic> json){
    data = List.from(json['data']).map((e)=>MenuAddon.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['data'] = data.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class Addons {
  Addons({
    this.data,
  });

  List<MenuAddon>? data;

  factory Addons.fromJson(Map<String, dynamic> json) => Addons(
    data: List<MenuAddon>.from(json["data"].map((x) => MenuAddon.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Allergies {
  Allergies({
    required this.data,
  });
  List<MenuAddon>? data;

  Allergies.fromJson(Map<String, dynamic> json){
    data = List.from(json['data']).map((e)=>MenuAddon.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['data'] = data!.map((e)=>e.toJson()).toList();
    return _data;
  }
}


class Categories {
  Categories({
    required this.data,
  });
  List<MenuAddon>? data;

  Categories.fromJson(Map<String, dynamic> json){
    data = List.from(json['data']).map((e)=>MenuAddon.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['data'] = data!.map((e)=>e.toJson()).toList();
    return _data;
  }
}

//
// class Variant {
//   Variant({
//     this.data,
//   });
//
//   List<MenuAddon>? data;
//
//   factory Variant.fromJson(Map<String, dynamic> json) => Variant(
//     data: List<MenuAddon>.from(json["data"].map((x) => MenuAddon.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "data": List<dynamic>.from(data!.map((x) => x.toJson())),
//   };
// }