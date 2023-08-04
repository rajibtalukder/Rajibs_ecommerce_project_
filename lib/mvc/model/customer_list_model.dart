// To parse this JSON data, do
//
//     final customer = customerFromJson(jsonString);

import 'dart:convert';

CustomerListModel customerListModelFromJson(String str) => CustomerListModel.fromJson(json.decode(str));

String customerListModelToJson(CustomerListModel data) => json.encode(data.toJson());

class CustomerListModel {
  CustomerListModel({
    this.data,
  });

  List <Data>? data;

  factory CustomerListModel.fromJson(Map<String, dynamic> json) => CustomerListModel(
    data: List<Data>.from(json["data"].map((x) => Data.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Data {
  Data({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.deliveryAddress,
    this.noOfVisit,
    this.lastVisit,
    this.pointsAcquired,
    this.usedPoints,
  });

  dynamic id;
  dynamic name;
  dynamic email;
  dynamic phone;
  dynamic deliveryAddress;
  dynamic noOfVisit;
  dynamic lastVisit;
  dynamic pointsAcquired;
  dynamic usedPoints;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"]?? '',
    name: json["name"] ?? '',
    email: json["email"] ?? '',
    phone: json["phone"] ?? '',
    deliveryAddress: json["delivery_address"] ?? '',
    noOfVisit: json["no_of_visit"] ?? '',
    lastVisit: json["last_visit"] ?? '',
    pointsAcquired: json["points_acquired"] ?? '',
    usedPoints: json["used_points"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "email": email,
    "phone": phone,
    "delivery_address": deliveryAddress,
    "no_of_visit": noOfVisit,
    "last_visit": lastVisit,
    "points_acquired": pointsAcquired,
    "used_points": usedPoints,
  };
}