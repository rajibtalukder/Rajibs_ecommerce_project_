// To parse this JSON data, do
//
//     final wasteReportListModel = wasteReportListModelFromJson(jsonString);

import 'dart:convert';

WasteReportListModel wasteReportListModelFromJson(String str) => WasteReportListModel.fromJson(json.decode(str));

String wasteReportListModelToJson(WasteReportListModel data) => json.encode(data.toJson());

class WasteReportListModel {
  List<Datum>? data;
  Links? links;
  Meta? meta;

  WasteReportListModel({
     this.data,
     this.links,
     this.meta,
  });

  factory WasteReportListModel.fromJson(Map<String, dynamic> json) => WasteReportListModel(
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    links: Links.fromJson(json["links"]),
    meta: Meta.fromJson(json["meta"]),
  );

  Map<String, dynamic> toJson() => {
    "data": List<dynamic>.from(data!.map((x) => x.toJson())),
    "links": links!.toJson(),
    "meta": meta!.toJson(),
  };
}

class Datum {
  int? id;
  String? personName;
  String? referenceNo;
  DateTime? date;
  String? note;
  String? addedBy;
  String? totalLoss;

  Datum({
     this.id,
     this.personName,
     this.referenceNo,
     this.date,
     this.note,
     this.addedBy,
     this.totalLoss,
  });

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
    "date": "${date?.year.toString().padLeft(4, '0')}-${date?.month.toString().padLeft(2, '0')}-${date?.day.toString().padLeft(2, '0')}",
    "note": note,
    "added_by": addedBy,
    "total_loss": totalLoss,
  };
}

enum AddedBy { STAFF }

final addedByValues = EnumValues({
  "Staff": AddedBy.STAFF
});

class Links {
  String first;
  String last;
  dynamic prev;
  dynamic next;

  Links({
    required this.first,
    required this.last,
    this.prev,
    this.next,
  });

  factory Links.fromJson(Map<String, dynamic> json) => Links(
    first: json["first"],
    last: json["last"],
    prev: json["prev"],
    next: json["next"],
  );

  Map<String, dynamic> toJson() => {
    "first": first,
    "last": last,
    "prev": prev,
    "next": next,
  };
}

class Meta {
  int? currentPage;
  int? from;
  int? lastPage;
  List<Link>? links;
  String? path;
  int? perPage;
  int? to;
  int? total;

  Meta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.links,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) => Meta(
    currentPage: json["current_page"],
    from: json["from"],
    lastPage: json["last_page"],
    links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
    path: json["path"],
    perPage: json["per_page"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "from": from,
    "last_page": lastPage,
    //"links": List<dynamic>.from(links.map((x) => x.toJson())),
    "path": path,
    "per_page": perPage,
    "to": to,
    "total": total,
  };
}

class Link {
  String? url;
  String label;
  bool active;

  Link({
    this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
    url: json["url"],
    label: json["label"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "active": active,
  };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
