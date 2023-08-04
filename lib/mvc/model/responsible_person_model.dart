// To parse this JSON data, do
//
//     final responsiblePersonModel = responsiblePersonModelFromJson(jsonString);

import 'dart:convert';

List<ResponsiblePersonModel> responsiblePersonModelFromJson(String str) => List<ResponsiblePersonModel>.from(json.decode(str).map((x) => ResponsiblePersonModel.fromJson(x)));

String responsiblePersonModelToJson(List<ResponsiblePersonModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ResponsiblePersonModel {
  int? id;
  String? name;

  ResponsiblePersonModel({
     this.id,
     this.name,
  });

  factory ResponsiblePersonModel.fromJson(Map<String, dynamic> json) => ResponsiblePersonModel(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
