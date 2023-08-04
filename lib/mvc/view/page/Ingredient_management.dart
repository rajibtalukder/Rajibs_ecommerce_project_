import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:klio_staff/constant/color.dart';
import 'package:klio_staff/constant/value.dart';
import 'package:klio_staff/mvc/controller/Ingredient_management_controller.dart';
import 'package:klio_staff/mvc/model/ingredient_category_model.dart';
import 'package:klio_staff/mvc/model/ingredient_supplier_model.dart'
    as supplier;
import 'package:klio_staff/mvc/model/ingredient_unit_model.dart';
import 'package:klio_staff/mvc/view/widget/custom_widget.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:klio_staff/mvc/view/dialog/custom_dialog.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

import '../../model/Ingredient_list_model.dart';

class IngredientManagement extends StatefulWidget {
  const IngredientManagement({Key? key}) : super(key: key);

  @override
  State<IngredientManagement> createState() => _IngredientManagementState();
}

class _IngredientManagementState extends State<IngredientManagement>
    with SingleTickerProviderStateMixin {
  IngredientController _ingredientController = Get.put(IngredientController());

  int _currentSelection = 0;
  late TabController controller;
  late ScrollController scrollController;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    controller = TabController(vsync: this, length: 4);
    scrollController = ScrollController();

    controller.addListener(() {
      _currentSelection = controller.index;
      _ingredientController.update(['changeCustomTabBar']);

      if (_currentSelection == 0) {
          textController.text = '';
          _ingredientController
              .getIngredientByKeyword(showLoading: false);
      } else if (_currentSelection == 1) {
          textController.text = '';
          _ingredientController
              .getIngredientCategoryByKeyword(showLoading: false);
      } else if (_currentSelection == 2) {
          textController.text = '';
          _ingredientController
              .getIngredientUnitByKeyword(showLoading: false);
      } else if (_currentSelection == 3) {
          textController.text = '';
          _ingredientController
              .getIngredientSupplierByKeyword(showLoading: false);
      }
    });

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.95) {
        if (_currentSelection == 0 && !_ingredientController.isLoading) {
          _ingredientController.getIngredientDataList();
        } else if (_currentSelection == 1 && !_ingredientController.isLoading) {
          _ingredientController.getIngredientCategory();
        } else if (_currentSelection == 2 && !_ingredientController.isLoading) {
          _ingredientController.getIngredientUnit();
        } else if (_currentSelection == 3 && !_ingredientController.isLoading) {
          _ingredientController.getIngredientSupplier();
        }
      }
    });
    super.initState();
  }

  int dropdownvalue = 1;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            GetBuilder<IngredientController>(
              id: "changeCustomTabBar",
              builder: (controller) => itemTitleHeader(),
            ),
            customTapbarHeader(controller),
            Expanded(
              child: TabBarView(
                controller: controller,
                children: [
                  ingredientDataTable(),
                  ingredientCategoryDataTable(),
                  ingredientUnitDataTable(),
                  ingredientSupplierDataTable(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  DataRow buildLoadingAndNoData(bool showLoading, int rowNumber) {
    if (!showLoading) {
      return DataRow(cells: [
        if (rowNumber == 8)
          const DataCell(CircularProgressIndicator(color: Colors.transparent)),
        if (rowNumber == 8 || rowNumber == 7)
          const DataCell(CircularProgressIndicator(color: Colors.transparent)),
        const DataCell(CircularProgressIndicator(color: Colors.transparent)),
        const DataCell(CircularProgressIndicator(color: Colors.transparent)),
        DataCell(Text('No Data', style: TextStyle(color: primaryText))),
        const DataCell(CircularProgressIndicator(color: Colors.transparent)),
        if (rowNumber == 8 || rowNumber == 7 || rowNumber == 5)
          const DataCell(CircularProgressIndicator(color: Colors.transparent)),
        if (rowNumber == 8 || rowNumber == 7)
          const DataCell(CircularProgressIndicator(color: Colors.transparent)),
      ]);
    } else {
      return DataRow(cells: [
        if (rowNumber == 8)
          const DataCell(CircularProgressIndicator(color: Colors.transparent)),
        if (rowNumber == 8 || rowNumber == 7)
          const DataCell(CircularProgressIndicator(color: Colors.transparent)),
        const DataCell(CircularProgressIndicator(color: Colors.transparent)),
        const DataCell(CircularProgressIndicator(color: Colors.transparent)),
        const DataCell(CircularProgressIndicator()),
        const DataCell(CircularProgressIndicator(color: Colors.transparent)),
        if (rowNumber == 8 || rowNumber == 7 || rowNumber == 5)
          const DataCell(CircularProgressIndicator(color: Colors.transparent)),
        if (rowNumber == 8 || rowNumber == 7)
          const DataCell(CircularProgressIndicator(color: Colors.transparent)),
      ]);
    }
  }

  Widget ingredientDataTable() {
    return Card(
      color: secondaryBackground,
      child: SingleChildScrollView(
        controller: scrollController,
        child: GetBuilder<IngredientController>(
            id: "ingredientTab",
            builder: (controller) {
              List<Ingrediant> data =
                  controller.ingredientData.value.data ?? [];
              if (data.isEmpty && controller.haveMoreIngredient) {
                return Center(
                    child: Container(
                        height: 40,
                        width: 40,
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.3),
                        child: CircularProgressIndicator()));
              }
              if (data.isEmpty && !controller.haveMoreIngredient) {
                data.add(Ingrediant(id: 0));
              }
              if (!controller.haveMoreIngredient && data.last.id != 0) {
                data.add(Ingrediant(id: 0));
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
                        'Code',
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
                        'Category',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Purchase Price',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Alert Qty',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Unit',
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
                  rows: data.map(
                    (item) {
                      if (item.id == 0 && !controller.haveMoreIngredient) {
                        return buildLoadingAndNoData(false, 8);
                      } else if (item ==
                              controller.ingredientData.value.data!.last &&
                          !controller.isLoading &&
                          controller.haveMoreIngredient) {
                        return buildLoadingAndNoData(true, 8);
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
                              '${item.code ?? ""}',
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
                              '${item.categoryName ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.purchasePrice ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.alertQty ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.unitName ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Row(
                              // mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Container(
                                //   height: 35,
                                //   width: 35,
                                //   decoration: BoxDecoration(
                                //     color: Color(0xffE1FDE8),
                                //     borderRadius: BorderRadius.circular(25.0),
                                //   ),
                                //   child: Image.asset(
                                //     "assets/hide.png",
                                //     height: 15,
                                //     width: 15,
                                //     color: Color(0xff00A600),
                                //   ),
                                // ),
                                // SizedBox(
                                //   width: 10,
                                // ),
                                Container(
                                  height: 35,
                                  width: 35,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffFEF4E1),
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      _ingredientController
                                          .getSingleIngredientData(id: item.id)
                                          .then((value) {
                                        showCustomDialogResponsive(
                                          context,
                                          "Update Ingredient",
                                          updateIngrediant(item.id),
                                          300,
                                          400,
                                        );
                                        _ingredientController
                                                .updateIngrediantNameCtlr.text =
                                            _ingredientController
                                                .singleIngredientData
                                                .value
                                                .data!
                                                .name;
                                        _ingredientController
                                                .updateIngredientPriceCtlr
                                                .text =
                                            _ingredientController
                                                .singleIngredientData
                                                .value
                                                .data!
                                                .purchasePrice;
                                        _ingredientController
                                                .updateIngredintCodeCtlr.text =
                                            _ingredientController
                                                .singleIngredientData
                                                .value
                                                .data!
                                                .code;
                                        _ingredientController
                                                .updateIngredintUnitCtlr.text =
                                            _ingredientController
                                                .singleIngredientData
                                                .value
                                                .data!
                                                .unitName;
                                        _ingredientController
                                                .updateIngredintAlertQtyCtlr
                                                .text =
                                            _ingredientController
                                                .singleIngredientData
                                                .value
                                                .data!
                                                .alertQty
                                                .toString();
                                        _ingredientController
                                            .updateIngredientCatgoryList
                                            .add(controller.singleIngredientData
                                                .value.data!.categoryName);
                                        _ingredientController
                                            .updateIngredientUnitList
                                            .add(controller.singleIngredientData
                                                .value.data!.unitName);
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
                                          onAccept: () async {
                                        _ingredientController
                                            .deleteIngredientDataList(
                                                id: item.id);
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

  Widget ingredientCategoryDataTable() {
    return Card(
      color: secondaryBackground,
      child: SingleChildScrollView(
        controller: scrollController,
        child: GetBuilder<IngredientController>(
            id: "categoryTab",
            builder: (controller) {
              List<IngrediantCategory> data =
                  controller.ingredientCategoryData.value.data;
              if (controller.ingredientCategoryData.value.data.isEmpty &&
                  controller.haveMoreCategory) {
                return Center(
                    child: Container(
                        height: 40,
                        width: 40,
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.3),
                        child: CircularProgressIndicator()));
              }
              if (data.isEmpty && !controller.haveMoreCategory) {
                data.add(IngrediantCategory(id: 0, name: ''));
              }
              if (!controller.haveMoreCategory && data.last.id != 0) {
                data.add(IngrediantCategory(id: 0, name: ''));
              }
              return DataTable(
                  // dataRowHeight: 70,
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
                  rows: data.map(
                    (item) {
                      if (item.id == 0 && !controller.haveMoreCategory) {
                        return buildLoadingAndNoData(false, 4);
                      } else if (item ==
                              controller
                                  .ingredientCategoryData.value.data.last &&
                          !controller.isLoading &&
                          controller.haveMoreCategory) {
                        return buildLoadingAndNoData(true, 4);
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
                              item.name ?? "",
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
                                      onAccept: () async {
                                    _ingredientController
                                        .deleteIngredientCategory(id: item.id);
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
                          )
                        ],
                      );
                    },
                  ).toList());
            }),
      ),
    );
  }

  Widget ingredientUnitDataTable() {
    return Card(
      color: secondaryBackground,
      child: SingleChildScrollView(
        controller: scrollController,
        child: GetBuilder<IngredientController>(
            id: "unitTab",
            builder: (controller) {
              List<IngrediantUnit> data =
                  controller.ingredientUnitData.value.data;
              if (data.isEmpty && !controller.haveMoreUnit) {
                data.add(IngrediantUnit(id: 0, name: '', description: ''));
              }
              if (!controller.haveMoreUnit && data.last.id != 0) {
                data.add(IngrediantUnit(id: 0, name: '', description: ''));
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
                        'Description',
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
                  rows: data.map(
                    (item) {
                      if (item.id == 0 && !controller.haveMoreUnit) {
                        return buildLoadingAndNoData(false, 5);
                      } else if (item ==
                              controller.ingredientUnitData.value.data.last &&
                          !controller.isLoading &&
                          controller.haveMoreUnit) {
                        return buildLoadingAndNoData(true, 5);
                      }
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '${item.id}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.name,
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.description,
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
                                      onAccept: () async {
                                    _ingredientController.deleteIngredientUnit(
                                        id: item.id);
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
                          )
                        ],
                      );
                    },
                  ).toList());
            }),
      ),
    );
  }

  Widget ingredientSupplierDataTable() {
    return Card(
      color: secondaryBackground,
      child: SingleChildScrollView(
        controller: scrollController,
        child: GetBuilder<IngredientController>(
            id: "supplierTab",
            builder: (controller) {
              List<supplier.Datum> data =
                  controller.ingredientSupplierData.value.data;

              if (data.isEmpty && !controller.haveMoreSupplier) {
                data.add(
                  supplier.Datum(
                    id: 0,
                    name: '',
                    address: '',
                    email: '',
                    idCardBack: '',
                    idCardFront: '',
                    phone: '',
                    reference: '',
                    status: '',
                  ),
                );
              }

              if (!controller.haveMoreSupplier && data.last.id != 0) {
                data.add(
                  supplier.Datum(
                    id: 0,
                    name: '',
                    address: '',
                    email: '',
                    idCardBack: '',
                    idCardFront: '',
                    phone: '',
                    reference: '',
                    status: '',
                  ),
                );
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
                        'Email',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Phone',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Reference',
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
                  rows: data.map(
                    (item) {
                      if (item.id == 0 && !controller.haveMoreSupplier) {
                        return buildLoadingAndNoData(false, 7);
                      } else if (item ==
                              controller
                                  .ingredientSupplierData.value.data.last &&
                          !controller.isLoading &&
                          controller.haveMoreSupplier) {
                        return buildLoadingAndNoData(true, 7);
                      }
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '${item.id}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.name,
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.email,
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.phone,
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.reference,
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
                                      _ingredientController
                                          .getSupplierSingleDetails(id: item.id)
                                          .then((value) {
                                        showCustomDialog(
                                            context,
                                            "Supplier Details",
                                            viewSupplierDetails(),
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
                                      _ingredientController
                                          .getSupplierSingleDetails(id: item.id)
                                          .then((value) {
                                        _ingredientController
                                                .updateSupplierNameCtlr.text =
                                            _ingredientController
                                                .ingredientSupplierSingleItem
                                                .value
                                                .data!
                                                .name;
                                        _ingredientController
                                                .updateSupplierEmailCtlr.text =
                                            _ingredientController
                                                .ingredientSupplierSingleItem
                                                .value
                                                .data!
                                                .email;
                                        _ingredientController
                                                .updateSupplierPhoneCtlr.text =
                                            _ingredientController
                                                .ingredientSupplierSingleItem
                                                .value
                                                .data!
                                                .phone;
                                        _ingredientController
                                                .updateSupplierRefCtlr.text =
                                            _ingredientController
                                                .ingredientSupplierSingleItem
                                                .value
                                                .data!
                                                .reference;
                                        _ingredientController
                                                .updateSupplierAddressCtlr
                                                .text =
                                            _ingredientController
                                                .ingredientSupplierSingleItem
                                                .value
                                                .data!
                                                .address;

                                        showCustomDialog(
                                            context,
                                            'Update Supplier',
                                            updateSupplier(item.id),
                                            30,
                                            400);
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
                                          onAccept: () async {
                                        _ingredientController
                                            .deleteIngredientSupplier(
                                                id: item.id);
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
                  'Ingredient',
                  style: TextStyle(fontSize: fontBig, color: primaryText),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 25),
                child: OutlinedButton.icon(
                  icon: Icon(
                    Icons.add,
                    color: primaryText,
                  ),
                  label: Text(
                    "Add New Ingredient",
                    style: TextStyle(
                      color: primaryText,
                    ),
                  ),
                  onPressed: () {
                    showCustomDialog(context, "Add New Ingredient",
                        addIngrediant(1), 30, 400);
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
      } else if (_currentSelection == 1) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  'Ingredient',
                  style: TextStyle(fontSize: fontBig, color: primaryText),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 25),
                child: OutlinedButton.icon(
                  icon: Icon(
                    Icons.add,
                    color: primaryText,
                  ),
                  label: Text(
                    "Add New Category",
                    style: TextStyle(
                      color: primaryText,
                    ),
                  ),
                  onPressed: () {
                    showCustomDialog(context, 'Add New Category',
                        addIngredientcategory(1), 100, 400);
                  },
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(width: 1.0, color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
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
                  'Ingredient',
                  style: TextStyle(fontSize: fontBig, color: primaryText),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 25),
                child: OutlinedButton.icon(
                  icon: Icon(
                    Icons.add,
                    color: primaryText,
                  ),
                  label: Text(
                    "Add New Unit",
                    style: TextStyle(
                      color: primaryText,
                    ),
                  ),
                  onPressed: () {
                    showCustomDialog(
                        context, 'Add New Unit', addNewUnit(1), 100, 300);
                  },
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(width: 1.0, color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      } else if (_currentSelection == 3) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  'Ingredient',
                  style: TextStyle(fontSize: fontBig, color: primaryText),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 25),
                child: OutlinedButton.icon(
                  icon: Icon(
                    Icons.add,
                    color: primaryText,
                  ),
                  label: Text(
                    "Add New Supplier",
                    style: TextStyle(
                      color: primaryText,
                    ),
                  ),
                  onPressed: () {
                    showCustomDialog(context, "Add New Supplier",
                        addNewSupplier(1), 30, 400);
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
          GetBuilder<IngredientController>(
              id: "changeCustomTabBar",
              builder: (context) {
                return Expanded(
                  flex: 1,
                  child: MaterialSegmentedControl(
                    children: {
                      0: Text(
                        'Ingredient',
                        style: TextStyle(
                            color:
                                _currentSelection == 0 ? white : Colors.black),
                      ),
                      1: Text(
                        'Category',
                        style: TextStyle(
                            color:
                                _currentSelection == 1 ? white : Colors.black),
                      ),
                      2: Text(
                        'Unit',
                        style: TextStyle(
                            color:
                                _currentSelection == 2 ? white : Colors.black),
                      ),
                      3: Text(
                        'Supplier',
                        style: TextStyle(
                            color:
                                _currentSelection == 3 ? white : Colors.black),
                      ),
                    },
                    selectionIndex: _currentSelection,
                    borderColor: Colors.grey,
                    selectedColor: primaryColor,
                    unselectedColor: Colors.white,
                    borderRadius: 32.0,
                    // disabledChildren: [
                    //   6,
                    // ],
                    onSegmentChosen: (index) {
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
                            _ingredientController.searchText = text;
                            if (_currentSelection == 0) {
                              const duration = Duration(seconds: 1);
                              if (stopOnSearch != null) {
                                stopOnSearch?.cancel();
                              }
                              stopOnSearch = Timer(
                                  duration,
                                  () => _ingredientController
                                      .getIngredientByKeyword(
                                          keyword: text, showLoading: false));
                            } else if (_currentSelection == 1) {
                              const duration = Duration(seconds: 1);
                              if (stopOnSearch != null) {
                                stopOnSearch?.cancel();
                              }
                              stopOnSearch = Timer(
                                  duration,
                                  () => _ingredientController
                                      .getIngredientCategoryByKeyword(
                                          keyword: text, showLoading: false));
                            } else if (_currentSelection == 2) {
                              const duration = Duration(seconds: 1);
                              if (stopOnSearch != null) {
                                stopOnSearch?.cancel();
                              }
                              stopOnSearch = Timer(
                                  duration,
                                  () => _ingredientController
                                      .getIngredientUnitByKeyword(
                                          keyword: text, showLoading: false));
                            } else if (_currentSelection == 3) {
                              const duration = Duration(seconds: 1);
                              if (stopOnSearch != null) {
                                stopOnSearch?.cancel();
                              }
                              stopOnSearch = Timer(
                                  duration,
                                  () => _ingredientController
                                      .getIngredientSupplierByKeyword(
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
                                  _ingredientController.searchText = '';
                                  if (_currentSelection == 0) {
                                    setState(() {
                                      textController.text = '';
                                      _ingredientController
                                          .getIngredientByKeyword();
                                    });
                                  } else if (_currentSelection == 1) {
                                    setState(() {
                                      textController.text = '';
                                      _ingredientController
                                          .getIngredientCategoryByKeyword();
                                    });
                                  } else if (_currentSelection == 2) {
                                    setState(() {
                                      textController.text = '';
                                      _ingredientController
                                          .getIngredientUnitByKeyword();
                                    });
                                  } else if (_currentSelection == 3) {
                                    setState(() {
                                      textController.text = '';
                                      _ingredientController
                                          .getIngredientSupplierByKeyword();
                                    });
                                  }
                                },
                                icon: Icon(Icons.close, color: textSecondary)),
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
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget addIngrediant(dynamic itemId) {
    return Container(
      height: Size.infinite.height,
      width: Size.infinite.width,
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
      child: Form(
        key: _ingredientController.addIngredintFormKey,
        child: ListView(children: [
          textRow('Name', 'Purchase Price'),
          textFieldRow('Enter Ingrediant name', 'Enter Purchase price',
              controller1: _ingredientController.addIngrediantNameCtlr,
              controller2: _ingredientController.addIngredientPriceCtlr,
              validator1: _ingredientController.textValidator,
              validator2: _ingredientController.textValidator,
              textInputType1: TextInputType.text,
              textInputType2: TextInputType.number),
          const SizedBox(height: 10),
          textRow('Code', 'Alert Qty'),
          textFieldRow('Enter Code', 'Enter Alert Qty',
              controller1: _ingredientController.addIngredintCodeCtlr,
              controller2: _ingredientController.addIngredintQtyCtlr,
              validator1: _ingredientController.textValidator,
              validator2: _ingredientController.textValidator,
              textInputType1: TextInputType.number,
              textInputType2: TextInputType.number),
          const SizedBox(height: 10),
          textRow('Select Category', 'Select Unit'),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  flex: 1,
                  child:
                      GetBuilder<IngredientController>(builder: (controller) {
                    return MultiSelectDropDown(
                      backgroundColor: secondaryBackground,
                      optionsBackgroundColor: secondaryBackground,
                      selectedOptionTextColor: primaryText,
                      selectedOptionBackgroundColor: primaryColor,
                      optionTextStyle:
                          TextStyle(color: primaryText, fontSize: 16),
                      onOptionSelected: (List<ValueItem> selectedOptions) {
                        controller.addIngredintCatgoryList = selectedOptions
                            .map((ValueItem e) => int.parse(e.value!))
                            .toList();
                        print(controller.addIngredintCatgoryList);
                      },
                      options: _ingredientController
                          .ingredientCategoryData.value.data
                          .map((IngrediantCategory e) {
                        return ValueItem(
                          label: e.name,
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
                  })),
              const SizedBox(width: 20),
              Expanded(
                  flex: 1,
                  child:
                      GetBuilder<IngredientController>(builder: (controller) {
                    return MultiSelectDropDown(
                      backgroundColor: secondaryBackground,
                      optionsBackgroundColor: secondaryBackground,
                      selectedOptionTextColor: primaryText,
                      selectedOptionBackgroundColor: primaryColor,
                      optionTextStyle:
                          TextStyle(color: primaryText, fontSize: 16),
                      onOptionSelected: (List<ValueItem> selectedOptions) {
                        controller.addIngredintUnitList = selectedOptions
                            .map((ValueItem e) => int.parse(e.value!))
                            .toList();
                        print(controller.addIngredintUnitList);
                      },
                      options: _ingredientController
                          .ingredientUnitData.value.data
                          .map((IngrediantUnit e) {
                        return ValueItem(
                          label: e.name,
                          value: e.id.toString(),
                        );
                      }).toList(),
                      hint: 'Select Unit',
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
                  })),
            ],
          ),
          const SizedBox(height: 10),
          Container(
              height: 40,
              width: 50,
              alignment: Alignment.bottomRight,
              child: normalButton('Submit', primaryColor, white,
                  onPressed: () async {
                if (_ingredientController.addIngredintFormKey.currentState!
                    .validate()) {
                  _ingredientController.haveMoreIngredient = true;
                  _ingredientController.ingredientPageNumber = 1;
                  _ingredientController
                      .addAndUpdateIngrediant(
                    true,
                    _ingredientController.addIngrediantNameCtlr.text,
                    _ingredientController.addIngredientPriceCtlr.text,
                    _ingredientController.addIngredintCodeCtlr.text,
                    _ingredientController.addIngredintQtyCtlr.text,
                    _ingredientController.addIngredintCatgoryList.first,
                    _ingredientController.addIngredintUnitList.first,
                  )
                      .then((value) {
                    _ingredientController.addIngredintQtyCtlr.clear();
                    _ingredientController.addIngredintCodeCtlr.clear();
                    _ingredientController.addIngredientPriceCtlr.clear();
                    _ingredientController.addIngrediantNameCtlr.clear();
                    _ingredientController.addIngredintCatgoryList.clear();
                    _ingredientController.addIngredintUnitList.clear();
                    if (Navigator.of(context).canPop()) {
                      Navigator.pop(context);
                    }
                  });
                }
              })),
        ]),
      ),
    );
  }

  Widget updateIngrediant(dynamic itemId) {
    return Container(
      height: Size.infinite.height,
      width: Size.infinite.width,
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
      child: Form(
        key: _ingredientController.updateIngredintFormKey,
        child: ListView(children: [
          textRow('Name', 'Purchase Price'),
          textFieldRow(
            'Enter Ingredient name',
            'Enter Purchase price',
            controller1: _ingredientController.updateIngrediantNameCtlr,
            controller2: _ingredientController.updateIngredientPriceCtlr,
            validator1: _ingredientController.textValidator,
            validator2: _ingredientController.textValidator,
            textInputType1: TextInputType.text,
            textInputType2: TextInputType.number,
          ),
          const SizedBox(height: 10),
          textRow('Code', 'Alert Qty'),
          textFieldRow(
            'Enter Code',
            'Enter Alert Qty',
            controller1: _ingredientController.updateIngredintCodeCtlr,
            controller2: _ingredientController.updateIngredintAlertQtyCtlr,
            validator1: _ingredientController.textValidator,
            validator2: _ingredientController.textValidator,
            textInputType1: TextInputType.number,
            textInputType2: TextInputType.number,
          ),
          const SizedBox(height: 10),
          textRow('Select Category', 'Select Unit'),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  flex: 1,
                  child:
                      GetBuilder<IngredientController>(builder: (controller) {
                    return MultiSelectDropDown(
                      backgroundColor: secondaryBackground,
                      optionsBackgroundColor: secondaryBackground,
                      selectedOptionTextColor: primaryText,
                      selectedOptionBackgroundColor: primaryColor,
                      optionTextStyle:
                          TextStyle(color: primaryText, fontSize: 16),
                      onOptionSelected: (List<ValueItem> selectedOptions) {
                        controller.updateIngredientCatgoryList = selectedOptions
                            .map((ValueItem e) => int.parse(e.value!))
                            .toList();
                      },
                      selectedOptions:
                          controller.ingredientData.value.data!.map((e) {
                        return ValueItem(
                          label: _ingredientController.ingredientData.value.data
                              ?.firstWhere((element) => element.id == itemId)
                              .categoryName,
                          value: _ingredientController.ingredientData.value.data
                              ?.firstWhere((element) => element.id == itemId)
                              .id
                              .toString(),
                        );
                      }).toList(),
                      options: _ingredientController
                          .ingredientCategoryData.value.data
                          .map((IngrediantCategory e) {
                        return ValueItem(
                          label: e.name,
                          value: e.id.toString(),
                        );
                      }).toList(),
                      hint: controller.ingredientData.value.data
                          ?.firstWhere((element) => element.id == itemId)
                          .categoryName,
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
                  })),
              const SizedBox(width: 20),
              Expanded(
                  flex: 1,
                  child:
                      GetBuilder<IngredientController>(builder: (controller) {
                    return MultiSelectDropDown(
                      backgroundColor: secondaryBackground,
                      optionsBackgroundColor: secondaryBackground,
                      selectedOptionTextColor: primaryText,
                      selectedOptionBackgroundColor: primaryColor,
                      optionTextStyle:
                          TextStyle(color: primaryText, fontSize: 16),
                      onOptionSelected: (List<ValueItem> selectedOptions) {
                        controller.updateIngredientUnitList = selectedOptions
                            .map((ValueItem e) => int.parse(e.value!))
                            .toList();
                      },
                      selectedOptions:
                          controller.ingredientData.value.data!.map((e) {
                        return ValueItem(
                          label: _ingredientController.ingredientData.value.data
                              ?.firstWhere((element) => element.id == itemId)
                              .unitName,
                          value: _ingredientController.ingredientData.value.data
                              ?.firstWhere((element) => element.id == itemId)
                              .id
                              .toString(),
                        );
                      }).toList(),
                      options: _ingredientController
                          .ingredientUnitData.value.data
                          .map((IngrediantUnit e) {
                        return ValueItem(
                          label: e.name,
                          value: e.id.toString(),
                        );
                      }).toList(),
                      hint: controller.ingredientData.value.data
                          ?.firstWhere((element) => element.id == itemId)
                          .unitName,
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
                  })),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 40,
            width: 50,
            alignment: Alignment.bottomRight,
            child: normalButton('Submit', primaryColor, white,
                onPressed: () async {
              if (_ingredientController.updateIngredintFormKey.currentState!
                  .validate()) {
                _ingredientController.haveMoreIngredient = true;
                _ingredientController.ingredientPageNumber = 1;
                _ingredientController
                    .addAndUpdateIngrediant(
                  false,
                  _ingredientController.updateIngrediantNameCtlr.text,
                  _ingredientController.updateIngredientPriceCtlr.text,
                  _ingredientController.updateIngredintCodeCtlr.text,
                  _ingredientController.updateIngredintAlertQtyCtlr.text,
                  _ingredientController.updateIngredientCatgoryList.first,
                  _ingredientController.updateIngredientUnitList.first,
                  id: itemId.toString(),
                )
                    .then((value) {
                  _ingredientController.addIngredintQtyCtlr.clear();
                  _ingredientController.addIngredintCodeCtlr.clear();
                  _ingredientController.addIngredientPriceCtlr.clear();
                  _ingredientController.addIngrediantNameCtlr.clear();
                  if (Navigator.of(context).canPop()) {
                    Navigator.pop(context);
                  }
                });
              }
            }),
          ),
        ]),
      ),
    );
  }

  Widget addIngredientcategory(dynamic itemId) {
    return Container(
      height: Size.infinite.height,
      width: Size.infinite.width,
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
      child: ListView(children: [
        textRow('Name', ''),
        textFieldRow(
          'Enter Name',
          '',
          controller1: _ingredientController.ingredientCategoryNameCtlr,
          validator1: _ingredientController.textValidator,
          textInputType1: TextInputType.text,
          showOne: true,
        ),
        const SizedBox(height: 10),
        Container(
          height: 40,
          width: 50,
          alignment: Alignment.bottomRight,
          child: normalButton(
            'Submit',
            primaryColor,
            white,
            onPressed: () async {
              _ingredientController.haveMoreCategory = true;
              _ingredientController.categoryPageNumber = 1;
              _ingredientController
                  .addAndUpdateIngrediantCategory(
                true,
                _ingredientController.ingredientCategoryNameCtlr.text,
              )
                  .then((value) {
                _ingredientController.ingredientCategoryNameCtlr.clear();
                if (Navigator.of(context).canPop()) {
                  Navigator.pop(context);
                }
              });
            },
          ),
        ),
      ]),
    );
  }

  Widget addNewUnit(dynamic itemId) {
    return Container(
        height: Size.infinite.height,
        width: Size.infinite.width,
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
        child: ListView(
          children: [
            textRow('Name', 'Description'),
            textFieldRow(
              'Enter Unit Name',
              'Enter Description',
              controller1: _ingredientController.ingredientUnitNameCtlr,
              controller2: _ingredientController.ingredientUnitDescriptionCtlr,
              validator1: _ingredientController.textValidator,
              validator2: _ingredientController.textValidator,
              textInputType1: TextInputType.text,
              textInputType2: TextInputType.text,
            ),
            const SizedBox(height: 10),
            Container(
              height: 40,
              width: 50,
              alignment: Alignment.bottomRight,
              child: normalButton(
                'Submit',
                primaryColor,
                white,
                onPressed: () async {
                  _ingredientController.haveMoreUnit = true;
                  _ingredientController.unitPageNumber = 1;
                  _ingredientController
                      .addAndUpdateIngrediantUnit(
                    true,
                    _ingredientController.ingredientUnitNameCtlr.text,
                    _ingredientController.ingredientUnitDescriptionCtlr.text,
                    true,
                  )
                      .then((value) {
                    _ingredientController.ingredientUnitNameCtlr.clear();
                    _ingredientController.ingredientUnitDescriptionCtlr.clear();
                    if (Navigator.of(context).canPop()) {
                      Navigator.pop(context);
                    }
                  });
                },
              ),
            ),
          ],
        ));
  }

  Widget addNewSupplier(dynamic itemId) {
    return Container(
        height: Size.infinite.height,
        width: Size.infinite.width,
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
        child: Form(
          key: _ingredientController.addIngredintSupplierFormKey,
          child: ListView(
            children: [
              textRow('Name', 'Email'),
              textFieldRow(
                'Enter Supplier name',
                'Enter Supplier Email',
                controller1:
                    _ingredientController.addIngrediantSupplierNameCtlr,
                controller2:
                    _ingredientController.addIngredientSupplierEmailCtlr,
                validator1: _ingredientController.textValidator,
                validator2: _ingredientController.textValidator,
                textInputType1: TextInputType.text,
                textInputType2: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              textRow('Phone', 'Reference'),
              textFieldRow(
                'Enter Phone',
                'Enter Reference',
                controller1:
                    _ingredientController.addIngredintSupplierPhoneCtlr,
                controller2: _ingredientController.addIngredintSupplierRefCtlr,
                validator1: _ingredientController.textValidator,
                validator2: _ingredientController.textValidator,
                textInputType1: TextInputType.number,
                textInputType2: TextInputType.number,
              ),
              const SizedBox(height: 10),
              textRow('Address', ''),
              textFieldRow(
                'Enter Address',
                '',
                controller1:
                    _ingredientController.addIngredintSupplierAddressCtlr,
                validator1: _ingredientController.textValidator,
                textInputType1: TextInputType.text,
                showOne: true,
              ),
              const SizedBox(height: 10),
              textRow('ID Card Front', 'ID Card Back'),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 40,
                    width: 400,
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.cloud_upload_outlined,
                        color: primaryColor,
                      ),
                      label:
                          GetBuilder<IngredientController>(builder: (context) {
                        return Text(
                          _ingredientController.idCardFront == null
                              ? "Upload Image"
                              : _ingredientController.idCardFront!.path,
                          style: TextStyle(
                              color: textSecondary, fontSize: fontSmall),
                        );
                      }),
                      onPressed: () async {
                        _ingredientController.idCardFront =
                            await _ingredientController.getIdCardImage();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: primaryBackground,
                        side: BorderSide(width: 1.0, color: textSecondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 400,
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.cloud_upload_outlined,
                        color: primaryColor,
                      ),
                      label:
                          GetBuilder<IngredientController>(builder: (context) {
                        return Text(
                          _ingredientController.idCardBack == null
                              ? "Upload Image"
                              : _ingredientController.idCardBack!.path,
                          style: TextStyle(
                              color: textSecondary, fontSize: fontSmall),
                        );
                      }),
                      onPressed: () async {
                        _ingredientController.idCardBack =
                            await _ingredientController.getIdCardImage();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: primaryBackground,
                        side: BorderSide(width: 1.0, color: textSecondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                  height: 40,
                  width: 50,
                  alignment: Alignment.bottomRight,
                  child: normalButton('Submit', primaryColor, white,
                      onPressed: () async {
                    if (_ingredientController
                        .addIngredintSupplierFormKey.currentState!
                        .validate()) {
                      _ingredientController.haveMoreSupplier = true;
                      _ingredientController.supplierPageNumber = 1;
                      _ingredientController
                          .addSupplierMethod(
                        _ingredientController
                            .addIngrediantSupplierNameCtlr.text,
                        _ingredientController
                            .addIngredientSupplierEmailCtlr.text,
                        _ingredientController
                            .addIngredintSupplierPhoneCtlr.text,
                        _ingredientController.addIngredintSupplierRefCtlr.text,
                        _ingredientController
                            .addIngredintSupplierAddressCtlr.text,
                        1.toString(),
                        _ingredientController.idCardFront,
                        _ingredientController.idCardBack,
                      )
                          .then((value) {
                        _ingredientController.addIngrediantSupplierNameCtlr
                            .clear();
                        _ingredientController.addIngredientSupplierEmailCtlr
                            .clear();
                        _ingredientController.addIngredintSupplierPhoneCtlr
                            .clear();
                        _ingredientController.addIngredintSupplierRefCtlr
                            .clear();
                        _ingredientController.addIngredintSupplierAddressCtlr
                            .clear();
                        _ingredientController.idCardFront = null;
                        _ingredientController.idCardBack = null;
                        if (Navigator.of(context).canPop()) {
                          Navigator.pop(context);
                        }
                      });
                    } else {
                      print('Not Validate form!!');
                    }
                  })),
            ],
          ),
        ));
  }

  Widget updateSupplier(dynamic itemId) {
    return Container(
      height: Size.infinite.height,
      width: Size.infinite.width,
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
      child: Form(
        key: _ingredientController.updateSupplierFormKey,
        child: ListView(children: [
          textRow('Name', 'Email'),
          textFieldRow('Enter Ingredient name', 'Enter Email',
              controller1: _ingredientController.updateSupplierNameCtlr,
              controller2: _ingredientController.updateSupplierEmailCtlr,
              validator1: _ingredientController.textValidator,
              validator2: _ingredientController.textValidator,
              textInputType1: TextInputType.text,
              textInputType2: TextInputType.text),
          const SizedBox(height: 10),
          textRow('Phone', 'Reference'),
          textFieldRow('Enter Phone', 'Enter Reference',
              controller1: _ingredientController.updateSupplierPhoneCtlr,
              controller2: _ingredientController.updateSupplierRefCtlr,
              validator1: _ingredientController.textValidator,
              validator2: _ingredientController.textValidator,
              textInputType1: TextInputType.number,
              textInputType2: TextInputType.number),
          const SizedBox(height: 10),
          textRow('Address', ''),
          textFieldRow(
            'Enter Address',
            '',
            controller1: _ingredientController.updateSupplierAddressCtlr,
            // controller2: _ingredientController.addIngredintSupplierStatusCtlr,
            validator1: _ingredientController.textValidator,
            textInputType1: TextInputType.text,
            showOne: true,
          ),
          const SizedBox(height: 10),
          textRow('ID Card Front', 'ID Card Back'),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 40,
                width: 400,
                child: OutlinedButton.icon(
                  icon: const Icon(
                    Icons.cloud_upload_outlined,
                    color: primaryColor,
                  ),
                  label: GetBuilder<IngredientController>(builder: (context) {
                    return Text(
                      _ingredientController.idCardFront == null
                          ? "Upload Image"
                          : _ingredientController.idCardFront!.path,
                      style:
                          TextStyle(color: textSecondary, fontSize: fontSmall),
                    );
                  }),
                  onPressed: () async {
                    _ingredientController.idCardFront =
                        await _ingredientController.getIdCardImage();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: primaryBackground,
                    side: BorderSide(width: 1.0, color: textSecondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                width: 400,
                child: OutlinedButton.icon(
                  icon: const Icon(
                    Icons.cloud_upload_outlined,
                    color: primaryColor,
                  ),
                  label: GetBuilder<IngredientController>(builder: (context) {
                    return Text(
                      _ingredientController.idCardBack == null
                          ? "Upload Image"
                          : _ingredientController.idCardBack!.path,
                      style:
                          TextStyle(color: textSecondary, fontSize: fontSmall),
                    );
                  }),
                  onPressed: () async {
                    _ingredientController.idCardBack =
                        await _ingredientController.getIdCardImage();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: primaryBackground,
                    side: BorderSide(width: 1.0, color: textSecondary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            height: 40,
            width: 50,
            alignment: Alignment.bottomRight,
            child: normalButton('Submit', primaryColor, white,
                onPressed: () async {
              if (_ingredientController.updateSupplierFormKey.currentState!
                  .validate()) {
                _ingredientController.supplierPageNumber = 1;
                _ingredientController.haveMoreSupplier = true;
                _ingredientController
                    .updateSupplierMethod(
                        _ingredientController.updateSupplierNameCtlr.text,
                        _ingredientController.updateSupplierEmailCtlr.text,
                        _ingredientController.updateSupplierPhoneCtlr.text,
                        _ingredientController.updateSupplierRefCtlr.text,
                        _ingredientController.updateSupplierAddressCtlr.text,
                        1.toString(),
                        // _ingredientController.idCardFront,
                        // _ingredientController.idCardBack,
                        id: itemId)
                    .then((value) {
                  if (Navigator.of(context).canPop()) {
                    Navigator.pop(context);
                  }
                });
              }
            }),
          ),
        ]),
      ),
    );
  }

  Widget viewSupplierDetails() {
    return Container(
        padding: const EdgeInsets.only(left: 30, right: 30),
        child: ListView(
          children: [
            SizedBox(
              height: 60,
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                        child: Text(
                          'Name:',
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
                          _ingredientController
                              .ingredientSupplierSingleItem.value.data!.name,
                          //foodCtlr.foodSingleItemDetails.value.data!.name!,
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
                          'Email:',
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
                          _ingredientController
                              .ingredientSupplierSingleItem.value.data!.email,
                          //foodCtlr.foodSingleItemDetails.value.data!.name!,
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
                          'Phone:',
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
                          _ingredientController
                              .ingredientSupplierSingleItem.value.data!.phone,
                          //foodCtlr.foodSingleItemDetails.value.data!.name!,
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
                          'Reference:',
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
                          _ingredientController.ingredientSupplierSingleItem
                              .value.data!.reference,
                          //foodCtlr.foodSingleItemDetails.value.data!.name!,
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
                          'Address:',
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
                          _ingredientController
                              .ingredientSupplierSingleItem.value.data!.address,
                          //foodCtlr.foodSingleItemDetails.value.data!.name!,
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
                          _ingredientController
                              .ingredientSupplierSingleItem.value.data!.status
                              .toString(),
                          //foodCtlr.foodSingleItemDetails.value.data!.name!,
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
              height: 200,
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                        child: Text(
                          'Front Image:',
                          style: TextStyle(
                              fontSize: fontVerySmall,
                              color: primaryText,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                  Expanded(
                      flex: 7,
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: Image.network(
                          _ingredientController.ingredientSupplierSingleItem
                              .value.data!.idCardFront,
                          height: 200,
                          width: 200,
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 50),
            SizedBox(
              height: 200,
              child: Row(
                children: [
                  Expanded(
                      flex: 3,
                      child: Container(
                        child: Text(
                          'Back Image:',
                          style: TextStyle(
                              fontSize: fontVerySmall,
                              color: primaryText,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                  Expanded(
                      flex: 7,
                      child: Container(
                        alignment: Alignment.topLeft,
                        child: Image.network(
                          _ingredientController.ingredientSupplierSingleItem
                              .value.data!.idCardBack,
                          height: 200,
                          width: 200,
                        ),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ));
  }
}
