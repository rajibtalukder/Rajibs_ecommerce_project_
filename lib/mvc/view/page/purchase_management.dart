import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:klio_staff/constant/color.dart';
import 'package:klio_staff/constant/value.dart';
import 'package:klio_staff/mvc/controller/food_management_controller.dart';
import 'package:klio_staff/mvc/controller/purchase_management_controller.dart';
import 'package:klio_staff/mvc/model/purchase_list_model.dart';
import 'package:klio_staff/mvc/model/expense_list_model.dart' as Expense;
import 'package:klio_staff/mvc/model/expense_category_model.dart'
    as ExpCategory;

import 'package:klio_staff/mvc/view/dialog/custom_dialog.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

import '../../../utils/utils.dart';
import '../../model/add_menu_model.dart';
import '../../model/single_purchase_data.dart';
import '../widget/custom_widget.dart';

class PurchaseManagement extends StatefulWidget {
  const PurchaseManagement({Key? key}) : super(key: key);

  @override
  State<PurchaseManagement> createState() => _PurchaseManagementState();
}

class _PurchaseManagementState extends State<PurchaseManagement>
    with SingleTickerProviderStateMixin {
  PurchaseManagementController purchaseCtrl =
      Get.put(PurchaseManagementController());

  FoodManagementController foodManagementController = Get.find();

  int _currentSelection = 0;
  late TabController controller;
  late ScrollController scrollController;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    scrollController = ScrollController();
    controller = TabController(vsync: this, length: 3);

    controller.addListener(() {
      _currentSelection = controller.index;
      purchaseCtrl.update(['changeCustomTabBar']);

      if (_currentSelection == 0) {
        textController.text = '';
        purchaseCtrl.getPurchaseByKeyword(showLoading: false);
      } else if (_currentSelection == 1) {
        textController.text = '';
        purchaseCtrl.getExpenseByKeyword(showLoading: false);
      } else if (_currentSelection == 2) {
        textController.text = '';
        purchaseCtrl.getExpenseCategoryByKeyword(showLoading: false);
      } else {}
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.95) {
        if (_currentSelection == 0 && !purchaseCtrl.isLoadingPurchase) {
          purchaseCtrl.getPurchaseDataList();
        } else if (_currentSelection == 1 && !purchaseCtrl.isLoadingExpence) {
          purchaseCtrl.getExpenseDataList();
        } else if (_currentSelection == 2 &&
            !purchaseCtrl.isLoadingExpenceCategory) {
          purchaseCtrl.getExpenseCategoryList();
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
          GetBuilder<PurchaseManagementController>(
              id: "changeCustomTabBar",
              builder: (controller) => itemTitleHeader()),
          customTapbarHeader(controller),
          Expanded(
            child: TabBarView(controller: controller, children: [
              purchaseDataTable(context),
              expenseDataTable(context),
              expenseCategoryDataTable(context),
            ]),
          )
        ],
      ),
    ));
  }

  itemTitleHeader() {
    return Builder(builder: (context) {
      if (_currentSelection == 0) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  'Purchase List',
                  style: TextStyle(fontSize: fontBig, color: primaryText),
                ),
              ),
              OutlinedButton.icon(
                icon: Icon(
                  Icons.add,
                  color: primaryText,
                ),
                label: Text(
                  "Add New Purchase",
                  style: TextStyle(
                    color: primaryText,
                  ),
                ),
                onPressed: () {
                  showCustomDialog(context, "Add New Purchase",
                      addNewPurchase(context, false), 100, 300);
                },
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(width: 1.0, color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              )
            ],
          ),
        );
      } else if (_currentSelection == 1) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  'Expense List',
                  style: TextStyle(fontSize: fontBig, color: primaryText),
                ),
              ),
              Container(
                child: OutlinedButton.icon(
                  icon: Icon(
                    Icons.add,
                    color: primaryText,
                  ),
                  label: Text(
                    "Add New Expense",
                    style: TextStyle(
                      color: primaryText,
                    ),
                  ),
                  onPressed: () {
                    showCustomDialog(context, "Add New Expence",
                        addNewExpence(context), 100, 300);
                  },
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(width: 1.0, color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      } else if (_currentSelection == 2) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  'Expense Category List',
                  style: TextStyle(fontSize: fontBig, color: primaryText),
                ),
              ),
              Container(
                child: OutlinedButton.icon(
                  icon: Icon(
                    Icons.add,
                    color: primaryText,
                  ),
                  label: Text(
                    "Add Expense Category",
                    style: TextStyle(
                      color: primaryText,
                    ),
                  ),
                  onPressed: () {
                    showCustomDialog(context, "Add New Expense Category",
                        addNewExpenseCategory(), 100, 400);
                  },
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(width: 1.0, color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }
      return Container();
    });
  }

  Widget customTapbarHeader(TabController controller) {
    Timer? stopOnSearch;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          GetBuilder<PurchaseManagementController>(
              id: 'changeCustomTabBar',
              builder: (context) {
                return Expanded(
                  flex: 1,
                  child: MaterialSegmentedControl(
                    children: {
                      0: Text(
                        'Purchase List',
                        style: TextStyle(
                            color: _currentSelection == 0 ? white : black),
                      ),
                      1: Text(
                        'Expense',
                        style: TextStyle(
                            color: _currentSelection == 1 ? white : black),
                      ),
                      2: Text(
                        'Expense Category',
                        style: TextStyle(
                            color: _currentSelection == 2 ? white : black),
                      ),
                    },
                    selectionIndex: _currentSelection,
                    borderColor: Colors.grey,
                    selectedColor: primaryColor,
                    unselectedColor: Colors.white,
                    borderRadius: 32.0,
                    disabledChildren: [
                      6,
                    ],
                    onSegmentChosen: (index) {
                      // if (index == 0 &&
                      //     purchaseCtrl.purchaseData.value.data.isEmpty) {
                      //   purchaseCtrl.getPurchaseDataList();
                      // } else if (index == 1 &&
                      //     purchaseCtrl.expenseData.value.data.isEmpty) {
                      //   purchaseCtrl.getExpenseDataList();
                      // } else if (index == 2 &&
                      //     purchaseCtrl.expenseCategoryData.value.data.isEmpty) {
                      //   purchaseCtrl.getExpenseCategoryList();
                      // }
                      print(index);
                      setState(() {
                        _currentSelection = index;
                        controller.index = _currentSelection;
                      });
                    },
                  ),
                );
              }),
          Container(
            margin: const EdgeInsets.only(left: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Card(
                  elevation: 0.0,
                  child: SizedBox(
                      width: 300,
                      height: 40,
                      child: TextField(
                          onChanged: (text) async {
                            if (_currentSelection == 0) {
                              purchaseCtrl.searchText = text;
                              const duration = Duration(seconds: 2);
                              if (stopOnSearch != null) {
                                stopOnSearch?.cancel();
                              }
                              stopOnSearch = Timer(
                                  duration,
                                  () => purchaseCtrl.getPurchaseByKeyword(
                                      keyword: text, showLoading: false));
                            } else if (_currentSelection == 1) {
                              purchaseCtrl.searchText = text;
                              const duration = Duration(seconds: 2);
                              if (stopOnSearch != null) {
                                stopOnSearch?.cancel();
                              }
                              stopOnSearch = Timer(
                                  duration,
                                  () => purchaseCtrl.getExpenseByKeyword(
                                      keyword: text, showLoading: false));
                            } else if (_currentSelection == 2) {
                              purchaseCtrl.searchText = text;
                              const duration = Duration(seconds: 2);
                              if (stopOnSearch != null) {
                                stopOnSearch?.cancel();
                              }
                              stopOnSearch = Timer(
                                  duration,
                                  () =>
                                      purchaseCtrl.getExpenseCategoryByKeyword(
                                          keyword: text, showLoading: false));
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
                            contentPadding:
                                const EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 0.0),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                                onPressed: () {
                                  if (_currentSelection == 0) {
                                    purchaseCtrl.searchText = '';
                                    setState(() {
                                      textController.text = '';
                                      purchaseCtrl.getPurchaseByKeyword();
                                    });
                                  } else if (_currentSelection == 1) {
                                    purchaseCtrl.searchText = '';
                                    setState(() {
                                      textController.text = '';
                                      purchaseCtrl.getExpenseByKeyword();
                                    });
                                  } else if (_currentSelection == 2) {
                                    purchaseCtrl.searchText = '';
                                    setState(() {
                                      textController.text = '';
                                      purchaseCtrl
                                          .getExpenseCategoryByKeyword();
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
                                    width: 1, color: Colors.transparent)),
                            disabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            focusedErrorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                          ))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget purchaseDataTable(BuildContext context) {
    return Card(
      color: secondaryBackground,
      child: SingleChildScrollView(
        controller: scrollController,
        child: GetBuilder<PurchaseManagementController>(
            id: 'purchaseId',
            builder: (controller) {
              print(
                  "***************************************************2222222222222222");
              // if (controller.purchaseData.value.data.isEmpty) {
              //   return Center(
              //       child: Container(
              //           height: 40,
              //           width: 40,
              //           margin: EdgeInsets.only(
              //               top: MediaQuery.of(context).size.height * 0.3),
              //           child: CircularProgressIndicator()));
              // }
              if (!controller.haveMorePurchase &&
                  controller.purchaseData.value.data.isNotEmpty &&
                  controller.purchaseData.value.data.last.id != 0) {
                controller.purchaseData.value.data.add(Datum(id: 0));
              } else if (controller.purchaseData.value.data.isEmpty &&
                  !controller.haveMorePurchase) {
                controller.purchaseData.value.data.add(Datum(id: 0));
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
                        'Reference No',
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
                        'Supplier',
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
                        'Paid Amount',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Action',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                  ],
                  rows: controller.purchaseData.value.data.map(
                    (item) {
                      if (item.id == 0 && !controller.haveMorePurchase) {
                        return DataRow(cells: [
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(Text('Data not found',
                              style: TextStyle(color: primaryText))),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                        ]);
                      } else if (item ==
                              controller.purchaseData.value.data.last &&
                          !controller.isLoadingPurchase &&
                          controller.haveMorePurchase) {
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
                            Text(
                              item.supplier?.name ?? "",
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.totalAmount ?? "",
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.paidAmount ?? "",
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffE1FDE8),
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      purchaseCtrl
                                          .getSinglePurchaseData(id: item.id)
                                          .then((value) {
                                        showCustomDialog(
                                            context,
                                            "Purchase Details",
                                            viewPurchaseData(),
                                            120,
                                            250);
                                      });
                                    },
                                    child: Image.asset(
                                      "assets/hide.png",
                                      height: 15,
                                      width: 15,
                                      color: const Color(0xff00A600),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () async {
                                    Utils.showLoading();
                                    await purchaseCtrl.getSinglePurchaseData(
                                        id: item.id);

                                    Data? data = purchaseCtrl
                                        .singlePurchaseData.value.data;
                                    if (data == null) {
                                      Utils.hidePopup();
                                      Utils.showSnackBar("Can not get Data");
                                      return;
                                    }

                                    try {
                                      purchaseCtrl.clearPurchase();
                                      purchaseCtrl.supplierId =
                                          data.supplierId.toString();
                                      purchaseCtrl.dateCtlr.value =
                                          DateFormat('yyyy-MM-dd')
                                              .format(data.date);
                                      purchaseCtrl.paymentType =
                                          data.paymentType;
                                      purchaseCtrl.bankId = data.bankId ?? "";
                                      purchaseCtrl.purchaseTotal =
                                          double.parse(data.totalAmount);

                                      //purchaseCtrl.ingredients.clear();
                                      purchaseCtrl.purchaseDetailController
                                          .text = data.details;
                                      purchaseCtrl
                                          .purchaseShippingChargeController
                                          .text = data.shippingCharge;
                                      purchaseCtrl.purchaseDiscountController
                                          .text = data.discountAmount;
                                      purchaseCtrl.purchasePaidController.text =
                                          data.paidAmount;
                                      Utils.hidePopup();

                                      for (var e in data.items.data) {
                                        var temp = foodManagementController
                                            .addMenuModel.ingredients
                                            .firstWhere((element) =>
                                                element.id == e.ingredient.id);
                                        temp.expireDate = e.expireDate;
                                        temp.price = e.unitPrice;
                                        temp.quantity =
                                            double.parse(e.quantityAmount)
                                                .toInt();
                                        purchaseCtrl.ingredients.add(temp);
                                      }
                                    } catch (e) {
                                      Utils.hidePopup();
                                      Utils.showSnackBar(
                                          "This Item do not have all the required fields");
                                      return;
                                    }
                                    showCustomDialog(
                                      context,
                                      "Update Purchase",
                                      addNewPurchase(context, true,
                                          id: item.id ?? -1),
                                      100,
                                      300,
                                    ).then((value) =>
                                        purchaseCtrl.clearPurchase());
                                  },
                                  child: Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffFEF4E1),
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    child: Image.asset(
                                      "assets/edit-alt.png",
                                      height: 15,
                                      width: 15,
                                      color: const Color(0xffED7402),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    showWarningDialog("Are you sure to delete?",
                                        onAccept: () {
                                      purchaseCtrl.deletePurchase(id: item.id);
                                      Get.back();
                                      Get.back();
                                    });
                                  },
                                  child: Container(
                                    height: 35,
                                    width: 35,
                                    decoration: BoxDecoration(
                                      color: const Color(0xffFFE7E6),
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    child: Image.asset(
                                      "assets/delete.png",
                                      height: 15,
                                      width: 15,
                                      color: const Color(0xffED0206),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ).toList());
            }),
      ),
    );
  }

  Widget expenseDataTable(BuildContext context) {
    return Card(
      color: secondaryBackground,
      child: SingleChildScrollView(
        controller: scrollController,
        child: GetBuilder<PurchaseManagementController>(
            id: 'expenceId',
            builder: (controller) {
              if (!controller.haveMoreExpence &&
                  controller.expenseData.value.data.isNotEmpty &&
                  controller.expenseData.value.data.last.id != 0) {
                controller.expenseData.value.data.add(Expense.Datum(id: 0));
              } else if (controller.expenseData.value.data.isEmpty &&
                  !controller.haveMoreExpence) {
                controller.expenseData.value.data.add(Expense.Datum(id: 0));
              }
              return DataTable(
                  // dataRowHeight: 70,
                  columnSpacing: 50,
                  columns: [
                    // column to set the name
                    DataColumn(
                      label: Container(
                        width: 50,
                        child: Text(
                          'SL NO',
                          style: TextStyle(color: textSecondary),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Category',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Responsible',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Amount',
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
                        'Status',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Action',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                  ],
                  rows: controller.expenseData.value.data.map(
                    (item) {
                      if (item.id == 0 && !controller.haveMoreExpence) {
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
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                        ]);
                      } else if (item ==
                              controller.expenseData.value.data.last &&
                          !controller.isLoadingExpence &&
                          controller.haveMoreExpence) {
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
                              item.category?.name ?? "",
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.person?.name ?? "",
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.amount ?? "",
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
                            Text(
                              item.note ?? "",
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.status ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Row(
                              // mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffE1FDE8),
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      purchaseCtrl
                                          .getSingleExpenseData(id: item.id)
                                          .then((value) {
                                        showCustomDialog(
                                            context,
                                            "Show Expense Details",
                                            viewExpenseDetails(),
                                            100,
                                            400);
                                      });
                                    },
                                    child: Image.asset(
                                      "assets/hide.png",
                                      height: 15,
                                      width: 15,
                                      color: const Color(0xff00A600),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffFEF4E1),
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      purchaseCtrl
                                          .getSingleExpenseData(id: item.id)
                                          .then((value) {
                                        purchaseCtrl.updateExpenceResPersonList
                                            .add(purchaseCtrl.singleExpenseData
                                                .value.data!.person.id);
                                        purchaseCtrl.updateExpenceCatList.add(
                                            purchaseCtrl.singleExpenseData.value
                                                .data!.category.id);
                                        purchaseCtrl
                                                .updateExpenceAmountCtlr.text =
                                            purchaseCtrl.singleExpenseData.value
                                                .data!.amount;
                                        purchaseCtrl
                                                .updateExpenceNoteCtlr.text =
                                            purchaseCtrl.singleExpenseData.value
                                                .data!.note;
                                        purchaseCtrl.dateCtlr.value =
                                            purchaseCtrl.singleExpenseData.value
                                                .data!.date
                                                .toString();

                                        showCustomDialog(
                                            context,
                                            "Update Expence",
                                            updateExpenceForm(item.id, context),
                                            100,
                                            300);
                                      });
                                    },
                                    child: Image.asset(
                                      "assets/edit-alt.png",
                                      height: 15,
                                      width: 15,
                                      color: const Color(0xffED7402),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffFFE7E6),
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      showWarningDialog(
                                          "Do you want to delete this item?",
                                          onAccept: () {
                                        purchaseCtrl.deleteExpense(id: item.id);
                                        Get.back();
                                        Get.back();
                                      });
                                    },
                                    child: Image.asset(
                                      "assets/delete.png",
                                      height: 15,
                                      width: 15,
                                      color: const Color(0xffED0206),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    },
                  ).toList());
            }),
      ),
    );
  }

  Widget expenseCategoryDataTable(BuildContext context) {
    return Card(
      color: secondaryBackground,
      child: SingleChildScrollView(
        controller: scrollController,
        child: GetBuilder<PurchaseManagementController>(
            id: 'expCategoryId',
            builder: (controller) {
              if (!controller.haveMoreExpenceCategory &&
                  controller.expenseCategoryData.value.data.isNotEmpty &&
                  controller.expenseCategoryData.value.data.last.id != 0) {
                controller.expenseCategoryData.value.data
                    .add(ExpCategory.Datum(id: 0));
              } else if (controller.expenseCategoryData.value.data.isEmpty &&
                  !controller.haveMoreExpenceCategory) {
                controller.expenseCategoryData.value.data
                    .add(ExpCategory.Datum(id: 0));
              }
              return DataTable(
                  dataRowHeight: 70,
                  columnSpacing: 50,
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
                        'Status',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Action',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                  ],
                  rows: controller.expenseCategoryData.value.data.map(
                    (item) {
                      if (item.id == 0 && !controller.haveMoreExpenceCategory) {
                        return DataRow(cells: [
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(Text('No Data',
                              style: TextStyle(color: primaryText))),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                        ]);
                      } else if (item ==
                              controller.expenseCategoryData.value.data.last &&
                          !controller.isLoadingExpenceCategory &&
                          controller.haveMoreExpenceCategory) {
                        return const DataRow(cells: [
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator()),
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
                              '${item.name ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.status ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                color: const Color(0xffFFE7E6),
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  showWarningDialog(
                                      "Do you want to delete this item?",
                                      onAccept: () {
                                    purchaseCtrl
                                        .deleteExpenseCategory(id: item.id)
                                        .then((value) {
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      }
                                    });
                                  });
                                },
                                child: Image.asset(
                                  "assets/delete.png",
                                  height: 15,
                                  width: 15,
                                  color: const Color(0xffED0206),
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ).toList());
            }),
      ),
    );
  }

  Widget viewPurchaseData() {
    return Container(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: SingleChildScrollView(
          child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Reference No:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Text(
                        purchaseCtrl.singlePurchaseData.value.data!.referenceNo,
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Supplier Name:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Text(
                        purchaseCtrl
                            .singlePurchaseData.value.data!.supplier.name
                            .toString(),
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Date:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Text(
                        purchaseCtrl.singlePurchaseData.value.data!.date
                            .toString(),
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Payment Type:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Text(
                        purchaseCtrl.singlePurchaseData.value.data!.paymentType,
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Total Total:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Text(
                        purchaseCtrl.singlePurchaseData.value.data!.totalAmount,
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Shipping Charge:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Text(
                      purchaseCtrl
                          .singlePurchaseData.value.data!.shippingCharge,
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Discount Amount:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Text(
                        purchaseCtrl
                            .singlePurchaseData.value.data!.discountAmount,
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Grand Total:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Text(
                        purchaseCtrl.singlePurchaseData.value.data!.paidAmount,
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Paid Amount:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Text(
                        purchaseCtrl.singlePurchaseData.value.data!.paidAmount,
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Due Amount:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Text(
                        "${double.parse(purchaseCtrl.singlePurchaseData.value.data!.totalAmount) - double.parse(purchaseCtrl.singlePurchaseData.value.data!.paidAmount)}",
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Details:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Text(
                        purchaseCtrl.singlePurchaseData.value.data!.details ??
                            "",
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 3,
                  child: Container(
                    child: Text(
                      'Info Items : ',
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    ),
                  )),
              Expanded(
                  flex: 7,
                  child: DataTable(
                    dataRowHeight: 70,
                    columnSpacing: 50,
                    columns: [
                      // column to set the name
                      DataColumn(
                        label: Text(
                          'ID No',
                          style: TextStyle(color: textSecondary),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Expire Date',
                          style: TextStyle(color: textSecondary),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Ingredient',
                          style: TextStyle(color: textSecondary),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Unit Price',
                          style: TextStyle(color: textSecondary),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Quantity',
                          style: TextStyle(color: textSecondary),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Total',
                          style: TextStyle(color: textSecondary),
                        ),
                      ),
                    ],
                    rows: purchaseCtrl
                        .singlePurchaseData.value.data!.items.data
                        .map((data) {
                      return DataRow(cells: [
                        DataCell(
                          Text(
                            data.id.toString(),
                            style: TextStyle(color: primaryText),
                          ),
                        ),
                        DataCell(
                          Text(
                            data.expireDate,
                            style: TextStyle(color: primaryText),
                          ),
                        ),
                        DataCell(
                          Text(
                            data.ingredient.name,
                            style: TextStyle(color: primaryText),
                          ),
                        ),
                        DataCell(
                          Text(
                            data.unitPrice,
                            style: TextStyle(color: primaryText),
                          ),
                        ),
                        DataCell(
                          Text(
                            data.quantityAmount,
                            style: TextStyle(color: primaryText),
                          ),
                        ),
                        DataCell(
                          Text(
                            data.total,
                            style: TextStyle(color: primaryText),
                          ),
                        )
                      ]);
                    }).toList(),
                  )),
            ],
          ),
          const SizedBox(height: 20),
        ],
      )),
    );
  }

  Widget addNewPurchase(BuildContext context, bool isUpdate, {int id = -1}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      purchaseCtrl.update(["refreshAddPurchase"]);
    });
    return GetBuilder<PurchaseManagementController>(
        id: "refreshAddPurchase",
        builder: (getContext) {
          return Container(
            height: Size.infinite.height,
            width: Size.infinite.width,
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Form(
              key: purchaseCtrl.uploadPurchaseKey,
              child: ListView(
                children: [
                  textRow("Supplier*", "Purchase Date*"),
                  Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                    Expanded(
                      flex: 1,
                      child: GetBuilder<PurchaseManagementController>(
                        builder: (controller) {
                          Suppliers? supplier = foodManagementController
                              .addMenuModel.suppliers
                              .firstWhereOrNull((element) =>
                                  element.id ==
                                  int.parse(purchaseCtrl.supplierId.isEmpty
                                      ? "-1"
                                      : purchaseCtrl.supplierId));
                          return MultiSelectDropDown(
                            backgroundColor: secondaryBackground,
                            optionsBackgroundColor: secondaryBackground,
                            selectedOptionTextColor: primaryText,
                            selectedOptionBackgroundColor: primaryColor,
                            showClearIcon: false,
                            optionTextStyle:
                                TextStyle(color: primaryText, fontSize: 16),
                            onOptionSelected: (selectedOptions) {
                              purchaseCtrl.supplierId =
                                  selectedOptions.first.value ?? "";
                            },
                            options: foodManagementController
                                .addMenuModel.suppliers
                                .map((e) {
                              return ValueItem(
                                label: e.name,
                                value: e.id.toString(),
                              );
                            }).toList(),
                            hint: 'Select Supplier',
                            hintColor: primaryText,
                            selectionType: SelectionType.single,
                            selectedOptions: [
                              if (supplier != null)
                                ValueItem(
                                  label: supplier.name,
                                  value: supplier.id.toString(),
                                )
                            ],
                            chipConfig:
                                const ChipConfig(wrapType: WrapType.wrap),
                            dropdownHeight: 300,
                            selectedOptionIcon: const Icon(Icons.check_circle),
                            inputDecoration: BoxDecoration(
                              color: secondaryBackground,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(6)),
                              border: Border.all(
                                color: textSecondary.withOpacity(0.4),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: SizedBox(
                        height: 52,
                        child: GetBuilder<PurchaseManagementController>(
                          id: 'dateId',
                          builder: (controller) => GestureDetector(
                            onTap: () {
                              controller.getChooseDate(context);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: secondaryBackground,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(6)),
                                border: Border.all(
                                  color: textSecondary.withOpacity(0.4),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller.dateCtlr.value,
                                    style: TextStyle(color: primaryText),
                                  ),
                                  Icon(Icons.calendar_month,
                                      color: textSecondary)
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  textRow("Payment Type*", "Ingredient*"),
                  Row(
                    children: [
                      Expanded(
                          flex: 1,
                          child: GetBuilder<PurchaseManagementController>(
                            builder: (controller) {
                              List<String> bankItem = [
                                "Cash Payment",
                                "Due Payment",
                                "Bank Payment"
                              ];

                              String selectedValue = bankItem.firstWhere(
                                  (element) =>
                                      element.toLowerCase() ==
                                      purchaseCtrl.paymentType);
                              print(selectedValue);
                              return MultiSelectDropDown(
                                backgroundColor: secondaryBackground,
                                optionsBackgroundColor: secondaryBackground,
                                selectedOptionTextColor: primaryText,
                                selectedOptionBackgroundColor: primaryColor,
                                showClearIcon: false,
                                optionTextStyle:
                                    TextStyle(color: primaryText, fontSize: 16),
                                onOptionSelected:
                                    (List<ValueItem> selectedOptions) {
                                  purchaseCtrl.paymentType =
                                      selectedOptions.first.value ?? "";
                                  purchaseCtrl.bankId = '';
                                  print(purchaseCtrl.bankId.isEmpty);
                                  print(purchaseCtrl.paymentType);
                                  purchaseCtrl.update(["updateBank"]);
                                },
                                options: bankItem.map((e) {
                                  return ValueItem(
                                    label: e,
                                    value: e.toLowerCase(),
                                  );
                                }).toList(),
                                hint: 'Select Payment Type',
                                hintColor: primaryText,
                                selectedOptions: [
                                  ValueItem(
                                    label: selectedValue,
                                    value: selectedValue.toLowerCase(),
                                  )
                                ],
                                selectionType: SelectionType.single,
                                chipConfig:
                                    const ChipConfig(wrapType: WrapType.wrap),
                                dropdownHeight: 300,
                                selectedOptionIcon:
                                    const Icon(Icons.check_circle),
                                inputDecoration: BoxDecoration(
                                  color: secondaryBackground,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(6)),
                                  border: Border.all(
                                    color: textSecondary.withOpacity(0.4),
                                  ),
                                ),
                              );
                            },
                          )),
                      const SizedBox(width: 10),
                      Expanded(
                          flex: 1,
                          child: GetBuilder<PurchaseManagementController>(
                            id: "ingredients",
                            builder: (controller) {
                              return MultiSelectDropDown(
                                backgroundColor: secondaryBackground,
                                optionsBackgroundColor: secondaryBackground,
                                selectedOptionTextColor: primaryText,
                                selectedOptionBackgroundColor: primaryColor,
                                showClearIcon: false,
                                selectedItemBuilder: (context, v) {
                                  return Chip(
                                    padding: const EdgeInsets.only(
                                        left: 12, top: 0, right: 12, bottom: 0),
                                    label: Text(v.label),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    labelPadding: EdgeInsets.zero,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    labelStyle: const TextStyle(
                                        color: Colors.white, fontSize: 14),
                                  );
                                },
                                optionTextStyle:
                                    TextStyle(color: primaryText, fontSize: 16),
                                onOptionSelected:
                                    (List<ValueItem> selectedOptions) {
                                  purchaseCtrl.ingredients.clear();
                                  for (int i = 0;
                                      i < selectedOptions.length;
                                      i++) {
                                    var temp = foodManagementController
                                        .addMenuModel.ingredients
                                        .firstWhere(
                                      (element) =>
                                          element.id ==
                                          int.parse(
                                              selectedOptions[i].value ?? "0"),
                                    );
                                    purchaseCtrl.ingredients.add(temp);
                                  }
                                  purchaseCtrl.update(['updateIngredient']);
                                },
                                options: foodManagementController
                                    .addMenuModel.ingredients
                                    .map((e) {
                                  return ValueItem(
                                    label: e.name,
                                    value: e.id.toString(),
                                  );
                                }).toList(),
                                hint: 'Select Ingredient',
                                hintColor: primaryText,
                                selectionType: SelectionType.multi,
                                chipConfig:
                                    const ChipConfig(wrapType: WrapType.wrap),
                                dropdownHeight: 300,
                                selectedOptions:
                                    purchaseCtrl.ingredients.map((e) {
                                  return ValueItem(
                                    label: e.name,
                                    value: e.id.toString(),
                                  );
                                }).toList(),
                                selectedOptionIcon:
                                    const Icon(Icons.check_circle),
                                inputDecoration: BoxDecoration(
                                  color: secondaryBackground,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(6)),
                                  border: Border.all(
                                    color: textSecondary.withOpacity(0.4),
                                  ),
                                ),
                              );
                            },
                          )),
                    ],
                  ),
                  GetBuilder<PurchaseManagementController>(
                      id: "updateBank",
                      builder: (controller) {
                        Banks? bank = foodManagementController
                            .addMenuModel.banks
                            .firstWhereOrNull((element) =>
                                element.id ==
                                int.parse(purchaseCtrl.bankId.isEmpty
                                    ? "-1"
                                    : purchaseCtrl.bankId));
                        return Column(
                          children: [
                            if (purchaseCtrl.paymentType == "bank payment")
                              const SizedBox(height: 10),
                            if (purchaseCtrl.paymentType == "bank payment")
                              textRow("Bank", ""),
                            if (purchaseCtrl.paymentType == "bank payment")
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: GetBuilder<
                                        PurchaseManagementController>(
                                      builder: (controller) {
                                        return MultiSelectDropDown(
                                          backgroundColor: secondaryBackground,
                                          optionsBackgroundColor:
                                              secondaryBackground,
                                          selectedOptionTextColor: primaryText,
                                          showClearIcon: false,
                                          selectedOptionBackgroundColor:
                                              primaryColor,
                                          optionTextStyle: TextStyle(
                                              color: primaryText, fontSize: 16),
                                          onOptionSelected: (List<ValueItem>
                                              selectedOptions) {
                                            purchaseCtrl.bankId =
                                                selectedOptions.first.value
                                                    .toString();
                                          },
                                          options: foodManagementController
                                              .addMenuModel.banks
                                              .map((e) {
                                            return ValueItem(
                                              label: e.name,
                                              value: e.id.toString(),
                                            );
                                          }).toList(),
                                          hint: 'Select Bank',
                                          selectedOptions: [
                                            if (bank != null)
                                              ValueItem(
                                                label: bank.name,
                                                value: bank.id.toString(),
                                              )
                                          ],
                                          hintColor: primaryText,
                                          selectionType: SelectionType.single,
                                          chipConfig: const ChipConfig(
                                              wrapType: WrapType.wrap),
                                          dropdownHeight: 300,
                                          selectedOptionIcon:
                                              const Icon(Icons.check_circle),
                                          inputDecoration: BoxDecoration(
                                            color: secondaryBackground,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(6)),
                                            border: Border.all(
                                              color: textSecondary
                                                  .withOpacity(0.4),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    flex: 1,
                                    child: SizedBox(),
                                  ),
                                ],
                              ),
                          ],
                        );
                      }),
                  const SizedBox(height: 10),
                  textRow("Details*", ""),
                  SizedBox(
                    child: TextFormField(
                      controller: purchaseCtrl.purchaseDetailController,
                      keyboardType: TextInputType.text,
                      maxLines: 3,
                      style: TextStyle(
                          fontSize: fontVerySmall, color: primaryText),
                      decoration: InputDecoration(
                          fillColor: secondaryBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: textSecondary.withOpacity(0.4))),
                          hintStyle: TextStyle(
                              fontSize: fontVerySmall, color: primaryText),
                          hintText: "Enter..."),
                    ),
                  ),
                  const SizedBox(height: 30),
                  GetBuilder<PurchaseManagementController>(
                    id: "updateIngredient",
                    builder: (controller) {
                      if (purchaseCtrl.ingredients.isNotEmpty) {
                        return _singleIngredient(isUpdate);
                      }
                      return const SizedBox();
                    },
                  ),
                  const SizedBox(height: 30),
                  GetBuilder<PurchaseManagementController>(
                    id: "updateIngredient",
                    builder: (controller) {
                      return _finalCalculation();
                    },
                  ),
                  const SizedBox(height: 30),
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: ()async{
                          if (purchaseCtrl.supplierId.isEmpty ||
                              purchaseCtrl.dateCtlr.isEmpty ||
                              purchaseCtrl
                                  .purchaseDetailController.text.isEmpty ||
                              purchaseCtrl.ingredients.isEmpty) {
                            Utils.showSnackBar(
                                "Please fill-up all required fields");
                            return;
                          }

                          if (purchaseCtrl.paymentType == "bank payment" &&
                              purchaseCtrl.bankId.isEmpty) {
                            Utils.showSnackBar("Please select a bank");
                            return;
                          }
                          for (int i = 0;
                              i < purchaseCtrl.ingredients.length;
                              i++) {
                            if (purchaseCtrl.ingredients[i].expireDate.isEmpty) {
                              Utils.showSnackBar(
                                  "Please select a date for ingredient id = ${purchaseCtrl.ingredients[i].id}");
                              return;
                            }
                            if (purchaseCtrl.ingredients[i].quantity < 1) {
                              Utils.showSnackBar(
                                  "quantity must be higher than 0. On ingredient id = ${purchaseCtrl.ingredients[i].id}");
                              return;
                            }
                          }

                          double discount = purchaseCtrl.discountType == "fixed"
                              ? double.parse(
                                  purchaseCtrl.purchaseDiscountController.text)
                              : ((double.parse(purchaseCtrl
                                          .purchaseDiscountController.text) /
                                      100) *
                                  purchaseCtrl.purchaseTotal);

                          await purchaseCtrl.addNewPurchase(discount, isUpdate,
                              id: id);
                      },
                      child: Container(
                        height: 40,
                        width: 170,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                            child: Text(isUpdate ? "Update" : "Submit",
                                style: const TextStyle(
                                    color: white, fontSize: 16))),
                        ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        });
  }

  Widget _singleIngredient(bool isUpdate) {
    List<String> header = [
      "ID NO",
      "Expire Date",
      "Ingredient*",
      "Unit Price",
      "Quantity/Amount*",
      "Total",
      "Action"
    ];
    return DataTable(
        dataRowHeight: 70,
        columns: [
          for (int i = 0; i < header.length; i++)
            DataColumn(
              label: Text(
                header[i],
                style: TextStyle(color: textSecondary),
              ),
            ),
          // column to set the name
        ],
        rows: purchaseCtrl.ingredients.map(
          (item) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    '${item.id}',
                    style: TextStyle(color: primaryText),
                  ),
                ),
                DataCell(
                  SizedBox(
                    height: 52,
                    child: GetBuilder<PurchaseManagementController>(
                      id: 'dateId',
                      builder: (controller) => GestureDetector(
                        onTap: () async {
                          String date = await controller.getChooseDate(context,
                              shouldChange: false);
                          item.expireDate = date;
                          controller.update(["dateId"]);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: secondaryBackground,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6)),
                            border: Border.all(
                              color: textSecondary.withOpacity(0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.expireDate,
                                style: TextStyle(color: primaryText),
                              ),
                              Icon(Icons.calendar_month, color: textSecondary)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    item.name,
                    style: TextStyle(color: primaryText),
                  ),
                ),
                DataCell(
                  TextFormField(
                    onChanged: (value) {
                      if (value.isEmpty) value = "0";
                      item.price = value;
                      purchaseCtrl.update(["updateIngredient"]);
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLines: 1,
                    initialValue: item.price,
                    style:
                        TextStyle(fontSize: fontVerySmall, color: primaryText),
                    decoration: InputDecoration(
                      fillColor: secondaryBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: textSecondary.withOpacity(0.4))),
                      hintStyle: TextStyle(
                          fontSize: fontVerySmall, color: primaryText),
                    ),
                  ),
                ),
                DataCell(
                  TextFormField(
                    onChanged: (value) {
                      if (value.isEmpty) value = "0";
                      item.quantity = int.parse(value);
                      purchaseCtrl.update(["updateIngredient"]);
                    },
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    maxLines: 1,

                    initialValue: item.quantity.toString(),
                    style:
                        TextStyle(fontSize: fontVerySmall, color: primaryText),
                    decoration: InputDecoration(
                      fillColor: secondaryBackground,
                      suffix: Text(item.unitName),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: textSecondary.withOpacity(0.4))),
                      hintStyle: TextStyle(
                          fontSize: fontVerySmall, color: primaryText),
                    ),
                  ),
                ),
                DataCell(
                  GetBuilder<PurchaseManagementController>(
                      id: "updateTotal",
                      builder: (context) {
                        return Text(
                          '${item.quantity * double.parse(item.price)}',
                          style: TextStyle(color: primaryText),
                        );
                      }),
                ),
                DataCell(
                  InkWell(
                    onTap: () {
                      purchaseCtrl.ingredients
                          .removeWhere((element) => element.id == item.id);
                      purchaseCtrl.update(['updateIngredient']);
                      purchaseCtrl.update(['ingredients']);
                      var temp = purchaseCtrl
                          .singlePurchaseData.value.data?.items.data
                          .firstWhereOrNull(
                              (element) => element.ingredient.id == item.id);
                      if (isUpdate && temp != null) {
                        purchaseCtrl.deletePurchaseItem(id: temp.id);
                      }
                    },
                    child: Image.asset(
                      "assets/delete.png",
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            );
          },
        ).toList());
  }

  Widget _finalCalculation() {
    List<String> header = [
      "Total Amount",
      "Shipping Charge*",
      "Discount Type",
      "Discount*",
      "Grand Total",
      "Paid*",
      "Due"
    ];

    purchaseCtrl.purchaseTotal =
        Utils.calcSubTotalQuantityAmount(purchaseCtrl.ingredients);

    return DataTable(
      dataRowHeight: 70,
      columns: [
        for (int i = 0; i < header.length; i++)
          DataColumn(
            label: Text(
              header[i],
              style: TextStyle(color: textSecondary),
            ),
          ),
        // column to set the name
      ],
      rows: [
        DataRow(
          cells: [
            DataCell(
              Text(
                purchaseCtrl.purchaseTotal.toStringAsFixed(2),
                style: TextStyle(color: primaryText),
              ),
            ),
            DataCell(
              TextFormField(
                controller: purchaseCtrl.purchaseShippingChargeController,
                onChanged: (value) {},
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLines: 1,
                //initialValue: item.quantity.toString(),
                style: TextStyle(fontSize: fontVerySmall, color: primaryText),
                decoration: InputDecoration(
                  fillColor: secondaryBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: textSecondary.withOpacity(0.4))),
                  hintStyle:
                      TextStyle(fontSize: fontVerySmall, color: primaryText),
                ),
              ),
            ),
            DataCell(
              SizedBox(
                width: 150,
                child: MultiSelectDropDown(
                  backgroundColor: secondaryBackground,
                  optionsBackgroundColor: secondaryBackground,
                  selectedOptionTextColor: primaryText,
                  selectedOptionBackgroundColor: primaryColor,
                  optionTextStyle: TextStyle(color: primaryText, fontSize: 16),
                  onOptionSelected: (List<ValueItem> selectedOptions) {
                    purchaseCtrl.discountType =
                        selectedOptions.first.value ?? "";
                    purchaseCtrl.update(["grandTotal"]);
                  },
                  options: [
                    "Fixed",
                    "Percentage",
                  ].map((e) {
                    return ValueItem(
                      label: e,
                      value: e.toLowerCase(),
                    );
                  }).toList(),
                  selectedOptions: const [
                    ValueItem(
                      label: "Fixed",
                      value: "fixed",
                    )
                  ],
                  hintColor: primaryText,
                  showClearIcon: false,
                  selectionType: SelectionType.single,
                  chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                  dropdownHeight: 100,
                  selectedOptionIcon: const Icon(Icons.check_circle),
                  inputDecoration: BoxDecoration(
                    color: secondaryBackground,
                    borderRadius: const BorderRadius.all(Radius.circular(6)),
                    border: Border.all(
                      color: alternate,
                    ),
                  ),
                ),
              ),
            ),
            DataCell(
              TextFormField(
                //controller: purchaseCtrl.purchaseDiscountController,
                onChanged: (value) {
                  if (value.isEmpty) value = "0";
                  purchaseCtrl.purchaseDiscountController.text = value;
                  purchaseCtrl.update(["grandTotal"]);
                  purchaseCtrl.update(["updateDue"]);
                },
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLines: 1,
                initialValue: purchaseCtrl.purchaseDiscountController.text,
                style: TextStyle(fontSize: fontVerySmall, color: primaryText),
                decoration: InputDecoration(
                  fillColor: secondaryBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: textSecondary.withOpacity(0.4))),
                  hintStyle:
                      TextStyle(fontSize: fontVerySmall, color: primaryText),
                ),
              ),
            ),
            DataCell(GetBuilder<PurchaseManagementController>(
                id: "grandTotal",
                builder: (context) {
                  return purchaseCtrl.discountType == "fixed"
                      ? Text((purchaseCtrl.purchaseTotal -
                              double.parse(
                                  purchaseCtrl.purchaseDiscountController.text))
                          .toStringAsFixed(2), style: TextStyle(color: textSecondary))
                      : Text((purchaseCtrl.purchaseTotal -
                              ((double.parse(purchaseCtrl
                                          .purchaseDiscountController.text) /
                                      100) *
                                  purchaseCtrl.purchaseTotal))
                          .toStringAsFixed(2), style: TextStyle(color: textSecondary));
                })),
            DataCell(
              TextFormField(
                onChanged: (value) {
                  if (value.isEmpty) value = "0";
                  purchaseCtrl.purchasePaidController.text = value;
                  purchaseCtrl.update(["updateDue"]);
                },
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLines: 1,
                initialValue: purchaseCtrl.purchasePaidController.text,
                style: TextStyle(fontSize: fontVerySmall, color: primaryText),
                decoration: InputDecoration(
                  fillColor: secondaryBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  enabledBorder: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: textSecondary.withOpacity(0.4))),
                  hintStyle:
                      TextStyle(fontSize: fontVerySmall, color: primaryText),
                ),
              ),
            ),
            DataCell(
              GetBuilder<PurchaseManagementController>(
                  id: "updateDue",
                  builder: (context) {
                    double discount = purchaseCtrl.discountType == "fixed"
                        ? double.parse(
                            purchaseCtrl.purchaseDiscountController.text)
                        : ((double.parse(purchaseCtrl
                                    .purchaseDiscountController.text) /
                                100) *
                            purchaseCtrl.purchaseTotal);
                    print(discount);
                    print("99999999999999999999999 discount");
                    return Text(
                      (purchaseCtrl.purchaseTotal -
                              discount -
                              double.parse(
                                  purchaseCtrl.purchasePaidController.text))
                          .toStringAsFixed(2),
                      style: TextStyle(color: primaryText),
                    );
                  }),
            ),
          ],
        )
      ],
    );
  }

  Widget addNewExpence(BuildContext context) {
    return Container(
        height: Size.infinite.height,
        width: Size.infinite.width,
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: Form(
          key: purchaseCtrl.uploadExpenceFormKey,
          child: ListView(children: [
            textRow("Responsible Person", "Category"),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Expanded(
                  flex: 1,
                  child: GetBuilder<PurchaseManagementController>(
                    builder: (controller) {
                      return MultiSelectDropDown(
                        backgroundColor: secondaryBackground,
                        optionsBackgroundColor: secondaryBackground,
                        selectedOptionTextColor: primaryText,
                        selectedOptionBackgroundColor: primaryColor,
                        optionTextStyle:
                            TextStyle(color: primaryText, fontSize: 16),
                        onOptionSelected: (List<ValueItem> selectedOptions) {
                          purchaseCtrl.uploadExpenceResPersonList =
                              selectedOptions
                                  .map((ValueItem e) => int.parse(e.value!))
                                  .toList();
                          print(purchaseCtrl.uploadExpenceResPersonList);
                        },
                        options: controller.responsiblePersons.map((e) {
                          return ValueItem(
                            label: e.name ?? "",
                            value: e.id.toString(),
                          );
                        }).toList(),
                        hint: 'Select Person',
                        hintColor: primaryText,
                        selectionType: SelectionType.single,
                        chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                        dropdownHeight: 300,
                        selectedOptionIcon: const Icon(Icons.check_circle),
                        inputDecoration: BoxDecoration(
                          color: secondaryBackground,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6)),
                          border: Border.all(
                            color: alternate,
                          ),
                        ),
                      );
                    },
                  )),
              const SizedBox(width: 10),
              Expanded(
                  flex: 1,
                  child: GetBuilder<PurchaseManagementController>(
                    builder: (controller) {
                      return MultiSelectDropDown(
                        backgroundColor: secondaryBackground,
                        optionsBackgroundColor: secondaryBackground,
                        selectedOptionTextColor: primaryText,
                        selectedOptionBackgroundColor: primaryColor,
                        optionTextStyle:
                            TextStyle(color: primaryText, fontSize: 16),
                        onOptionSelected: (List<ValueItem> selectedOptions) {
                          purchaseCtrl.uploadExpenceCatList = selectedOptions
                              .map((ValueItem e) => int.parse(e.value!))
                              .toList();
                          print(purchaseCtrl.uploadExpenceCatList);
                        },
                        options:
                            controller.expenseCategoryData.value.data.map((e) {
                          return ValueItem(
                            label: e.name.toString(),
                            value: e.id.toString(),
                          );
                        }).toList(),
                        hint: 'Select Category',
                        hintColor: primaryText,
                        selectionType: SelectionType.single,
                        chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                        dropdownHeight: 300,
                        selectedOptionIcon: const Icon(Icons.check_circle),
                        inputDecoration: BoxDecoration(
                          color: secondaryBackground,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6)),
                          border: Border.all(
                            color: alternate,
                          ),
                        ),
                      );
                    },
                  )),
            ]),
            const SizedBox(height: 10),
            textRow("Amount", "Date"),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 52,
                    child: TextFormField(
                        controller: purchaseCtrl.expenceAmountCtlr,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            fontSize: fontVerySmall, color: primaryText),
                        decoration: InputDecoration(
                            fillColor: secondaryBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: alternate)),
                            hintStyle: TextStyle(
                                fontSize: fontVerySmall, color: primaryText),
                            hintText: "Enter Amount")),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 52,
                    child: GetBuilder<PurchaseManagementController>(
                      id: 'dateId',
                      builder: (controller) => GestureDetector(
                        onTap: () {
                          controller.getChooseDate(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: secondaryBackground,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6)),
                            border: Border.all(
                              color: alternate,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.dateCtlr.value,
                                style: TextStyle(color: primaryText),
                              ),
                              Icon(Icons.calendar_month, color: textSecondary)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            textRow("Note", ""),
            SizedBox(
              child: TextFormField(
                  controller: purchaseCtrl.expenceNoteCtlr,
                  keyboardType: TextInputType.text,
                  maxLines: 3,
                  style: TextStyle(fontSize: fontVerySmall, color: primaryText),
                  decoration: InputDecoration(
                      fillColor: secondaryBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: alternate)),
                      hintStyle: TextStyle(
                          fontSize: fontVerySmall, color: primaryText),
                      hintText: "Enter...")),
            ),
            const SizedBox(height: 30),
            Container(
              height: 40,
              width: 50,
              child: normalButton(
                "Submit",
                primaryColor,
                white,
                onPressed: () async {
                  if (purchaseCtrl.uploadExpenceFormKey.currentState!
                      .validate()) {
                    purchaseCtrl.addExpence(
                        purchaseCtrl.uploadExpenceResPersonList.first,
                        purchaseCtrl.uploadExpenceCatList.first,
                        double.parse(purchaseCtrl.expenceAmountCtlr.text),
                        purchaseCtrl.dateCtlr.value,
                        note: purchaseCtrl.expenceNoteCtlr.text);
                  }
                  purchaseCtrl.expenceAmountCtlr.clear();
                  purchaseCtrl.dateCtlr.close();
                  purchaseCtrl.expenceNoteCtlr.clear();
                },
              ),
            ),
            const SizedBox(height: 30),
          ]),
        ));
  }

  Widget updateExpenceForm(dynamic itemId, BuildContext context) {
    print(purchaseCtrl.singleExpenseData.value.data!.category.name);
    print(purchaseCtrl.singleExpenseData.value.data!.category.id);

    return Container(
        height: Size.infinite.height,
        width: Size.infinite.width,
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: Form(
          key: purchaseCtrl.updateExpenceFormKey,
          child: ListView(children: [
            textRow("Responsible Person", "Category"),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Expanded(
                  flex: 1,
                  child: GetBuilder<PurchaseManagementController>(
                    builder: (controller) {
                      return MultiSelectDropDown(
                        backgroundColor: secondaryBackground,
                        optionsBackgroundColor: secondaryBackground,
                        selectedOptionTextColor: primaryText,
                        selectedOptionBackgroundColor: primaryColor,
                        optionTextStyle:
                            TextStyle(color: primaryText, fontSize: 16),
                        onOptionSelected: (List<ValueItem> selectedOptions) {
                          purchaseCtrl.updateExpenceResPersonList =
                              selectedOptions
                                  .map((ValueItem e) => int.parse(e.value!))
                                  .toList();
                          print(purchaseCtrl.updateExpenceResPersonList);
                        },
                        options: controller.responsiblePersons.map((e) {
                          return ValueItem(
                            label: e.name ?? "",
                            value: e.id.toString(),
                          );
                        }).toList(),
                        selectedOptions:
                            controller.expenseData.value.data.map((e) {
                          return ValueItem(
                            label: purchaseCtrl.expenseData.value.data
                                .firstWhere((element) => element.id == itemId)
                                .person!
                                .name,
                            value: purchaseCtrl.expenseData.value.data
                                .firstWhere((element) => element.id == itemId)
                                .person!
                                .id
                                .toString(),
                          );
                        }).toList(),
                        hint: purchaseCtrl.expenseData.value.data
                            .firstWhere((element) => element.id == itemId)
                            .person!
                            .name,
                        hintColor: primaryText,
                        selectionType: SelectionType.single,
                        chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                        dropdownHeight: 300,
                        selectedOptionIcon: const Icon(Icons.check_circle),
                        inputDecoration: BoxDecoration(
                          color: secondaryBackground,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6)),
                          border: Border.all(
                            color: alternate,
                          ),
                        ),
                      );
                    },
                  )),
              const SizedBox(width: 10),
              Expanded(
                  flex: 1,
                  child: GetBuilder<PurchaseManagementController>(
                    builder: (controller) {
                      return MultiSelectDropDown(
                        backgroundColor: secondaryBackground,
                        optionsBackgroundColor: secondaryBackground,
                        selectedOptionTextColor: primaryText,
                        selectedOptionBackgroundColor: primaryColor,
                        optionTextStyle:
                            TextStyle(color: primaryText, fontSize: 16),
                        onOptionSelected: (List<ValueItem> selectedOptions) {
                          purchaseCtrl.updateExpenceCatList = selectedOptions
                              .map((ValueItem e) => int.parse(e.value!))
                              .toList();
                          print(purchaseCtrl.updateExpenceCatList);
                        },
                        selectedOptions: [
                          ValueItem(
                            label: purchaseCtrl
                                .singleExpenseData.value.data!.category.name,
                            value: purchaseCtrl
                                .singleExpenseData.value.data!.category.id
                                .toString(),
                          ),
                        ],
                        options:
                            controller.expenseCategoryData.value.data.map((e) {
                          return ValueItem(
                            label: e.name.toString(),
                            value: e.id.toString(),
                          );
                        }).toList(),
                        hint: purchaseCtrl
                            .singleExpenseData.value.data!.category.name,
                        hintColor: primaryText,
                        selectionType: SelectionType.single,
                        chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                        dropdownHeight: 300,
                        selectedOptionIcon: const Icon(Icons.check_circle),
                        inputDecoration: BoxDecoration(
                          color: secondaryBackground,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(6)),
                          border: Border.all(
                            color: alternate,
                          ),
                        ),
                      );
                    },
                  )),
            ]),
            const SizedBox(height: 10),
            textRow("Amount", "Date"),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 52,
                    child: TextFormField(
                        controller: purchaseCtrl.updateExpenceAmountCtlr,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                            fontSize: fontVerySmall, color: primaryText),
                        decoration: InputDecoration(
                            fillColor: secondaryBackground,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: alternate)),
                            hintStyle: TextStyle(
                                fontSize: fontVerySmall, color: primaryText),
                            hintText: "Enter Amount")),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 52,
                    child: GetBuilder<PurchaseManagementController>(
                      id: 'dateId',
                      builder: (controller) => GestureDetector(
                        onTap: () {
                          controller.getChooseDate(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: secondaryBackground,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(6)),
                            border: Border.all(
                              color: alternate,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                controller.dateCtlr.value,
                                style: TextStyle(color: primaryText),
                              ),
                              Icon(Icons.calendar_month, color: textSecondary)
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            textRow("Note", ""),
            SizedBox(
              child: TextFormField(
                  controller: purchaseCtrl.updateExpenceNoteCtlr,
                  keyboardType: TextInputType.text,
                  maxLines: 3,
                  style: TextStyle(fontSize: fontVerySmall, color: primaryText),
                  decoration: InputDecoration(
                      fillColor: secondaryBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: alternate)),
                      hintStyle: TextStyle(
                          fontSize: fontVerySmall, color: primaryText),
                      hintText: "Enter...")),
            ),
            const SizedBox(height: 30),
            Container(
              height: 40,
              width: 50,
              child: normalButton(
                "Submit",
                primaryColor,
                white,
                onPressed: () async {
                  purchaseCtrl.updateExpence(
                    purchaseCtrl.updateExpenceResPersonList.first,
                    purchaseCtrl.updateExpenceCatList.first,
                    double.parse(purchaseCtrl.updateExpenceAmountCtlr.text),
                    purchaseCtrl.dateCtlr.value.toString(),
                    purchaseCtrl.updateExpenceNoteCtlr.text,
                    id: itemId.toString(),
                  );
                },
              ),
            ),
            const SizedBox(height: 30),
          ]),
        ));
  }

  Widget addNewExpenseCategory() {
    return Container(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: ListView(children: [
          textRow('Name', ''),
          normalTextField(
            hint: "Enter Expence Category Name",
            purchaseCtrl.expenseCategoryNameCtlr.value,
          ),
          const SizedBox(height: 10),
          Container(
            height: 40,
            width: 50,
            child: normalButton(
              'Submit',
              primaryColor,
              white,
              onPressed: () async {
                purchaseCtrl.addNewExpenseCategory(
                  purchaseCtrl.expenseCategoryNameCtlr.value.text,
                );
                purchaseCtrl.expenseCategoryNameCtlr.value.clear();
              },
            ),
          ),
        ]));
  }

  Widget viewExpenseDetails() {
    return Container(
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: ListView(children: [
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'ID:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Text(
                        purchaseCtrl.singleExpenseData.value.data!.id
                            .toString(),
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Person Id:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                  flex: 7,
                  child: Container(
                    child: Text(
                      purchaseCtrl.singleExpenseData.value.data!.person.id
                          .toString(),
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Person Name:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Text(
                        purchaseCtrl.singleExpenseData.value.data!.person.name
                            .toString(),
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Category Id:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Text(
                        purchaseCtrl.singleExpenseData.value.data!.category.id
                            .toString(),
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Category Name:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Text(
                        purchaseCtrl.singleExpenseData.value.data!.category.name
                            .toString(),
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Date:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Text(
                        purchaseCtrl.singleExpenseData.value.data!.date
                            .toString(),
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Amount:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Text(
                        purchaseCtrl.singleExpenseData.value.data!.amount
                            .toString(),
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Note:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Text(
                        purchaseCtrl.singleExpenseData.value.data!.note
                            .toString(),
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
          SizedBox(
            height: 60,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Container(
                      child: Text(
                        'Status:',
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    flex: 7,
                    child: Container(
                      child: Text(
                        purchaseCtrl.singleExpenseData.value.data!.status
                            .toString(),
                        style: TextStyle(
                            fontSize: fontVerySmall,
                            color: primaryText,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
              ],
            ),
          ),
        ]));
  }

}
