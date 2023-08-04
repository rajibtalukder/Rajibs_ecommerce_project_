import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:klio_staff/mvc/controller/Ingredient_management_controller.dart';
import 'package:klio_staff/mvc/controller/food_management_controller.dart';
import 'package:klio_staff/mvc/controller/production_controller.dart';
import 'package:klio_staff/mvc/model/Ingredient_list_model.dart';
import 'package:klio_staff/mvc/model/single_production_unit.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';

import '../../../constant/color.dart';
import '../../../constant/value.dart';
import '../../../utils/utils.dart';
import '../../model/food_menu_management.dart';
import '../../model/production_unit_item_model.dart';
import '../dialog/custom_dialog.dart';
import '../widget/custom_widget.dart';

class ProductionMangement extends StatefulWidget {
  const ProductionMangement({Key? key}) : super(key: key);

  @override
  State<ProductionMangement> createState() => _ProductionMangementState();
}

class _ProductionMangementState extends State<ProductionMangement> {
  final ProductionController _controller = Get.put(ProductionController());
  IngredientController ingredientController = Get.put(IngredientController());

  TextEditingController qtyCtlr = TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: [
                itemHeaderTitle(),
                Expanded(
                  child: productionDataTable(),
                ),
              ],
            )));
  }

  itemHeaderTitle() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Text(
              'Production Unit',
              style: TextStyle(fontSize: fontBig, color: primaryText),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 25),
            child: Row(
              children: [
                OutlinedButton.icon(
                  icon: Icon(
                    Icons.add,
                    color: primaryText,
                  ),
                  label: Text(
                    "Add Production Unit",
                    style: TextStyle(
                      color: primaryText,
                    ),
                  ),
                  onPressed: () {
                    showCustomDialog(context, "Set Production Cost Per Unit",
                        addProductionUnit(context, false), 30, 200);
                  },
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(width: 1.0, color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  productionDataTable() {
    return SizedBox(
      width: double.infinity,
      child: Card(
          color: secondaryBackground,
          child: SingleChildScrollView(
            child: GetBuilder<ProductionController>(
                id: 'productionListUpdate',
                builder: (prodController) {
                  if (prodController.productionUnit.value.data.isEmpty) {
                    return Center(
                        child: Container(
                            height: 40,
                            width: 40,
                            margin: EdgeInsets.only(
                                top: MediaQuery.of(context).size.height * 0.3),
                            child: const CircularProgressIndicator()));
                  }
                  return DataTable(
                      dataRowHeight: 70,
                      columns: [
                        DataColumn(
                          label: Text(
                            'SL NO',
                            style: TextStyle(color: textSecondary),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Menu Name',
                            style: TextStyle(color: textSecondary),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Variant Name',
                            style: TextStyle(color: textSecondary),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Price',
                            style: TextStyle(color: textSecondary),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Action',
                            style: TextStyle(color: textSecondary),
                          ),
                        )
                      ],
                      rows: prodController.productionUnit.value.data.reversed
                          .map((item) => DataRow(cells: [
                                DataCell(Text(
                                  '${prodController.productionUnit.value.data.indexWhere((element) => element == item) + 1}',
                                  style: TextStyle(color: primaryText),
                                )),
                                DataCell(Text(
                                  item.foodName,
                                  style: TextStyle(color: primaryText),
                                )),
                                DataCell(Text(
                                  item.variantName,
                                  style: TextStyle(color: primaryText),
                                )),
                                DataCell(Text(
                                  item.price,
                                  style: TextStyle(color: primaryText),
                                )),
                                DataCell(
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffFFE7E6),
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                        child: GestureDetector(
                                          onTap: () async {
                                            await _controller
                                                .getSingleProductionUnit(
                                                    id: item.id)
                                                .then((value) {
                                              showCustomDialog(
                                                  context,
                                                  "View Production Cost Per Unit",
                                                  viewProductionUnit(),
                                                  30,
                                                  200);
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
                                      const SizedBox(width: 15),
                                      Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffFFE7E6),
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                        child: GestureDetector(
                                          onTap: () async {
                                            Utils.showLoading();
                                            await _controller
                                                .getSingleProductionUnit(
                                                    id: item.id);
                                            Data? data = _controller
                                                .singleProductionUnit
                                                .value
                                                .data;
                                            if (data == null) {
                                              Utils.hidePopup();
                                              Utils.showSnackBar(
                                                  "Can not get Data");
                                              return;
                                            }
                                            try {
                                              _controller.clearProduction();
                                              _controller.foodId.value =
                                                  data.food.id;
                                              _controller.getVariantName(
                                                  id: _controller.foodId.value);
                                              _controller.variantId.value =
                                                  data.variant.id;
                                              for (var e in data.items.data) {
                                                var temp = ingredientController
                                                    .ingredientData.value.data
                                                    ?.firstWhere((element) =>
                                                        element.id ==
                                                        e.ingredient.id);
                                                _controller.productionItem.add(
                                                  ProductionUnitItemModel(
                                                    sl: e.ingredient.id
                                                        .toString(),
                                                    price:
                                                        double.parse(e.price),
                                                    unit: e.unit,
                                                    qty: e.quantity,
                                                    itemInfo: temp!,
                                                    id: e.id.toString(),
                                                  ),
                                                );
                                              }
                                              Utils.hidePopup();
                                            } catch (e) {
                                              Utils.hidePopup();
                                              Utils.showSnackBar(
                                                  "This Item do not have all the required fields");
                                              return;
                                            }
                                            showCustomDialog(
                                                    context,
                                                    "Update Production Cost Per Unit",
                                                    addProductionUnit(
                                                        context, true,
                                                        id: item.id.toString()),
                                                    30,
                                                    200)
                                                .then((value) => _controller
                                                    .clearProduction());
                                          },
                                          child: Image.asset(
                                            "assets/edit-alt.png",
                                            height: 15,
                                            width: 15,
                                            color: const Color(0xffED7402),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 15),
                                      Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffFFE7E6),
                                          borderRadius:
                                              BorderRadius.circular(25.0),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            showWarningDialog(
                                                'Are you sure to Delete',
                                                onAccept: () async {
                                              Get.back();
                                              await _controller
                                                  .deleteProductionUnitData(
                                                      id: item.id);
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
                              ]))
                          .toList());
                }),
          )),
    );
  }

  Widget addProductionUnit(BuildContext context, bool isUpdate, {String? id}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.update(["refreshAddProduction"]);
    });
    return GetBuilder<ProductionController>(
        id: 'refreshAddProduction',
        builder: (getContext) {
          return Container(
            height: Size.infinite.height,
            width: Size.infinite.width,
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  textRow("Menu Name", "Variant Name"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          flex: 1,
                          child: GetBuilder<FoodManagementController>(
                            builder: (controller) {
                              FoodMenuManagementDatum? menuName = controller
                                  .menusData.value.data
                                  ?.firstWhereOrNull((element) =>
                                      element.id == _controller.foodId.value);
                              return MultiSelectDropDown(
                                backgroundColor: secondaryBackground,
                                optionsBackgroundColor: secondaryBackground,
                                selectedOptionTextColor: primaryText,
                                selectedOptionBackgroundColor: primaryColor,
                                optionTextStyle:
                                    TextStyle(color: primaryText, fontSize: 16),
                                onOptionSelected:
                                    (List<ValueItem> selectedOptions) {
                                  controller.selectMenuItem = selectedOptions
                                      .map((ValueItem e) => int.parse(e.value!))
                                      .toList();
                                  _controller.getVariantName(
                                      id: controller.selectMenuItem.first);
                                  _controller.foodId.value =
                                      controller.selectMenuItem.first;
                                },
                                options: controller.menusData.value.data!
                                    .map((FoodMenuManagementDatum e) {
                                  return ValueItem(
                                    label: e.name ?? '',
                                    value: e.id.toString(),
                                  );
                                }).toList(),
                                hint: 'Select Menu',
                                hintColor: primaryText,
                                selectionType: SelectionType.single,
                                chipConfig:
                                    const ChipConfig(wrapType: WrapType.wrap),
                                dropdownHeight: 300,
                                selectedOptionIcon:
                                    const Icon(Icons.check_circle),
                                selectedOptions: [
                                  if (menuName != null)
                                    ValueItem(
                                      label: menuName.name ?? "",
                                      value: menuName.id.toString(),
                                    )
                                ],
                                inputDecoration: BoxDecoration(
                                  color: secondaryBackground,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(6)),
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
                          child: GetBuilder<ProductionController>(
                            id: 'variantName',
                            builder: (controller) {
                              // VariantNameModel? vrntName = _controller
                              //     .variantName.firstWhereOrNull((element) =>
                              // element.id == _controller.variantId.value);
                              return MultiSelectDropDown(
                                backgroundColor: secondaryBackground,
                                optionsBackgroundColor: secondaryBackground,
                                selectedOptionTextColor: primaryText,
                                selectedOptionBackgroundColor: primaryColor,
                                optionTextStyle:
                                    TextStyle(color: primaryText, fontSize: 16),
                                onOptionSelected:
                                    (List<ValueItem> selectedOptions) {
                                  _controller.variantId.value = int.parse(
                                      selectedOptions.single.value.toString());
                                },
                                options: controller.variantName
                                    .map((e) => ValueItem(
                                          label: e.name.toString(),
                                          value: e.id.toString(),
                                        ))
                                    .toList(),
                                hint: 'Select Variant',
                                hintColor: primaryText,
                                selectionType: SelectionType.single,
                                selectedOptions: [
                                  ValueItem(
                                      label: _controller.singleProductionUnit
                                              .value.data?.variant.name ??
                                          "",
                                      value: _controller.singleProductionUnit
                                              .value.data?.variant.id
                                              .toString() ??
                                          "")
                                ],
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
                                    color: alternate,
                                  ),
                                ),
                              );
                            },
                          )),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        _controller.productionItem.add(ProductionUnitItemModel(
                          sl: (_controller.productionItem.length + 1)
                              .toString(),
                          itemInfo: Ingrediant(),
                          qty: 1,
                          unit: ' No data',
                          price: 00,
                          id: '',
                        ));
                        _controller.update(['prodItemId']);
                      },
                      child: Container(
                        height: 40,
                        width: 170,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                            child: Text('Add more item',
                                style: TextStyle(color: white, fontSize: 16))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: GetBuilder<ProductionController>(
                        id: 'prodItemId',
                        builder: (context) {
                          return DataTable(
                            border: TableBorder(
                                borderRadius: BorderRadius.circular(10)),
                            dataRowHeight: 70,
                            columns: [
                              DataColumn(
                                label: Text(
                                  'SL',
                                  style: TextStyle(color: textSecondary),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Info Item',
                                  style: TextStyle(color: textSecondary),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Qty',
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
                                  'Price',
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
                            rows: _controller.productionItem.map((e) {
                              return DataRow(cells: [
                                DataCell(
                                  Text(
                                    e.sl,
                                    style: TextStyle(color: primaryText),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 200,
                                    child: GetBuilder<IngredientController>(
                                      builder: (controller) {
                                        return MultiSelectDropDown(
                                          backgroundColor: secondaryBackground,
                                          optionsBackgroundColor:
                                              secondaryBackground,
                                          selectedOptionTextColor: primaryText,
                                          selectedOptionBackgroundColor:
                                              primaryColor,
                                          showClearIcon: false,
                                          optionTextStyle: TextStyle(
                                              color: primaryText, fontSize: 16),
                                          onOptionSelected: (List<ValueItem>
                                              selectedOptions) {
                                            var temp = controller
                                                .ingredientData.value.data
                                                ?.firstWhere((element) =>
                                                    element.id ==
                                                    int.parse(selectedOptions
                                                            .first.value ??
                                                        ''));
                                            if (temp == null) return;
                                            e.itemInfo = temp;
                                            e.unit = temp.unitName;
                                            e.price = double.parse(
                                                temp.purchasePrice);
                                            _controller.update(['prodItemId']);
                                            _controller
                                                .update(['updateIngredient']);
                                          },
                                          options: controller
                                              .ingredientData.value.data!
                                              .map((e) {
                                            return ValueItem(
                                              label:
                                                  '${e.name} (${e.unitName})',
                                              value: e.id.toString(),
                                            );
                                          }).toList(),
                                          hint: 'Select Ingredient',
                                          hintColor: primaryText,
                                          selectionType: SelectionType.single,
                                          chipConfig: const ChipConfig(
                                              wrapType: WrapType.wrap),
                                          dropdownHeight: 300,
                                          selectedOptionIcon:
                                              const Icon(Icons.check_circle),
                                          selectedOptions: [
                                            ValueItem(
                                                label:
                                                    e.itemInfo.name.toString(),
                                                value: e.itemInfo.id.toString())
                                          ],
                                          inputDecoration: BoxDecoration(
                                            color: secondaryBackground,
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(6)),
                                            border: Border.all(
                                              color: alternate,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                DataCell(
                                  TextFormField(
                                    onChanged: (value) {
                                      if (value.isEmpty) {
                                        value = "0";
                                      }
                                      e.qty = int.parse(value);

                                      e.price = e.qty *
                                          double.parse(
                                              e.itemInfo.purchasePrice);
                                      _controller.update(['calculationUpdate']);
                                      _controller.update(['priceUpdate']);
                                    },
                                    keyboardType: TextInputType.number,
                                    maxLines: 1,
                                    initialValue: e.qty.toString(),
                                    style: TextStyle(
                                        fontSize: fontVerySmall,
                                        color: primaryText),
                                    decoration: InputDecoration(
                                      fillColor: secondaryBackground,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: textSecondary
                                                  .withOpacity(0.4))),
                                      hintStyle: TextStyle(
                                          fontSize: fontVerySmall,
                                          color: primaryText),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    e.unit,
                                    style: TextStyle(color: primaryText),
                                  ),
                                ),
                                DataCell(
                                  GetBuilder<ProductionController>(
                                      id: 'priceUpdate',
                                      builder: (context) {
                                        return Text(
                                          e.price.toString(),
                                          style: TextStyle(color: primaryText),
                                        );
                                      }),
                                ),
                                DataCell(
                                  GestureDetector(
                                    onTap: () async {
                                      _controller.productionItem.removeWhere(
                                          (element) => element.sl == e.sl);

                                      var temp = _controller
                                          .singleProductionUnit.value.data?.items.data
                                          .firstWhereOrNull(
                                              (element) => element.id.toString() == e.id);
                                      if (isUpdate && temp != null) {
                                        _controller
                                            .deleteProductionItemData(id: e.id);
                                      }

                                      _controller.update(['prodItemId']);
                                      _controller.update(['calculationUpdate']);
                                    },
                                    child: Image.asset(
                                      "assets/delete.png",
                                      height: 20,
                                      width: 20,
                                      color: const Color(0xffED0206),
                                    ),
                                  ),
                                ),
                              ]);
                            }).toList(),
                          );
                        }),
                  ),
                  const SizedBox(height: 10),
                  GetBuilder<ProductionController>(
                    id: "updateIngredient",
                    builder: (controller) {
                      return _finalCalculation();
                    },
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () async {
                        if (_controller.foodId.value == 0) {
                          Utils.showSnackBar("Please select menu name");
                          return;
                        }
                        if (_controller.variantId.value == 0) {
                          Utils.showSnackBar("Please select variant name");
                          return;
                        }

                        if(_controller.productionItem.isEmpty){
                          Utils.showSnackBar("Please add a item");
                          return;
                        }

                        for (int i = 0;
                            i < _controller.productionItem.length;
                            i++) {
                          if (_controller.productionItem[i].itemInfo.id ==
                              null) {
                            Utils.showSnackBar(
                                "Please select info item in sl = ${_controller.productionItem[i].sl}");
                            return;
                          }
                        }

                        _controller.itemsData.addAll([
                          for (var singleItem in _controller.productionItem)
                            singleItem.toJson()
                        ]);
                        await _controller.addNewProductionUnit(isUpdate,
                            id: id);
                        Get.back();
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
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        });
  }

  Widget _finalCalculation() {
    return GetBuilder<ProductionController>(
        id: 'calculationUpdate',
        builder: (context) {
          _controller.totalAmount =
              Utils.calcTotalQuantityAmount(_controller.productionItem);
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total  : ',
                  style: TextStyle(color: primaryText, fontSize: fontMedium),
                ),
                const SizedBox(width: 30),
                Text(
                  _controller.totalAmount.toString(),
                  style: TextStyle(color: primaryText, fontSize: fontMedium),
                ),
              ],
            ),
          );
        });
  }

  Widget viewProductionUnit() {
    return Container(
      height: Size.infinite.height,
      width: Size.infinite.width,
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
                          'Menu Name : ',
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
                          _controller
                              .singleProductionUnit.value.data!.food.name,
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
                          'Variant Name : ',
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
                          _controller
                              .singleProductionUnit.value.data!.variant.name
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
            const SizedBox(height: 30),
            SizedBox(
              height: 40,
              child: Row(
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
                              'Menu Name',
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
                              'Quantity',
                              style: TextStyle(color: textSecondary),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Price',
                              style: TextStyle(color: textSecondary),
                            ),
                          ),
                        ],
                        rows: _controller
                            .singleProductionUnit.value.data!.items.data
                            .map((data) {
                          return DataRow(cells: [
                            DataCell(
                              Text(
                                data.ingredient.name,
                                style: TextStyle(color: primaryText),
                              ),
                            ),
                            DataCell(
                              Text(
                                data.unit,
                                style: TextStyle(color: primaryText),
                              ),
                            ),
                            DataCell(
                              Text(
                                data.quantity.toString(),
                                style: TextStyle(color: primaryText),
                              ),
                            ),
                            DataCell(
                              Text(
                                data.price,
                                style: TextStyle(color: primaryText),
                              ),
                            )
                          ]);
                        }).toList(),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
