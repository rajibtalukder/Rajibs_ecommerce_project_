// To parse this JSON data, do
//
//     final profitLossReportModel = profitLossReportModelFromJson(jsonString);

import 'dart:convert';

ProfitLossReportModel profitLossReportModelFromJson(String str) => ProfitLossReportModel.fromJson(json.decode(str));

String profitLossReportModelToJson(ProfitLossReportModel data) => json.encode(data.toJson());

class ProfitLossReportModel {
  String? totalPurchaseShippingCharge;
  String? totalPurchaseDiscount;
  int? totalPurchase;
  String? totalSellDiscount;
  int? totalCustomerReward;
  String? totalExpense;
  int? totalWaste;
  int? totalStockAdjustments;
  String? totalSellShippingCharge;
  String? totalSellServiceCharge;
  String? totalSales;
  double? totalSellVat;
  double? grossProfit;
  double? netProfit;

  ProfitLossReportModel({
     this.totalPurchaseShippingCharge,
     this.totalPurchaseDiscount,
     this.totalPurchase,
     this.totalSellDiscount,
     this.totalCustomerReward,
     this.totalExpense,
     this.totalWaste,
     this.totalStockAdjustments,
     this.totalSellShippingCharge,
     this.totalSellServiceCharge,
     this.totalSales,
     this.totalSellVat,
     this.grossProfit,
     this.netProfit,
  });

  factory ProfitLossReportModel.fromJson(Map<String, dynamic> json) => ProfitLossReportModel(
    totalPurchaseShippingCharge: json["total_purchase_shipping_charge"],
    totalPurchaseDiscount: json["total_purchase_discount"],
    totalPurchase: json["total_purchase"],
    totalSellDiscount: json["total_sell_discount"],
    totalCustomerReward: json["total_customer_reward"],
    totalExpense: json["total_expense"],
    totalWaste: json["total_waste"],
    totalStockAdjustments: json["total_stock_adjustments"],
    totalSellShippingCharge: json["total_sell_shipping_charge"],
    totalSellServiceCharge: json["total_sell_service_charge"],
    totalSales: json["total_sales"],
    totalSellVat: json["total_sell_vat"]?.toDouble(),
    grossProfit: json["gross_profit"]?.toDouble(),
    netProfit: json["net_profit"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "total_purchase_shipping_charge": totalPurchaseShippingCharge,
    "total_purchase_discount": totalPurchaseDiscount,
    "total_purchase": totalPurchase,
    "total_sell_discount": totalSellDiscount,
    "total_customer_reward": totalCustomerReward,
    "total_expense": totalExpense,
    "total_waste": totalWaste,
    "total_stock_adjustments": totalStockAdjustments,
    "total_sell_shipping_charge": totalSellShippingCharge,
    "total_sell_service_charge": totalSellServiceCharge,
    "total_sales": totalSales,
    "total_sell_vat": totalSellVat,
    "gross_profit": grossProfit,
    "net_profit": netProfit,
  };
}
