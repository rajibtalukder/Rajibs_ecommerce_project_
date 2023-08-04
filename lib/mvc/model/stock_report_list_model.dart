// To parse this JSON data, do
//
//     final stockReportListModel = stockReportListModelFromJson(jsonString);

import 'dart:convert';

StockReportListModel stockReportListModelFromJson(String str) => StockReportListModel.fromJson(json.decode(str));

String stockReportListModelToJson(StockReportListModel data) => json.encode(data.toJson());

class StockReportListModel {
  List<Datum>? data;
  Links? links;
  Meta? meta;

  StockReportListModel({
     this.data,
     this.links,
     this.meta,
  });

  factory StockReportListModel.fromJson(Map<String, dynamic> json) => StockReportListModel(
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
  String? qtyAmount;
  Ingredient? ingredient;

  Datum({
     this.id,
     this.qtyAmount,
     this.ingredient,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    qtyAmount: json["qty_amount"],
    ingredient: Ingredient.fromJson(json["ingredient"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "qty_amount": qtyAmount,
    "ingredient": ingredient?.toJson(),
  };
}

class Ingredient {
  int id;
  String name;
  String code;
  int alertQty;
  Category category;
  Category? unit;

  Ingredient({
    required this.id,
    required this.name,
    required this.code,
    required this.alertQty,
    required this.category,
    this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    id: json["id"],
    name: json["name"],
    code: json["code"],
    alertQty: json["alert_qty"],
    category: Category.fromJson(json["category"]),
    unit: json["unit"] == null ? null : Category.fromJson(json["unit"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "alert_qty": alertQty,
    "category": category.toJson(),
    "unit": unit?.toJson(),
  };
}

class Category {
  int id;
  String name;

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}

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
