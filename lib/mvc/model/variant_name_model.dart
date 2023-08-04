// To parse this JSON data, do
//
//     final variantNameModel = variantNameModelFromJson(jsonString);

import 'dart:convert';

List<VariantNameModel> variantNameModelFromJson(String str) => List<VariantNameModel>.from(json.decode(str).map((x) => VariantNameModel.fromJson(x)));

String variantNameModelToJson(List<VariantNameModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class VariantNameModel {
  int? id;
  String? name;

  VariantNameModel({
    this.id,
    this.name,
  });

  factory VariantNameModel.fromJson(Map<String, dynamic> json) => VariantNameModel(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}