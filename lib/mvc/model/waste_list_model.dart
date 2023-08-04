// To parse this JSON data, do
//
//     final wasteListModel = wasteListModelFromJson(jsonString);

import 'dart:convert';

WasteListModel wasteListModelFromJson(String str) => WasteListModel.fromJson(json.decode(str));

String wasteListModelToJson(WasteListModel data) => json.encode(data.toJson());

class WasteListModel {
  WasteListModel({
    required this.data,
  });

  List<Datum> data;

  factory WasteListModel.fromJson(Map<String, dynamic> json) => WasteListModel(
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Datum {
  Datum({
    required this.id,
    required this.personName,
    required this.referenceNo,
    required this.date,
    required this.note,
    required this.addedBy,
    required this.totalLoss,
  });

  int id;
  String personName;
  String referenceNo;
  DateTime date;
  String note;
  String addedBy;
  String totalLoss;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    personName: json["person_name"],
    referenceNo: json["reference_no"],
    date: DateTime.parse(json["date"]),
    note: json["note"],
    addedBy: json["added_by"],
    totalLoss: json["total_loss"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "person_name": personName,
    "reference_no": referenceNo,
    "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "note": note,
    "added_by": addedBy,
    "total_loss": totalLoss,
  };
}
