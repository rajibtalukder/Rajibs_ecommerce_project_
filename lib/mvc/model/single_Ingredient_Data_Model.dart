// To parse this JSON data, do
//
//     final ingredinetListModel = ingredinetListModelFromJson(jsonString);

import 'dart:convert';

SingleIngredientData singleIngredientDataFromJson(String str) => SingleIngredientData.fromJson(json.decode(str));

String singleIngredientDataToJson(SingleIngredientData data) => json.encode(data.toJson());

class SingleIngredientData {
  SingleIngredientData({
    this.data,
  });

  SingleData? data;

  factory SingleIngredientData.fromJson(Map<String, dynamic> json) => SingleIngredientData(
    data: SingleData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data!.toJson(),
  };
}

class SingleData {
  SingleData({
    this.id,
    this.categoryName,
    this.unitName,
    this.name,
    this.purchasePrice,
    this.alertQty,
    this.code,
  });

  dynamic id;
  dynamic categoryName;
  dynamic unitName;
  dynamic name;
  dynamic purchasePrice;
  dynamic alertQty;
  dynamic code;

  factory SingleData.fromJson(Map<String, dynamic> json) => SingleData(
    id: json["id"]==null?"":json["id"],
    categoryName: json["category_name"]==null?"":json["category_name"],
    unitName: json["unit_name"]==null?"":json["unit_name"],
    name: json["name"]==null?"":json["name"],
    purchasePrice: json["purchase_price"]==null?"":json["purchase_price"],
    alertQty: json["alert_qty"]==null?"":json["alert_qty"],
    code: json["code"]==null?"":json["code"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category_name": categoryName,
    "unit_name": unitName,
    "name": name,
    "purchase_price": purchasePrice,
    "alert_qty": alertQty,
    "code": code,
  };
}
