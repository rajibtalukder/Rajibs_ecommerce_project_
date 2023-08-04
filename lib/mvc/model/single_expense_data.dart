// To parse this JSON data, do
//
//     final singleExpenseData = singleExpenseDataFromJson(jsonString);

import 'dart:convert';

SingleExpenseData singleExpenseDataFromJson(String str) => SingleExpenseData.fromJson(json.decode(str));

String singleExpenseDataToJson(SingleExpenseData data) => json.encode(data.toJson());

class SingleExpenseData {
  SingleExpenseData({
    this.data,
  });

  Data? data;

  factory SingleExpenseData.fromJson(Map<String, dynamic> json) => SingleExpenseData(
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data!.toJson(),
  };
}

class Data {
  Data({
    required this.id,
    required this.person,
    required this.category,
    required this.date,
    required this.amount,
    required this.note,
    required this.status,
  });

  int id;
  Category person;
  Category category;
  DateTime date;
  String amount;
  String note;
  int status;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    person: Category.fromJson(json["person"]),
    category: Category.fromJson(json["category"]),
    date: DateTime.parse(json["date"]),
    amount: json["amount"],
    note: json["note"]??"",
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "person": person.toJson(),
    "category": category.toJson(),
    "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "amount": amount,
    "note": note,
    "status": status,
  };
}

class Category {
  Category({
    required this.id,
    required this.name,
  });

  int id;
  String name;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}
