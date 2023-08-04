// To parse this JSON data, do
//
//     final singlePurchaseData = singlePurchaseDataFromJson(jsonString);

import 'dart:convert';

SinglePurchaseData singlePurchaseDataFromJson(String str) => SinglePurchaseData.fromJson(json.decode(str));

String singlePurchaseDataToJson(SinglePurchaseData data) => json.encode(data.toJson());

class SinglePurchaseData {
  SinglePurchaseData({
     this.data,
  });

  Data? data;

  factory SinglePurchaseData.fromJson(Map<String, dynamic> json) => SinglePurchaseData(
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "data": data!.toJson(),
  };
}

class Data {
  Data({
    required this.id,
    required this.supplierId,
    this.bankId,
    required this.referenceNo,
    required this.totalAmount,
    required this.shippingCharge,
    required this.discountAmount,
    required this.paidAmount,
    required this.status,
    required this.date,
    required this.paymentType,
    this.details,
    required this.supplier,
     this.bank,
    required this.items
  });

  int id;
  int supplierId;
  dynamic bankId;
  String referenceNo;
  String totalAmount;
  String shippingCharge;
  String discountAmount;
  String paidAmount;
  int status;
  DateTime date;
  String paymentType;
  dynamic details;
  Bank supplier;
  Bank? bank;
  Items items;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    supplierId: json["supplier_id"],
    bankId: json["bank_id"],
    referenceNo: json["reference_no"],
    totalAmount: json["total_amount"],
    shippingCharge: json["shipping_charge"],
    discountAmount: json["discount_amount"],
    paidAmount: json["paid_amount"],
    status: json["status"],
    date: DateTime.parse(json["date"]),
    paymentType: json["payment_type"],
    details: json["details"],
    supplier: Bank.fromJson(json["supplier"]),
    bank: Bank.fromJson(json["bank"]),
    items: Items.fromJson(json["items"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "supplier_id": supplierId,
    "bank_id": bankId,
    "reference_no": referenceNo,
    "total_amount": totalAmount,
    "shipping_charge": shippingCharge,
    "discount_amount": discountAmount,
    "paid_amount": paidAmount,
    "status": status,
    "date": "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
    "payment_type": paymentType,
    "details": details,
    "supplier": supplier.toJson(),
    if(bank != null)"bank": bank?.toJson(),
  };
}

class Bank {
  Bank({
    this.id,
    this.name,
  });

  int? id;
  String? name;

  factory Bank.fromJson(Map<String, dynamic> json) => Bank(
    id: json["id"],
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
  };
}


class Items {
  Items({
    required this.data,
  });
  late final List<IngredientData> data;

  Items.fromJson(Map<String, dynamic> json){
    data = List.from(json['data']).map((e)=>IngredientData.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['data'] = data.map((e)=>e.toJson()).toList();
    return _data;
  }
}

class IngredientData {
  IngredientData({
    required this.ingredient,
    required this.unitPrice,
    required this.quantityAmount,
    required this.total,
    required this.id,
    required this.expireDate,
  });
  late final Ingredient ingredient;
  late final String unitPrice;
  late final int id;
  late final String quantityAmount;
  late final String total;
  late final String expireDate;

  IngredientData.fromJson(Map<String, dynamic> json){
    ingredient = Ingredient.fromJson(json['ingredient']);
    unitPrice = json['unit_price'];
    quantityAmount = json['quantity_amount'];
    total = json['total'];
    expireDate = json['expire_date'];
    id  = json['id'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['ingredient'] = ingredient.toJson();
    _data['unit_price'] = unitPrice;
    _data['quantity_amount'] = quantityAmount;
    _data['total'] = total;
    _data['expire_date'] = expireDate;
    _data['id'] = id;
    return _data;
  }
}

class Ingredient {
  Ingredient({
    required this.id,
    required this.name,
  });
  late final int id;
  late final String name;

  Ingredient.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    return _data;
  }
}

