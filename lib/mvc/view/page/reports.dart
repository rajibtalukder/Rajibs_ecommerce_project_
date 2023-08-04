import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:klio_staff/mvc/controller/report_management_controller.dart';
import 'package:klio_staff/mvc/model/sale_report_list_model.dart' as SaleReport;
import 'package:klio_staff/mvc/model/stock_report_list_model.dart'
    as StockReport;
import 'package:klio_staff/mvc/model/waste_report_list_model.dart'
    as WasteReport;
import 'package:material_segmented_control/material_segmented_control.dart';
import '../../../constant/color.dart';
import '../../../constant/value.dart';

class Reports extends StatefulWidget {
  const Reports({Key? key}) : super(key: key);

  @override
  State<Reports> createState() => _ReportsState();
}

class _ReportsState extends State<Reports> with SingleTickerProviderStateMixin {
  ReportManagementController _reportController =
      Get.put(ReportManagementController());

  int _currentSelection = 0;
  late TabController controller;
  int dropdownvalue = 1;
  TextEditingController textController = TextEditingController();

  late ScrollController scrollController;

  @override
  void initState() {
    // TODO: implement initState
    controller = TabController(length: 4, vsync: this);

    controller.addListener(() {
      _currentSelection = controller.index;
      _reportController.update(['changeCustomTabBar']);

      if (_currentSelection == 0) {
        textController.text = '';
        _reportController.getSaleReportByKeyword();
      } else if (_currentSelection == 1) {
        textController.text = '';
        _reportController.getStockReportByKeyword();
      } else if (_currentSelection == 3) {
        textController.text = '';
        _reportController.getWasteReportByKeyword();
      } else {}
    });

    scrollController = ScrollController();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.95) {
        if (_currentSelection == 0 && !_reportController.isLoadingAllSale) {
          _reportController.getSaleReportDataList();
          print('===================');
        } else if (_currentSelection == 1 &&
            !_reportController.isLoadingStockReport) {
          _reportController.getStockReportDataList();
        } else if (_currentSelection == 2) {
          _reportController.getProfitLossReportList();
        } else if (_currentSelection == 3 &&
            !_reportController.isLoadingWasteReport) {
          _reportController.getWasteReportDataList();
        }
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          height: double.infinity,
          width: double.infinity,
          child: Column(
            children: [
              itemTitleHeader(),
              customTapbarHeader(controller),
              Expanded(
                  child: TabBarView(controller: controller, children: [
                saleReportDataTable(context),
                stockReportDataTable(context),
                profitLossReportDataTable(context),
                wasteReportDataTable(context),
              ]))
            ],
          )),
    );
  }

  itemTitleHeader() {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 20),
      child: Text(
        'Reports',
        style: TextStyle(fontSize: fontBig, color: primaryText),
      ),
    );
  }

  customTapbarHeader(TabController controller) {
    Timer? stopOnSearch;
    return Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            GetBuilder<ReportManagementController>(
                id: 'changeCustomTabBar',
                builder: (context) {
                  return Expanded(
                      flex: 1,
                      child: MaterialSegmentedControl(
                          children: {
                            0: Text(
                              'Sale Report',
                              style: TextStyle(
                                  color: _currentSelection == 0
                                      ? white
                                      : Colors.black),
                            ),
                            1: Text(
                              'Stock Report',
                              style: TextStyle(
                                  color: _currentSelection == 1
                                      ? white
                                      : Colors.black),
                            ),
                            2: Text(
                              'Profit Loss Report',
                              style: TextStyle(
                                  color: _currentSelection == 2
                                      ? white
                                      : Colors.black),
                            ),
                            3: Text(
                              'Waste Report',
                              style: TextStyle(
                                  color: _currentSelection == 3
                                      ? white
                                      : Colors.black),
                            ),
                          },
                          selectionIndex: _currentSelection,
                          borderColor: Colors.grey,
                          selectedColor: primaryColor,
                          unselectedColor: Colors.white,
                          borderRadius: 32.0,
                          onSegmentTapped: (index) {
                            // if (index == 0 &&
                            //     _reportController
                            //         .saleRepData.value.data!.isEmpty) {
                            //   _reportController.getSaleReportDataList();
                            // } else if (index == 1 &&
                            //     _reportController
                            //         .stockRepData.value.data!.isEmpty) {
                            //   _reportController.getStockReportDataList();
                            // } else if (index == 2) {
                            //   _reportController.getProfitLossReportList();
                            // } else if (index == 3 &&
                            //     _reportController
                            //         .wasteRepData.value.data!.isEmpty) {
                            //   _reportController.getWasteReportDataList();
                            // }
                            print(index);
                            setState(() {
                              _currentSelection = index;
                              controller.index = _currentSelection;
                            });
                          }));
                }),
            Container(
                margin: const EdgeInsets.only(left: 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _currentSelection == 2
                        ? const Card(
                            color: Colors.transparent,
                            elevation: 0.0,
                            child: SizedBox(width: 300, height: 38))
                        : Card(
                            elevation: 0.0,
                            child: SizedBox(
                                width: 300,
                                height: 40,
                                child: TextField(
                                    onChanged: (text) async {
                                      if (_currentSelection == 0) {
                                        _reportController.searchText = text;
                                        const duration = Duration(seconds: 1);
                                        if (stopOnSearch != null) {
                                          stopOnSearch?.cancel();
                                        }
                                        stopOnSearch = Timer(
                                            duration,
                                            () => _reportController
                                                .getSaleReportByKeyword(
                                                    keyword: text));
                                      } else if (_currentSelection == 1) {
                                        const duration = Duration(seconds: 2);
                                        if (stopOnSearch != null) {
                                          stopOnSearch?.cancel();
                                        }
                                        stopOnSearch = Timer(
                                            duration,
                                            () => _reportController
                                                .getStockReportByKeyword(
                                                    keyword: text));
                                      } else if (_currentSelection == 3) {
                                        const duration = Duration(seconds: 2);
                                        if (stopOnSearch != null) {
                                          stopOnSearch?.cancel();
                                        }
                                        stopOnSearch = Timer(
                                            duration,
                                            () => _reportController
                                                .getWasteReportByKeyword(
                                                    keyword: text));
                                      } else {}
                                    },
                                    controller: textController,
                                    style: const TextStyle(
                                      fontSize: fontSmall,
                                      color: black,
                                    ),
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.white10,
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          10, 3, 10, 0),
                                      prefixIcon: const Icon(
                                        Icons.search,
                                        size: 20,
                                      ),
                                      suffixIcon: IconButton(
                                          onPressed: () {
                                            _reportController.searchText = '';
                                            if (_currentSelection == 0) {
                                              setState(() {
                                                textController.text = '';
                                                _reportController
                                                    .getSaleReportByKeyword();
                                              });
                                            } else if (_currentSelection == 1) {
                                              setState(() {
                                                textController.text = '';
                                                _reportController
                                                    .getStockReportByKeyword();
                                              });
                                            } else if (_currentSelection == 3) {
                                              setState(() {
                                                textController.text = '';
                                                _reportController
                                                    .getWasteReportByKeyword();
                                              });
                                            } else {}
                                          },
                                          icon: Icon(
                                            Icons.close,
                                            color: textSecondary,
                                          )),
                                      hintText: "Search Item",
                                      hintStyle: const TextStyle(
                                          fontSize: fontSmall, color: black),
                                      border: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1,
                                              color: Colors.transparent)),
                                      disabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1,
                                              color: Colors.transparent)),
                                      enabledBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1,
                                              color: Colors.transparent)),
                                      errorBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1,
                                              color: Colors.transparent)),
                                      focusedBorder: const OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: 1,
                                              color: Colors.transparent)),
                                      focusedErrorBorder:
                                          const OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  width: 1,
                                                  color: Colors.transparent)),
                                    ))),
                          ),
                  ],
                ))
          ],
        ));
  }

  saleReportDataTable(BuildContext context) {
    return Card(
      color: secondaryBackground,
      child: SingleChildScrollView(
        controller: scrollController,
        child: GetBuilder<ReportManagementController>(
            id: "saleId",
            builder: (controller) {
              if (controller.saleRepData.value.data!.isEmpty &&
                  controller.haveMoreAllSale) {
                return Center(
                    child: Container(
                        height: 40,
                        width: 40,
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.3),
                        child: const CircularProgressIndicator()));
              }
              if (controller.saleRepData.value.data!.isEmpty &&
                  !controller.haveMoreAllSale) {
                controller.saleRepData.value.data!.add(SaleReport.Datum(id: 0));
              }
              if (!controller.haveMoreAllSale &&
                  controller.saleRepData.value.data!.last.id != 0) {
                controller.saleRepData.value.data!.add(SaleReport.Datum(id: 0));
              }
              return DataTable(
                  dataRowHeight: 70,
                  columns: [
                    // column to set the name
                    DataColumn(
                      label: Text(
                        'SL NO',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Invoice',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Customer Name',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Type',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Grand Total',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Date',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                  ],
                  rows: controller.saleRepData.value.data!.map(
                    (item) {
                      if (item.id == 0 && !controller.haveMoreAllSale) {
                        return DataRow(cells: [
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(Text('No Data',
                              style: TextStyle(color: primaryText))),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                        ]);
                      } else if (item ==
                              _reportController.saleRepData.value.data!.last &&
                          !controller.isLoadingAllSale &&
                          controller.haveMoreAllSale) {
                        return const DataRow(cells: [
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator()),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                        ]);
                      }
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '${item.id ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.invoice ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.customerName ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.type ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.grandTotal ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.date ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList());
            }),
      ),
    );
  }

  stockReportDataTable(BuildContext context) {
    return Card(
      color: secondaryBackground,
      child: SingleChildScrollView(
        controller: scrollController,
        child: GetBuilder<ReportManagementController>(
            id: 'stockId',
            builder: (controller) {
              if (controller.stockRepData.value.data!.isEmpty &&
                  !controller.haveMoreStockReport) {
                controller.stockRepData.value.data!
                    .add(StockReport.Datum(id: 0));
              }
              if (!controller.haveMoreStockReport &&
                  controller.stockRepData.value.data!.last.id != 0) {
                controller.stockRepData.value.data!
                    .add(StockReport.Datum(id: 0));
              }
              return DataTable(
                  dataRowHeight: 70,
                  columns: [
                    // column to set the name
                    DataColumn(
                      label: Text(
                        'SL NO',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Quantity Amount',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Ingredient Name',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Ingredient Code',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Alert Quantity',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Category Name',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Unit name',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                  ],
                  rows: controller.stockRepData.value.data!.map(
                    (item) {
                      if (item.id == 0 && !controller.haveMoreStockReport) {
                        return DataRow(cells: [
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(Text('No Data',
                              style: TextStyle(color: primaryText))),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                        ]);
                      } else if (item ==
                              controller.stockRepData.value.data!.last &&
                          !controller.isLoadingStockReport &&
                          controller.haveMoreStockReport) {
                        return const DataRow(cells: [
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator()),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                        ]);
                      }
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '${item.id ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.qtyAmount ?? "",
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.ingredient?.name ?? "",
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.ingredient?.code ?? "",
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.ingredient?.alertQty ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.ingredient?.category.name ?? "",
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.ingredient?.unit?.name ?? "",
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList());
            }),
      ),
    );
  }

  profitLossReportDataTable(BuildContext context) {
    return Card(
        color: secondaryBackground,
        child: SingleChildScrollView(
          child: GetBuilder<ReportManagementController>(
            builder: (controller) => DataTable(
              dataRowHeight: 70,
              columns: [
                DataColumn(
                    label: Text('Loss Item',
                        style: TextStyle(color: textSecondary))),
                DataColumn(
                    label:
                        Text('Amount', style: TextStyle(color: textSecondary))),
              ],
              rows: [
                DataRow(cells: [
                  DataCell(Text("Total Purchase Shipping Charge : ",
                      style: TextStyle(color: primaryText))),
                  DataCell(Text(
                      controller.profitLossData.value.grossProfit!
                          .toStringAsFixed(2),
                      style: TextStyle(color: primaryText))),
                ]),
                DataRow(cells: [
                  DataCell(Text("Total Purchase Discount : ",
                      style: TextStyle(color: primaryText))),
                  DataCell(Text(
                      controller.profitLossData.value.totalPurchaseDiscount
                          .toString(),
                      style: TextStyle(color: primaryText))),
                ]),
                DataRow(cells: [
                  DataCell(Text("Total Purchase : ",
                      style: TextStyle(color: primaryText))),
                  DataCell(Text(
                      controller.profitLossData.value.totalPurchase.toString(),
                      style: TextStyle(color: primaryText))),
                ]),
                DataRow(cells: [
                  DataCell(Text("Total Sell Discount : ",
                      style: TextStyle(color: primaryText))),
                  DataCell(Text(
                      controller.profitLossData.value.totalSellDiscount
                          .toString(),
                      style: TextStyle(color: primaryText))),
                ]),
                DataRow(cells: [
                  DataCell(Text("Total Customer Reward : ",
                      style: TextStyle(color: primaryText))),
                  DataCell(Text(
                      controller.profitLossData.value.totalCustomerReward
                          .toString(),
                      style: TextStyle(color: primaryText))),
                ]),
                DataRow(cells: [
                  DataCell(Text("Total Expense : ",
                      style: TextStyle(color: primaryText))),
                  DataCell(Text(
                      controller.profitLossData.value.totalExpense.toString(),
                      style: TextStyle(color: primaryText))),
                ]),
                DataRow(cells: [
                  DataCell(Text("Total Waste : ",
                      style: TextStyle(color: primaryText))),
                  DataCell(Text(
                      controller.profitLossData.value.totalWaste.toString(),
                      style: TextStyle(color: primaryText))),
                ]),
                DataRow(cells: [
                  DataCell(Text("Total Sell Shipping Charge : ",
                      style: TextStyle(color: primaryText))),
                  DataCell(Text(
                      controller.profitLossData.value.totalSellShippingCharge
                          .toString(),
                      style: TextStyle(color: primaryText))),
                ]),
                DataRow(cells: [
                  DataCell(Text("Total Sell Service Charge : ",
                      style: TextStyle(color: primaryText))),
                  DataCell(Text(
                      controller.profitLossData.value.totalSellServiceCharge
                          .toString(),
                      style: TextStyle(color: primaryText))),
                ]),
                DataRow(cells: [
                  DataCell(Text("Total Sales : ",
                      style: TextStyle(color: primaryText))),
                  DataCell(Text(
                      controller.profitLossData.value.totalSales.toString(),
                      style: TextStyle(color: primaryText))),
                ]),
                DataRow(cells: [
                  DataCell(Text("Total Sell Vat : ",
                      style: TextStyle(color: primaryText))),
                  DataCell(Text(
                      controller.profitLossData.value.totalSellVat!
                          .toStringAsFixed(2),
                      style: TextStyle(color: primaryText))),
                ]),
                DataRow(cells: [
                  DataCell(Text("Gross Profit : ",
                      style: TextStyle(color: primaryText))),
                  DataCell(Text(
                      controller.profitLossData.value.grossProfit!
                          .toStringAsFixed(2),
                      style: TextStyle(color: primaryText))),
                ]),
                DataRow(cells: [
                  DataCell(Text("Net Profit : ",
                      style: TextStyle(color: primaryText))),
                  DataCell(Text(
                      controller.profitLossData.value.netProfit!
                          .toStringAsFixed(2),
                      style: TextStyle(color: primaryText))),
                ]),
              ],
            ),
          ),
        ));
  }

  wasteReportDataTable(BuildContext context) {
    return Card(
      color: secondaryBackground,
      child: SingleChildScrollView(
        controller: scrollController,
        child: GetBuilder<ReportManagementController>(
            id: 'wasteId',
            builder: (controller) {
              if (controller.wasteRepData.value.data!.isEmpty &&
                  !controller.haveMoreWasteReport) {
                controller.wasteRepData.value.data!
                    .add(WasteReport.Datum(id: 0));
              }
              if (!controller.haveMoreWasteReport &&
                  controller.wasteRepData.value.data!.last.id != 0) {
                controller.wasteRepData.value.data!
                    .add(WasteReport.Datum(id: 0));
              }
              return DataTable(
                  dataRowHeight: 70,
                  columns: [
                    // column to set the name
                    DataColumn(
                      label: Text(
                        'SL NO',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Name',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Ref No',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Date',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Note',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Added By',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Total Loss',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                  ],
                  rows: controller.wasteRepData.value.data!.map(
                    (item) {
                      if (item.id == 0 && !controller.haveMoreWasteReport) {
                        return DataRow(cells: [
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(Text('No Data',
                              style: TextStyle(color: primaryText))),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                        ]);
                      } else if (item ==
                              controller.wasteRepData.value.data!.last &&
                          !controller.isLoadingWasteReport &&
                          controller.haveMoreWasteReport) {
                        return const DataRow(cells: [
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator()),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                        ]);
                      }

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '${item.id ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.personName ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.referenceNo ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.date ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 300,
                              child: Text(
                                '${item.note ?? ""}',
                                style: TextStyle(color: primaryText),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.addedBy ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.totalLoss ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList());
            }),
      ),
    );
  }
}
