// To parse this JSON data, do
//
//     final singleProductionUnit = singleProductionUnitFromJson(jsonString);

import 'dart:convert';

SingleProductionUnit singleProductionUnitFromJson(String str) => SingleProductionUnit.fromJson(json.decode(str));

String singleProductionUnitToJson(SingleProductionUnit data) => json.encode(data.toJson());

class SingleProductionUnit {
  Data? data;

  SingleProductionUnit({
     this.data,
  });

  factory SingleProductionUnit.fromJson(Map<String, dynamic> json) => SingleProductionUnit(
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data?.toJson(),
  };
}

class Data {
  int id;
  Food food;
  Food variant;
  Items items;

  Data({
    required this.id,
    required this.food,
    required this.variant,
    required this.items,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    food: Food.fromJson(json["food"]),
    variant: Food.fromJson(json["variant"]),
    items: Items.fromJson(json["items"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "food": food.toJson(),
    "variant": variant.toJson(),
    "items": items.toJson(),
  };
}

class Food {
  int id;
  String name;

  Food({
    required this.id,
    required this.name,
  });

  factory Food.fromJson(Map<String, dynamic> json) => Food(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

class Items {
  List<Datum> data;

  Items({
    required this.data,
  });

  factory Items.fromJson(Map<String, dynamic> json) => Items(
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  Food ingredient;
  int quantity;
  String unit;
  String price;
  int id;

  Datum({
    required this.ingredient,
    required this.id,
    required this.quantity,
    required this.unit,
    required this.price,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    ingredient: Food.fromJson(json["ingredient"]),
    quantity: json["quantity"],
    unit: json["unit"],
    price: json["price"],
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "ingredient": ingredient.toJson(),
    "quantity": quantity,
    "unit": unit,
    "price": price,
    "id": id,
  };
}
