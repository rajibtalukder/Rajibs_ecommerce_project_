// To parse this JSON data, do
//
//     final allOrdersModel = allOrdersModelFromJson(jsonString);

import 'dart:convert';

AllOrdersModel allOrdersModelFromJson(String str) => AllOrdersModel.fromJson(json.decode(str));

String allOrdersModelToJson(AllOrdersModel data) => json.encode(data.toJson());

class AllOrdersModel {
  List<Datum>? data;
  Links? links;
  Meta? meta;

  AllOrdersModel({
     this.data,
     this.links,
     this.meta,
  });

  factory AllOrdersModel.fromJson(Map<String, dynamic> json) => AllOrdersModel(
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
  String? invoice;
  String? customerName;
  String? type;
  String? status;
  String? grandTotal;

  Datum({
    this.id,
    this.invoice,
    this.customerName,
    this.type,
    this.status,
    this.grandTotal,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    invoice: json["invoice"],
    customerName: json["customer_name"],
    type: json["type"],
    status: json["status"]??"",
    grandTotal: json["grand_total"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "invoice": invoice,
    "customer_name": customerName,
    "type": type,
    "status": status,
    "grand_total": grandTotal,
  };
}

// enum Status { PROCESSING }
//
// final statusValues = EnumValues({
//   "processing": Status.PROCESSING
// });
//
// enum Type { DELIVERY, TAKEWAY, DINE_IN }
//
// final typeValues = EnumValues({
//   "Delivery": Type.DELIVERY,
//   "Dine In": Type.DINE_IN,
//   "Takeway": Type.TAKEWAY
// });

class Links {
  String? first;
  String? last;
  dynamic prev;
  String? next;

  Links({
    required this.first,
    required this.last,
    this.prev,
    required this.next,
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
  int currentPage;
  int? from;
  int lastPage;
  List<Link> links;
  String path;
  int perPage;
  int? to;
  int total;

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
    "links": List<dynamic>.from(links.map((x) => x.toJson())),
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
