import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:get/get.dart';
import 'package:klio_staff/mvc/model/Customer.dart';
import 'package:klio_staff/mvc/model/menu.dart';
import 'package:klio_staff/utils/utils.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:sumup/sumup.dart';
import '../../../constant/color.dart';
import '../../../constant/constant.dart';
import '../../../constant/value.dart';
import '../../../service/printer/customer_display.dart';
import '../../../service/printer/print_service.dart';
import '../../controller/food_management_controller.dart';
import '../../controller/home_controller.dart';
import '../../controller/payment_controller.dart';
import '../../model/add_menu_model.dart';
import '../../model/add_menu_model.dart' as add_menu_model;
import '../page/payment/square_payment.dart';
import '../widget/custom_widget.dart';
import 'package:path/path.dart';
import 'dart:io';

HomeController homeController = Get.find();

Future<void> showCustomDialog(BuildContext context, String title, Widget widget,
    int heightReduce, int widthReduce,
    {bool reducePop = false}) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width - widthReduce,
          height: MediaQuery.of(context).size.height - heightReduce,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: secondaryBackground,
          ),
          child: Column(
            children: [
              dialogHeader(title, context, reducePop: reducePop),
              // Divider(color: textSecondary, thickness: 1),
              const SizedBox(height: 10),
              Expanded(
                child: widget,
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> showCustomDialogResponsive(
  BuildContext context,
  String title,
  Widget widget,
  double height,
  double width,
) async {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: secondaryBackground,
            ),
            child: Column(
              children: [
                dialogHeader(title, context),
                // Divider(color: textSecondary, thickness: 1),
                const SizedBox(height: 10),
                Expanded(
                  child: widget,
                ),
              ],
            ),
          ));
    },
  );
}

void showWarningDialog(String message, {Function()? onAccept}) {
  Get.dialog(
    AlertDialog(
      backgroundColor: alternate,
      title: Row(
        children: [
          const Icon(
            Icons.warning,
            color: Colors.orange,
          ),
          Text(' Warning!', style: TextStyle(color: primaryText)),
        ],
      ),
      content: Text(message, style: TextStyle(color: primaryText)),
      actions: [
        TextButton(
          onPressed: onAccept,
          child: const Text("Yes"),
        ),
        TextButton(
          child: Text(
            "No",
            style: TextStyle(color: textSecondary),
          ),
          onPressed: () => Get.back(),
        ),
      ],
    ),
  );
}

void showInputDialog(
    String title, String message, TextEditingController controller,
    {Function()? onAccept}) {
  Get.dialog(
    AlertDialog(
      backgroundColor: alternate,
      title: Row(
        children: [
          const Icon(
            Icons.input,
            color: Colors.green,
          ),
          Text('  $title', style: TextStyle(color: primaryText)),
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: TextStyle(color: primaryText)),
          SizedBox(
            height: 40,
            child: TextFormField(
                keyboardType: TextInputType.number,
                controller: controller,
                style: TextStyle(fontSize: fontVerySmall, color: textSecondary),
                decoration: InputDecoration(
                    fillColor: secondaryBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Type here...',
                    contentPadding: const EdgeInsets.only(left: 5),
                    hintStyle: TextStyle(
                        fontSize: fontVerySmall, color: textSecondary))),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onAccept,
          child: const Text("Add"),
        ),
        TextButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: textSecondary),
          ),
          onPressed: () => Get.back(),
        ),
      ],
    ),
  );
}

void showDiscountDialog(String title, TextEditingController controller,
    {Function()? onAccept}) {
  Get.dialog(
    AlertDialog(
      backgroundColor: alternate,
      title: Row(
        children: [
          const Icon(
            Icons.input,
            color: Colors.green,
          ),
          Text('  ' + title, style: TextStyle(color: primaryText)),
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Value to discount", style: TextStyle(color: primaryText)),
          SizedBox(
            height: 40,
            child: TextFormField(
                keyboardType: TextInputType.number,
                controller: controller,
                style: TextStyle(fontSize: fontVerySmall, color: textSecondary),
                decoration: InputDecoration(
                    fillColor: secondaryBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Type here...',
                    contentPadding: const EdgeInsets.only(left: 5),
                    hintStyle: TextStyle(
                        fontSize: fontVerySmall, color: textSecondary))),
          ),
          const SizedBox(height: 15),
          Text('Discount Type', style: TextStyle(color: primaryText)),
          Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: textSecondary, width: 1)),
              child: Obx(() {
                return DropdownButton<String>(
                  items: discType.map((dynamic val) {
                    return DropdownMenuItem<String>(
                      value: val,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(val, style: TextStyle(color: primaryText)),
                      ),
                    );
                  }).toList(),
                  borderRadius: BorderRadius.circular(8),
                  underline: const SizedBox(),
                  isExpanded: true,
                  dropdownColor: primaryBackground,
                  value: homeController.discType.toString(),
                  onChanged: (value) {
                    homeController.discType.value = value!;
                  },
                );
              }))
        ],
      ),
      actions: [
        TextButton(
          onPressed: onAccept,
          child: const Text("Add"),
        ),
        TextButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: textSecondary),
          ),
          onPressed: () => Get.back(),
        ),
      ],
    ),
  );
}

Widget dialogHeader(String title, BuildContext context,
    {bool reducePop = false}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 22, color: primaryText),
        ),
        IconButton(
          onPressed: () {
            Get.back();
            if (reducePop) Utils.hidePopup();
            if (reducePop) Utils.hidePopup();
          },
          icon: Icon(
            Icons.close,
            color: textSecondary,
          ),
        ),
      ],
    ),
  );
}

Widget addRider(BuildContext context, bool isUpdate,
    {Customer? customer, Function()? onPressed}) {
  return Container(
    height: Size.infinite.height,
    width: Size.infinite.width,
    padding: const EdgeInsets.all(30),
    child: ListView(children: [
      Text(
        'First Name*',
        style: TextStyle(fontSize: fontMediumExtra, color: primaryText),
      ),
      const SizedBox(height: 10),
      normalTextField(homeController.controllerName.value),
      const SizedBox(height: 10),
      Text(
        'Last name*',
        style: TextStyle(fontSize: fontMediumExtra, color: primaryText),
      ),
      const SizedBox(height: 10),
      normalTextField(homeController.lastNameComtroller.value),
      const SizedBox(height: 10),
      Text(
        'Email',
        style: TextStyle(fontSize: fontMediumExtra, color: primaryText),
      ),
      const SizedBox(height: 10),
      normalTextField(homeController.controllerEmail.value),
      const SizedBox(height: 10),
      Text(
        'Phone*',
        style: TextStyle(fontSize: fontMediumExtra, color: primaryText),
      ),
      const SizedBox(height: 10),
      normalTextField(homeController.controllerPhone.value),
      if (!isUpdate) const SizedBox(height: 10),
      if (!isUpdate)
        Text(
          'Password*',
          style: TextStyle(fontSize: fontMediumExtra, color: primaryText),
        ),
      if (!isUpdate) const SizedBox(height: 10),
      if (!isUpdate) normalTextField(homeController.controllerPassword.value),
      if (!isUpdate) const SizedBox(height: 10),
      if (!isUpdate)
        Text(
          'Confirm Password*',
          style: TextStyle(fontSize: fontMediumExtra, color: primaryText),
        ),
      if (!isUpdate) const SizedBox(height: 10),
      if (!isUpdate)
        normalTextField(homeController.controllerConfirmPass.value),
      const SizedBox(height: 10),
      Text(
        'Address',
        style: TextStyle(fontSize: fontMediumExtra, color: primaryText),
      ),
      const SizedBox(height: 10),
      normalTextField(homeController.controllerAddress.value),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          normalButton('Submit', primaryColor, white, onPressed: onPressed),
        ],
      )
    ]),
  );
}

Widget addCustomer(BuildContext context, bool isDetail,
    {Customer? customer, Function()? onPressed}) {
  return Container(
    height: Size.infinite.height,
    width: Size.infinite.width,
    padding: const EdgeInsets.all(30),
    child: ListView(children: [
      Text(
        'Name*',
        style: TextStyle(fontSize: fontMediumExtra, color: primaryText),
      ),
      const SizedBox(height: 10),
      normalTextField(homeController.controllerName.value),
      const SizedBox(height: 10),
      Text(
        'Email',
        style: TextStyle(fontSize: fontMediumExtra, color: primaryText),
      ),
      const SizedBox(height: 10),
      normalTextField(homeController.controllerEmail.value),
      const SizedBox(height: 10),
      Text(
        'Phone*',
        style: TextStyle(fontSize: fontMediumExtra, color: primaryText),
      ),
      const SizedBox(height: 10),
      normalTextField(homeController.controllerPhone.value),
      const SizedBox(height: 10),
      Text(
        'Delivery Address*',
        style: TextStyle(fontSize: fontMediumExtra, color: primaryText),
      ),
      const SizedBox(height: 10),
      normalTextField(homeController.controllerAddress.value),
      if (isDetail)
        for (int i = 5; i < customer!.data!.toJson().entries.length; i++)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                customer.data!.toJson().keys.toList()[i].toUpperCase(),
                style: TextStyle(fontSize: fontMediumExtra, color: primaryText),
              ),
              const SizedBox(height: 10),
              normalTextField(TextEditingController(
                  text: customer.data!.toJson().values.toList()[i].toString())),
              const SizedBox(height: 10)
            ],
          ),
      const SizedBox(height: 20),
      if (!isDetail)
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            normalButton('Submit', primaryColor, white, onPressed: onPressed),
          ],
        )
    ]),
  );
}

Widget foodMenuBody(BuildContext context, MenuData data) {
  homeController.menuData.value = data;
  homeController.menuData.value.quantity = 1;

  for (int i = 0; i < homeController.menuData.value.addons!.data!.length; i++) {
    homeController.menuData.value.addons!.data![i].quantity = 0;
    homeController.menuData.value.addons!.data![i].isChecked = false;
  }
  // homeController.variantPrice.value = 0;
  double unitPrice = 0;

  if (data.variants!.data!.isEmpty) {
    unitPrice = double.parse(homeController.menuData.value.price.toString());
    homeController.menuData.value.variant = '0';
  } else {
    unitPrice = double.parse(data.variants!.data!.first.price.toString());
    homeController.menuData.value.variant =
        data.variants!.data![0].id.toString();
  }
  //unitPrice = double.parse(data.variants!.data!.first.price.toString());
  //homeController.menuData.value.variant = data.variants!.data![0].id.toString();

  return Padding(
    padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.only(right: 25),
            child: ListView(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name.toString(),
                  style: TextStyle(
                      fontSize: fontMediumExtra,
                      color: primaryText,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  data.description.toString(),
                  style:
                      TextStyle(fontSize: fontVerySmall, color: textSecondary),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(data.image.toString(),
                      height: 242, width: 242, fit: BoxFit.cover),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          flex: 5,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    "Name",
                    style: TextStyle(
                        fontSize: fontVerySmall, color: textSecondary),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Size",
                    style: TextStyle(
                        fontSize: fontVerySmall, color: textSecondary),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Qty",
                    style: TextStyle(
                        fontSize: fontVerySmall, color: textSecondary),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "Price",
                    style: TextStyle(
                        fontSize: fontVerySmall, color: textSecondary),
                  ),
                ),
              ],
            ),
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(data.name.toString(),
                        style: TextStyle(
                            fontSize: fontMedium,
                            color: primaryText,
                            fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                        height: 33,
                        alignment: Alignment.center,
                        margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: textSecondary, width: 1)),
                        child: DropdownButton<String>(
                          items: data.variants!.data!.map((dynamic val) {
                            return DropdownMenuItem<String>(
                              value: val.name.toString(),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(val.name,
                                    style: TextStyle(
                                        color: primaryText,
                                        fontSize: fontVerySmall)),
                              ),
                            );
                          }).toList(),
                          borderRadius: BorderRadius.circular(30),
                          underline: const SizedBox(),
                          isExpanded: true,
                          dropdownColor: primaryBackground,
                          value: data.variants!.data!.isEmpty
                              ? "Normal"
                              : data.variants!.data![0].name,
                          onChanged: (value) {
                            unitPrice = double.parse(
                                Utils.findPriceByListNearValue(
                                    data.variants!.data!, value!));
                            // homeController.menuData.value.variant = unitPrice.toString();
                            // for store variant as id
                            homeController.menuData.value.variant =
                                Utils.findIdByListNearValue(
                                    data.variants!.data!, value);
                            print(homeController.menuData.value.variant);
                          },
                        )),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        topBarIconBtn(
                            Image.asset('assets/remove.png', color: white),
                            primaryColor,
                            0,
                            2,
                            26, onPressed: () {
                          homeController.menuData.value.quantity =
                              Utils.incrementDecrement(
                                  false,
                                  homeController.menuData.value.quantity!
                                      .toInt());
                          homeController.menuData.refresh();
                        }),
                        const SizedBox(width: 8),
                        Text(homeController.menuData.value.quantity.toString(),
                            style: TextStyle(
                                color: primaryText, fontSize: fontMedium)),
                        const SizedBox(width: 8),
                        topBarIconBtn(
                            Image.asset('assets/add.png', color: white),
                            primaryColor,
                            0,
                            2,
                            26, onPressed: () {
                          homeController.menuData.value.quantity =
                              Utils.incrementDecrement(
                                  true,
                                  homeController.menuData.value.quantity!
                                      .toInt());
                          homeController.menuData.refresh();
                        }),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 16,
                    child: Text(
                        "${homeController.settings.value.data![11].value}${(homeController.menuData.value.quantity! * unitPrice).toStringAsFixed(2)}",
                        style: TextStyle(
                            fontSize: fontMedium,
                            color: primaryText,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              );
            }),
            Divider(color: textSecondary, thickness: 1),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Expanded(
                //   flex: 1,
                //   child: Text(
                //     "Selection",
                //     style: TextStyle(
                //         fontSize: fontVerySmall, color: textSecondary),
                //   ),
                // ),
                Expanded(
                  flex: 3,
                  child: Text(
                    "Addon Name",
                    style: TextStyle(
                        fontSize: fontVerySmall, color: textSecondary),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    "Qty",
                    style: TextStyle(
                        fontSize: fontVerySmall, color: textSecondary),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    "Price",
                    style: TextStyle(
                        fontSize: fontVerySmall, color: textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Obx(
                () {
                  if (homeController.cardList.isNotEmpty)
                    print(homeController.cardList[0].quantity);
                  print(
                      "----------------------============================= 2");
                  return ListView.builder(
                      itemCount:
                          homeController.menuData.value.addons!.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Expanded(
                                //     flex: 1,
                                //     child: Padding(
                                //         padding: const EdgeInsets.only(right: 60.0),
                                //         child: Checkbox(
                                //             value: homeController.menuData.value.addons!
                                //                 .data![index].isChecked,
                                //             onChanged: (checked) {
                                //               // homeController.menuData.value.addons!
                                //               //     .data![index].isChecked = checked!;
                                //               // homeController.menuData.refresh();
                                //             }))),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                      homeController.menuData.value.addons!
                                          .data![index].name
                                          .toString(),
                                      style: TextStyle(
                                          fontSize: fontSmall,
                                          color: primaryText,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      topBarIconBtn(
                                          Image.asset('assets/remove.png',
                                              color: white),
                                          primaryColor,
                                          0,
                                          2,
                                          23, onPressed: () {
                                        homeController.menuData.value.addons!
                                                .data![index].quantity =
                                            Utils.incrementDecrement(
                                                false,
                                                homeController
                                                    .menuData
                                                    .value
                                                    .addons!
                                                    .data![index]
                                                    .quantity!
                                                    .toInt());
                                        if (homeController
                                                .menuData
                                                .value
                                                .addons!
                                                .data![index]
                                                .quantity! >
                                            0) {
                                          homeController.menuData.value.addons!
                                              .data![index].isChecked = true;
                                        } else
                                          homeController.menuData.value.addons!
                                              .data![index].isChecked = false;
                                        homeController.menuData.refresh();
                                      }),
                                      const SizedBox(width: 8),
                                      Text(
                                          homeController.menuData.value.addons!
                                              .data![index].quantity
                                              .toString(),
                                          style: TextStyle(
                                              color: primaryText,
                                              fontSize: fontSmall,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      topBarIconBtn(
                                          Image.asset('assets/add.png',
                                              color: white),
                                          primaryColor,
                                          0,
                                          2,
                                          23, onPressed: () {
                                        homeController.menuData.value.addons!
                                                .data![index].quantity =
                                            Utils.incrementDecrement(
                                                true,
                                                homeController
                                                    .menuData
                                                    .value
                                                    .addons!
                                                    .data![index]
                                                    .quantity!
                                                    .toInt());
                                        if (homeController
                                                .menuData
                                                .value
                                                .addons!
                                                .data![index]
                                                .quantity! >
                                            0) {
                                          homeController.menuData.value.addons!
                                              .data![index].isChecked = true;
                                        } else
                                          homeController.menuData.value.addons!
                                              .data![index].isChecked = false;
                                        homeController.menuData.refresh();
                                      }),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                      "${homeController.settings.value.data![11].value}${homeController.menuData.value.addons!.data![index].quantity! * double.parse(homeController.menuData.value.addons!.data![index].price.toString())}",
                                      style: TextStyle(
                                          fontSize: fontSmall,
                                          color: primaryText,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      });
                },
              ),
            ),
            MaterialButton(
                elevation: 0,
                color: primaryColor,
                height: 40,
                minWidth: 160,
                // padding: EdgeInsets.all(20),
                onPressed: () {
                  int a = -1;

                  for (int i = 0; i < homeController.cardList.length; i++) {
                    if (homeController.cardList[i].name ==
                        homeController.menuData.value.name) {
                      a = i;
                      break;
                    }
                  }

                  if (a < 0) {
                    homeController.cardList.add(MenuData(
                      id: homeController.menuData.value.id,
                      name: homeController.menuData.value.name,
                      addons: homeController.menuData.value.addons,
                      allergies: homeController.menuData.value.allergies,
                      calorie: homeController.menuData.value.calorie,
                      categories: homeController.menuData.value.categories,
                      description: homeController.menuData.value.description,
                      image: homeController.menuData.value.image,
                      price: homeController.menuData.value.price,
                      quantity: homeController.menuData.value.quantity,
                      slug: homeController.menuData.value.slug,
                      taxVat: homeController.menuData.value.taxVat,
                      variant: homeController.menuData.value.variant,
                      variants: homeController.menuData.value.variants,
                    ));
                  } else {
                    homeController.cardList[a].quantity =
                        homeController.menuData.value.quantity! +
                            homeController.cardList[a].quantity!;
                  }

                  Utils.hidePopup();
                  Utils.hidePopup();
                  homeController.update(["cardUpdate"]);
                  CustomerDisplay.cartPrint(homeController);
                  // print(homeController.menuData.value.toJson());
                  // print(homeController.menuData.value.qty);
                  // print(homeController.menuData.value.addons!.data);
                  // print(homeController.menuData.value.addons!.data![0].qty);
                  // print(homeController.menuData.value.addons!.data![1].qty);
                  // print(homeController.menuData.value.addons!.data![1].isChecked);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/shopping-cart.png',
                      color: white,
                      height: 15,
                      width: 15,
                    ),
                    const SizedBox(width: 5),
                    const Text("Add to cart",
                        style: TextStyle(color: white, fontSize: fontSmall)),
                  ],
                )),
          ]),
        ),
      ],
    ),
  );
}

Widget tableBody(BuildContext context, bool showOnly) {
  Size size = MediaQuery.of(context).size;
  ScrollController _scrollController = ScrollController();
  for (int i = 0; i < homeController.tables.value.data!.length; i++) {
    homeController.tables.value.data![i].message = '';
    homeController.tables.value.data![i].person = 0;
  }
  homeController.withoutTable.value = false;

  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Expanded(
        child: RawScrollbar(
          thumbVisibility: true,
          trackVisibility: true,
          thickness: 12,
          thumbColor: primaryColor,
          radius: const Radius.circular(20),
          controller: _scrollController,
          child: Obx(() {
            return GridView.builder(
                padding: EdgeInsets.zero,
                controller: _scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: size.width > size.height ? 3 : 2,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: showOnly ? .85 : 1.6,
                ),
                scrollDirection: Axis.vertical,
                itemCount: homeController.tables.value.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    padding: const EdgeInsets.all(20.0),
                    margin: const EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: textSecondary, width: .3)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  homeController.tables.value.data![index].name
                                      .toString(),
                                  style: TextStyle(
                                      fontSize: fontBig,
                                      fontWeight: FontWeight.bold,
                                      color: primaryText),
                                ),
                                Text(
                                    'Sit capacity: ${homeController.tables.value.data![index].capacity.toString()} Available: ${homeController.tables.value.data![index].available.toString()}',
                                    style: TextStyle(
                                        fontSize: fontVerySmall,
                                        color: primaryText)),
                              ],
                            ),
                            Image.asset(
                              "assets/table2.png",
                              height: 60,
                              width: 60,
                              fit: BoxFit.fill,
                              color: primaryColor,
                            )
                          ],
                        ),
                        const SizedBox(height: 10),
                        !showOnly ? const SizedBox() : const SizedBox(height: 10),
                        !showOnly
                            ? const SizedBox()
                            : Row(
                                children: [
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Order',
                                        style: TextStyle(
                                            color: textSecondary,
                                            fontSize: fontVerySmall),
                                      )),
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Time',
                                        style: TextStyle(
                                            color: textSecondary,
                                            fontSize: fontVerySmall),
                                      )),
                                  Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Person',
                                        style: TextStyle(
                                            color: textSecondary,
                                            fontSize: fontVerySmall),
                                      )),
                                  // Expanded(
                                  //     flex: 1,
                                  //     child: Text(
                                  //       '',
                                  //       style: TextStyle(
                                  //           color: textSecondary,
                                  //           fontSize: fontVerySmall),
                                  //     )),
                                ],
                              ),
                        // SizedBox(height: 10),
                        !showOnly
                            ? const SizedBox()
                            : SizedBox(
                                height: 220,
                                child: ListView.builder(
                                    itemCount: homeController.tables.value
                                        .data![index].orders!.data!.length,
                                    shrinkWrap: true,
                                    itemBuilder:
                                        (BuildContext context, int index2) {
                                      return Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                      homeController
                                                          .tables
                                                          .value
                                                          .data![index]
                                                          .orders!
                                                          .data![index2]
                                                          .invoice
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: fontSmall,
                                                          color: primaryText,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                      homeController
                                                          .tables
                                                          .value
                                                          .data![index]
                                                          .orders!
                                                          .data![index2]
                                                          .time
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: fontSmall,
                                                          color: primaryText,
                                                          fontWeight: FontWeight
                                                              .bold))),
                                              Expanded(
                                                flex: 2,
                                                child: Text(
                                                    homeController
                                                        .tables
                                                        .value
                                                        .data![index]
                                                        .orders!
                                                        .data![index2]
                                                        .totalPerson
                                                        .toString(),
                                                    style: TextStyle(
                                                        fontSize: fontSmall,
                                                        color: primaryText,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                              ),
                                              // Expanded(
                                              //     flex: 1,
                                              //     child: IconButton(
                                              //       onPressed: () {},
                                              //       icon: Image.asset(
                                              //         "assets/delete.png",
                                              //         color: Colors.red,
                                              //         height: 18,
                                              //         width: 18,
                                              //       ),
                                              //     )),
                                            ],
                                          ),
                                          Container(
                                            height: .5,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: textSecondary,
                                                    width: .3)),
                                          ),
                                        ],
                                      );
                                    }),
                              ),
                        showOnly
                            ? const SizedBox()
                            : SizedBox(
                                height: 30,
                                child: TextFormField(
                                    onChanged: (text) {
                                      if (text == '') {
                                        homeController.tables.value.data![index]
                                            .person = 0;
                                        homeController.tables.refresh();
                                      }
                                      print(text);
                                      if (homeController.tables.value
                                              .data![index].available! >=
                                          int.parse(text ?? '0')) {
                                        homeController.tables.value.data![index]
                                            .person = int.parse(text);
                                        homeController.tables.value.data![index]
                                            .message = '';
                                        homeController.tables.refresh();
                                      } else {
                                        homeController.tables.value.data![index]
                                            .person = 0;
                                        homeController.tables.value.data![index]
                                                .message =
                                            'Available sit is not smaller than entered person!';
                                        homeController.tables.refresh();
                                      }
                                    },
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        fontSize: fontVerySmall,
                                        color: primaryText),
                                    decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          borderSide: BorderSide(
                                              color: textSecondary, width: .5),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        hintStyle: TextStyle(
                                            fontSize: fontVerySmall,
                                            color: primaryText),
                                        hintText: 'Person')),
                              ),
                        showOnly
                            ? const SizedBox()
                            : Expanded(
                                child: Text(
                                    homeController.tables.value.data![index]
                                            .message ??
                                        '',
                                    style: const TextStyle(color: Colors.red)),
                              )
                      ],
                    ),
                  );
                });
          }),
        ),
      ),
      !showOnly
          ? const SizedBox()
          : const SizedBox(
              height: 10,
            ),
      showOnly
          ? const SizedBox()
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                normalButton(
                    'Process without table', Colors.transparent, textSecondary,
                    onPressed: () {
                  homeController.withoutTable.value = true;
                  homeController.tables.value.data!.clear();
                  Get.back();
                }),
                normalButton('Please read', primaryBackground, primaryText,
                    onPressed: () {}),
                const SizedBox(width: 100),
                normalButton('Submit', primaryColor, white, onPressed: () {
                  print(homeController.tables.value.toJson());
                  bool error = false;
                  for (var element in homeController.tables.value.data!) {
                    if (element.message != '') {
                      error = true;
                      break;
                    }
                  }

/*
                  for(int i=0; i<homeController.tables.value.data!.length; i++){
                    print(homeController.tables.value.data![i].number);
                    print(homeController.tables.value.data![i].name);
                    print(homeController.tables.value.data![i].person);
                    print("======================== 222222222222222222222222222");
                  }

                  print("======================== 222222222222222222222222222  enddddddddddddddd");*/

                  if (error) {
                    Utils.showSnackBar("Check the person filed is valid!");
                  } else {
                    for (var element in homeController.tables.value.data!) {
                      if (element.person != 0) {
                        error = false;
                        break;
                      } else {
                        error = true;
                      }
                    }
                    if (!error) {
                      homeController.withoutTable.value = true;
                      Get.back();
                    } else
                      Utils.showSnackBar("Check the person filed is empty!");
                  }
                }),
              ],
            ),
    ]),
  );
}

Widget searchOrderDialog(BuildContext context) {
  Timer? searchOnStoppedTyping;
  homeController.searchOrders();
  return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: 56,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 0, 20, 0),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(43),
            ),
            child: Row(
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: MultiSelectDropDown(
                        backgroundColor: secondaryBackground,
                        optionsBackgroundColor: secondaryBackground,
                        selectedOptionTextColor: primaryText,
                        selectedOptionBackgroundColor: primaryColor,
                        showClearIcon: false,
                        optionTextStyle:
                            TextStyle(color: primaryText, fontSize: 16),
                        onOptionSelected: (List<ValueItem> selectedOptions) {
                          homeController.selectedSearchType =
                              selectedOptions.first.value ?? "table";
                          const duration = Duration(
                              seconds:
                                  1); // set the duration that you want call search() after that.
                          if (searchOnStoppedTyping != null) {
                            searchOnStoppedTyping!.cancel(); // clear timer
                          }
                          if (homeController.searchController.text.isNotEmpty) {
                            searchOnStoppedTyping = Timer(
                                duration, () => homeController.searchOrders());
                          }
                        },
                        options: ["Table", "Invoice", "Name"].map((e) {
                          return ValueItem(
                            label: e,
                            value: e.toLowerCase(),
                          );
                        }).toList(),
                        hint: 'Table',
                        hintColor: primaryText,
                        selectionType: SelectionType.single,
                        chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                        selectedOptions: const [
                          ValueItem(
                            label: "Table",
                            value: "table",
                          )
                        ],
                        selectedOptionIcon: const Icon(Icons.check_circle),
                        inputDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                    ),
                    Container(
                      height: 56,
                      width: 1,
                      color: Colors.black,
                    )
                  ],
                ),
                SizedBox(
                  width: 200,
                  child: TextFormField(
                    controller: homeController.searchController,
                    onChanged: (text) {
                      const duration = Duration(
                          seconds:
                              1); // set the duration that you want call search() after that.
                      if (searchOnStoppedTyping != null) {
                        searchOnStoppedTyping!.cancel(); // clear timer
                      }
                      searchOnStoppedTyping =
                          Timer(duration, () => homeController.searchOrders());
                    },
                    decoration: InputDecoration(
                      suffixIconConstraints:
                          const BoxConstraints(maxHeight: 24, maxWidth: 24),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      hintText: "Search Order",
                      hintStyle: TextStyle(
                        color: primaryText,
                        fontSize: fontSmall,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: textSecondary,
                  ),
                  onPressed: () {
                    homeController.searchController.clear();
                    homeController.searchOrders();
                  },
                )
              ],
            ),
          ),

          /*TextFormField(
              controller: searchController,
              style: TextStyle(color: primaryText),
              onChanged: (text) {
                const duration = Duration(
                    seconds:
                        1); // set the duration that you want call search() after that.
                if (searchOnStoppedTyping != null) {
                  searchOnStoppedTyping!.cancel(); // clear timer
                }
                searchOnStoppedTyping =
                    Timer(duration, () => homeController.searchOrders(text));
              },
              decoration: InputDecoration(
                fillColor: secondaryBackground,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                label: Text(
                  'Search Order',
                  style: TextStyle(color: primaryText),
                ),
                //hintText: "Search Order by Name or Table",
                prefixIcon: SizedBox(
                  width: 120,
                  height: 50,
                  child: Row(
                    children: [
                      MultiSelectDropDown(

                        backgroundColor: secondaryBackground,
                        optionsBackgroundColor: secondaryBackground,
                        selectedOptionTextColor: primaryText,
                        selectedOptionBackgroundColor: primaryColor,
                        showClearIcon: false,
                        optionTextStyle:
                            TextStyle(color: primaryText, fontSize: 16),
                        onOptionSelected: (List<ValueItem> selectedOptions) {},
                        options: ["Table", "Invoice", "Name"].map((e) {
                          return ValueItem(
                            label: e,
                            value: e.toLowerCase(),
                          );
                        }).toList(),
                        hint: 'Table',
                        hintColor: primaryText,
                        selectionType: SelectionType.single,
                        chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                        selectedOptions: const [
                          ValueItem(
                            label: "Table",
                            value: "table",
                          )
                        ],
                        selectedOptionIcon: const Icon(Icons.check_circle),

                        inputDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 1,
                        color: Colors.black,
                      )
                    ],
                  ),

                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: textSecondary,
                  ),
                  onPressed: () {
                    searchController.clear();
                    homeController.searchOrders("");
                  },
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: textSecondary)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    borderSide: BorderSide(color: textSecondary)),
                hintStyle:
                    TextStyle(fontSize: fontVerySmall, color: textSecondary),
              )),*/
          const SizedBox(height: 10),
          Expanded(
            child: Obx(() {
              return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: homeController.searchedOrders.value.data == null
                    ? 0
                    : homeController.searchedOrders.value.data!.length,
                itemBuilder: (context, index) {
                  String value = homeController.searchedOrders.value
                                  .data![index].customerName !=
                              null &&
                          homeController.searchedOrders.value.data![index]
                              .customerName!.isNotEmpty
                      ? "C Name : ${homeController.searchedOrders.value.data![index].customerName}"
                      : "Invoice : ${homeController.searchedOrders.value.data![index].invoice.toString()}";
                  return Card(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    color: alternate,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: homeController.selectedOrder == index
                            ? const BorderSide(width: 2, color: primaryColor)
                            : BorderSide.none),
                    child: Container(
                      width: 250,
                      alignment: Alignment.center,
                      color: alternate,
                      child: GestureDetector(
                        onDoubleTap: () async {
                          homeController.selectedOrder.value = index;
                          homeController.searchedOrders.refresh();
                          Utils.showLoading();
                          await homeController.getOrder(homeController
                              .searchedOrders
                              .value
                              .data![homeController.selectedOrder.value]
                              .id!
                              .toInt());
                          Utils.hidePopup();
                          if (homeController.order.value.data != null) {
                            showCustomDialog(context, "Order Details",
                                orderDetail(context), 50, 400);
                          }
                        },
                        child: ListTile(
                          onTap: () {
                            homeController.selectedOrder.value = index;
                            homeController.searchedOrders.refresh();
                          },
                          leading: Image.asset(
                            orderTypes[homeController
                                .searchedOrders.value.data![index].type
                                .toString()],
                            color: primaryColor,
                          ),
                          title: Text(
                              homeController
                                      .searchedOrders.value.data![index].type
                                      .toString() ??
                                  '',
                              style: TextStyle(
                                  fontSize: fontMedium,
                                  color: primaryText,
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              homeController.searchedOrders.value.data![index]
                                          .type ==
                                      "Dine In"
                                  ? 'Table : ${Utils.getTables(homeController.searchedOrders.value.data![index].tables!.data!)}\n$value'
                                  : 'Invoice : ${homeController.searchedOrders.value.data![index].invoice}\n$value',
                              style: TextStyle(
                                fontSize: fontVerySmall,
                                color: primaryText,
                              )),
                          tileColor: secondaryBackground,
                          dense: false,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          )
        ],
      ));
}

Widget orderDetail(BuildContext context) {
  String time = homeController.order.value.data!.processingTime ?? "00:00:00";
  int hour = int.parse(time[0] + time[1]);
  int minute = int.parse(time[3] + time[4]);
  int second = int.parse(time[6] + time[7]);
  return Padding(
    padding: const EdgeInsets.fromLTRB(30, 0, 30, 20),
    child: GetBuilder(builder: (HomeController homeController) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 1,
                child: textMixer(
                    'Order Type: ',
                    homeController.order.value.data != null
                        ? homeController.order.value.data!.type.toString()
                        : "null",
                    MainAxisAlignment.start)),
            Expanded(
                flex: 1,
                child: textMixer(
                    'Customer Name: ',
                    homeController.order.value.data != null
                        ? homeController.order.value.data!.customer!.name
                            .toString()
                        : "null",
                    MainAxisAlignment.center)),
            Expanded(
                flex: 1,
                child: textMixer(
                    'Invoice: ',
                    homeController.order.value.data != null
                        ? homeController.order.value.data!.invoice.toString()
                        : "null",
                    MainAxisAlignment.end)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              flex: 1,
              child: textMixer(
                'Table Number: ',
                Utils.getTables(
                    homeController.order.value.data!.tables!.data!.toList()),
                MainAxisAlignment.start,
              ),
            ),
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Processing Time:  ",
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold)),
                  TimerCountdown(
                    format: CountDownTimerFormat.hoursMinutesSeconds,
                    enableDescriptions: false,
                    timeTextStyle: TextStyle(
                        fontSize: fontVerySmall, color: textSecondary),
                    colonsTextStyle: TextStyle(
                        fontSize: fontVerySmall, color: textSecondary),
                    endTime: DateTime.now().add(
                      Duration(
                        hours: hour,
                        minutes: minute,
                        seconds: second,
                      ),
                    ),
                    onEnd: () {},
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: textMixer(
                'Price: ',
                '${homeController.settings.value.data![11].value}' +
                    homeController.order.value.data!.grandTotal.toString(),
                MainAxisAlignment.end,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                "NO",
                style: TextStyle(
                    fontSize: fontVerySmall,
                    color: primaryText,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                "Status",
                style: TextStyle(
                    fontSize: fontVerySmall,
                    color: primaryText,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "Name",
                style: TextStyle(
                    fontSize: fontVerySmall,
                    color: primaryText,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                "Variant Name",
                style: TextStyle(
                    fontSize: fontVerySmall,
                    color: primaryText,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                "Price",
                style: TextStyle(
                    fontSize: fontVerySmall,
                    color: primaryText,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                "Qty",
                style: TextStyle(
                    fontSize: fontVerySmall,
                    color: primaryText,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                "Vat",
                style: TextStyle(
                    fontSize: fontVerySmall,
                    color: primaryText,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(
                "Total",
                style: TextStyle(
                    fontSize: fontVerySmall,
                    color: primaryText,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Divider(color: textSecondary, thickness: 0.1, height: 0.1),
        Expanded(
            child: ListView.builder(
                itemCount:
                    homeController.order.value.data!.orderDetails!.data!.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text(
                                (index + 1).toString(),
                                style: TextStyle(
                                    fontSize: fontVerySmall,
                                    color: primaryText,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: homeController
                                                .order
                                                .value
                                                .data!
                                                .orderDetails!
                                                .data![index]
                                                .status ==
                                            'pending'
                                        ? red
                                        : homeController
                                                    .order
                                                    .value
                                                    .data!
                                                    .orderDetails!
                                                    .data![index]
                                                    .status ==
                                                'ready'
                                            ? green
                                            : blue),
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(right: 20),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  homeController.order.value.data!.orderDetails!
                                      .data![index].status
                                      .toString(),
                                  style: const TextStyle(
                                      fontSize: fontVerySmall,
                                      color: white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                homeController.order.value.data!.orderDetails!
                                    .data![index].food!.name
                                    .toString(),
                                style: TextStyle(
                                    fontSize: fontVerySmall,
                                    color: textSecondary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                homeController.order.value.data!.orderDetails!
                                    .data![index].variant!.name
                                    .toString(),
                                style: TextStyle(
                                    fontSize: fontVerySmall,
                                    color: textSecondary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "${homeController.settings.value.data![11].value}${homeController.order.value.data!.orderDetails!.data![index].price}",
                                style: TextStyle(
                                    fontSize: fontVerySmall,
                                    color: textSecondary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                homeController.order.value.data!.orderDetails!
                                    .data![index].quantity
                                    .toString(),
                                style: TextStyle(
                                    fontSize: fontVerySmall,
                                    color: textSecondary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                homeController.order.value.data!.orderDetails!
                                    .data![index].vat
                                    .toString(),
                                style: TextStyle(
                                    fontSize: fontVerySmall,
                                    color: textSecondary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Text(
                                "${homeController.settings.value.data![11].value}${homeController.order.value.data!.orderDetails!.data![index].totalPrice}",
                                style: TextStyle(
                                    fontSize: fontVerySmall,
                                    color: textSecondary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                          color: textSecondary, thickness: 0.1, height: 0.1),
                      homeController.order.value.data!.orderDetails!
                                  .data![index].addons!.data!.length >
                              0
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      for (var addons in homeController
                                          .order
                                          .value
                                          .data!
                                          .orderDetails!
                                          .data![index]
                                          .addons!
                                          .data!
                                          .toList())
                                        Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 5),
                                            decoration: BoxDecoration(
                                                color: alternate,
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Text(
                                                '${addons.name}  ${addons.quantity}x${addons.price}',
                                                style: TextStyle(
                                                    fontSize: fontVerySmall,
                                                    color: textSecondary)))
                                    ],
                                  ),
                                  Divider(
                                      color: textSecondary,
                                      thickness: 0.1,
                                      height: 0.1),
                                ],
                              ),
                            )
                          : const SizedBox(),
                    ],
                  );
                })),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 1,
                child: textMixer(
                    'Total Item: ',
                    homeController.order.value.data!.orderDetails!.data!.length
                        .toString(),
                    MainAxisAlignment.start)),
            Expanded(
                flex: 1,
                child: textMixer(
                    'Sub Total: ',
                    Utils.orderSubTotal(homeController
                            .order.value.data!.orderDetails!.data!
                            .toList())
                        .toStringAsFixed(2),
                    // '${double.parse(homeController.order.value.data!.grandTotal.toString()) + double.parse(homeController.order.value.data!.discount.toString()) - (double.parse(homeController.order.value.data!.deliveryCharge.toString()) + Utils.vatTotal2(homeController.order.value.data!.orderDetails!.data!.toList()) + double.parse(homeController.order.value.data!.serviceCharge.toString()))}',
                    MainAxisAlignment.center)),
            Expanded(
                flex: 1,
                child: textMixer(
                    'Service Charge: ',
                    '${homeController.settings.value.data![11].value}${homeController.order.value.data!.serviceCharge}',
                    MainAxisAlignment.end)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 1,
                child: textMixer(
                    'Delivery Charge: ',
                    '${homeController.settings.value.data![11].value}${homeController.order.value.data!.deliveryCharge}',
                    MainAxisAlignment.start)),
            Expanded(
                flex: 1, child: textMixer('', '', MainAxisAlignment.center)),
            Expanded(
                flex: 1,
                child: textMixer(
                    'Discount: ',
                    '${homeController.settings.value.data![11].value}${homeController.order.value.data!.discount}',
                    MainAxisAlignment.end)),
          ],
        ),
        const SizedBox(height: 30),
        Center(
          child: Text(
            'Grand Total: ${homeController.settings.value.data![11].value}${homeController.order.value.data!.grandTotal}',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: fontSmall,
                color: textSecondary),
          ),
        ),
        const Expanded(child: SizedBox(height: 500)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            normalButton('Create Invoice', primaryColor, white,
                onPressed: () async {
              Utils.hidePopup();
              Utils.showLoading();
              String id = Utils.findIdByListNearValue(
                  homeController.customers.value.data!.toList(),
                  homeController.customerName.value);
              Customer? customer = Customer();
              if (id != '0' && id.isNotEmpty) {
                customer = await homeController.getCustomer(id);
              }

              Utils.hidePopup();
              if (customer == null) return;
              showCustomDialog(context, "Finalize Order",
                      finalizeOrder(context, customer), 100, 600)
                  .then((value) => NfcManager.instance.stopSession());
            }),
            normalButton('Close', textSecondary, white,
                onPressed: () => Get.back()),
          ],
        )
      ]);
    }),
  );
}

finalizeOrder(BuildContext context, Customer customer) {
  homeController.giveAmount.value = 0;
  ValueNotifier<bool> nfcResult = ValueNotifier(false);
  Customer? nfcCustomerInfo;
  double totalPayable = double.parse(homeController.order.value.data!
      .grandTotal!); // Utils.calcSubTotal(homeController.cardList);

  double rewardDiscount =
      ((customer.data == null ? 0 : customer.data!.pointsAcquired)! *
          double.parse(homeController.settings.value.data![23].value!));

  CustomerDisplay.totalPayPrint(
      '${homeController.settings.value.data![11].value}${homeController.order.value.data!.grandTotal}');
  TextEditingController textController = TextEditingController();

  void tagRead() {
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        nfcResult.value = true;
        NfcManager.instance.stopSession();
        Map tagData = tag.data;
        Map tagNdef = tagData['ndef'];
        if (tagNdef['cachedMessage'] == null) {
          Utils.showSnackBar("Empty Card");
          return;
        }
        Map cachedMessage = tagNdef['cachedMessage'];
        Map records = cachedMessage['records'][0];
        Uint8List payload = records['payload'];
        String payloadAsString = String.fromCharCodes(payload);

        final startIndex = payloadAsString.lastIndexOf("/");

        final id = payloadAsString.substring(startIndex + 1);

        if (id.isNotEmpty) {
          homeController.isNFCRewardSelected.value = true;
          homeController.reward.value = false;
          nfcCustomerInfo = await homeController.getCustomer(id);
          rewardDiscount = ((nfcCustomerInfo == null
                  ? 0
                  : nfcCustomerInfo!.data!.pointsAcquired)! *
              double.parse(homeController.settings.value.data![23].value!));
          nfcResult.value = false;
          homeController.reward.refresh();
        }
      },
    );
  }

  return GetBuilder<HomeController>(
      id: "finalizeOrder",
      builder: (builderContext) {
        return Container(
          height: Size.infinite.height,
          width: Size.infinite.width,
          padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
          child: ListView(
            //mainAxisAlignment: MainAxisAlignment.start,
            //crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Reward: ${customer.data == null ? 0 : customer.data!.pointsAcquired}, 1R = ${homeController.settings.value.data![11].value}${homeController.settings.value.data![23].value}, You get ${homeController.settings.value.data![11].value}${(customer.data == null ? 0 : customer.data!.pointsAcquired!) * double.parse(homeController.settings.value.data![23].value!)}',
                  style: TextStyle(fontSize: fontSmall, color: primaryText),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    return Checkbox(
                        value: homeController.reward.value,
                        side: BorderSide(color: textSecondary),
                        onChanged: (checked) {
                          if (homeController.reward.value == true) {
                            homeController.reward.value = false;
                          } else {
                            homeController.reward.value = checked!;
                            homeController.isNFCRewardSelected.value = !checked;
                            rewardDiscount = ((customer.data == null
                                    ? 0
                                    : customer.data!.pointsAcquired)! *
                                double.parse(homeController
                                    .settings.value.data![23].value!));
                          }
                        });
                  }),
                  Text(
                    // 'Use Rewards: ${12}',
                    'System Reward',
                    style: TextStyle(fontSize: fontSmall, color: primaryText),
                  ),
                  const Spacer(),
                  Obx(() {
                    return Text(
                      'Payable Amount: ${homeController.settings.value.data![11].value}${homeController.reward.value || homeController.isNFCRewardSelected.value ? (totalPayable - rewardDiscount).toStringAsFixed(2) : totalPayable.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: fontSmall, color: primaryText),
                    );
                  }),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    return Checkbox(
                        value: homeController.isNFCRewardSelected.value,
                        side: BorderSide(color: textSecondary),
                        onChanged: (checked) {
                          if (homeController.isNFCRewardSelected.value ==
                              true) {
                            homeController.isNFCRewardSelected.value = false;
                          } else {
                            homeController.isNFCRewardSelected.value = checked!;
                            homeController.reward.value = !checked;
                          }
                          rewardDiscount = ((nfcCustomerInfo == null
                                  ? 0
                                  : nfcCustomerInfo!.data!.pointsAcquired)! *
                              double.parse(homeController
                                  .settings.value.data![23].value!));
                          homeController.reward.refresh();
                        });
                  }),
                  Text(
                    // 'Use Rewards: ${12}',
                    'Reward Card',
                    style: TextStyle(fontSize: fontSmall, color: primaryText),
                  ),
                  const Spacer(),
                  FutureBuilder<bool>(
                      future: NfcManager.instance.isAvailable(),
                      builder: (context, ss) {
                        return ss.data != true
                            ? Center(
                                child: Text(
                                  'NFC is not available',
                                  style: TextStyle(
                                      fontSize: fontSmall, color: red),
                                ),
                              )
                            : ValueListenableBuilder<dynamic>(
                                valueListenable: nfcResult,
                                builder: (context, value, _) {
                                  tagRead();

                                  return Row(
                                    children: [
                                      Text(
                                        'Reward Amount: ',
                                        style: TextStyle(
                                            fontSize: fontSmall,
                                            color: primaryText),
                                      ),
                                      nfcResult.value
                                          ? const SizedBox(
                                              height: 14,
                                              width: 14,
                                              child:
                                                  CircularProgressIndicator())
                                          : Text(
                                              "${nfcCustomerInfo == null ? 0 : nfcCustomerInfo!.data!.pointsAcquired! * double.parse(homeController.settings.value.data![23].value!)}",
                                              style: TextStyle(
                                                  fontSize: fontSmall,
                                                  color: primaryText),
                                            )
                                    ],
                                  );
                                },
                              );
                      }),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                "Payment Method",
                style: TextStyle(fontSize: fontSmall, color: primaryText),
              ),
              Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryText, width: 1)),
                  child: Obx(() {
                    return DropdownButton<String>(
                      items: paymentType.map((dynamic val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child:
                                Text(val, style: TextStyle(color: primaryText)),
                          ),
                        );
                      }).toList(),
                      borderRadius: BorderRadius.circular(8),
                      underline: const SizedBox(),
                      isExpanded: true,
                      dropdownColor: primaryBackground,
                      value: homeController.payMethod.value,
                      onChanged: (value) {
                        homeController.payMethod.value = value!;
                        homeController.update(["finalizeOrder"]);
                        if (homeController.payMethod.value == "Card") {
                          textController.text = homeController.reward.value ||
                                  homeController.isNFCRewardSelected.value
                              ? (totalPayable - rewardDiscount)
                                  .toStringAsFixed(2)
                              : totalPayable.toStringAsFixed(2);
                        } else {
                          textController.text = "";
                        }
                      },
                    );
                  })),
              const SizedBox(height: 15),
              if (homeController.payMethod.value == "Card")
                paymentMethods(
                    context,
                    customer,
                    homeController.reward.value ||
                            homeController.isNFCRewardSelected.value
                        ? (totalPayable - rewardDiscount).toStringAsFixed(2)
                        : totalPayable.toStringAsFixed(2)),
              const SizedBox(height: 15),
              Text(
                'Give Amount',
                style: TextStyle(fontSize: fontSmall, color: primaryText),
              ),
              SizedBox(
                height: 40,
                child: TextFormField(
                    controller: textController,
                    keyboardType: TextInputType.number,
                    onChanged: (text) =>
                        homeController.giveAmount.value = double.parse(text),
                    style:
                        TextStyle(fontSize: fontVerySmall, color: primaryText),
                    decoration: InputDecoration(
                        fillColor: secondaryBackground,
                        hintText: " Enter given amount",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: textSecondary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: textSecondary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.only(left: 5),
                        hintStyle: TextStyle(
                            fontSize: fontVerySmall, color: primaryText))),
              ),
              const SizedBox(height: 15),
              Text(
                "Change Amount",
                style: TextStyle(fontSize: fontSmall, color: primaryText),
              ),
              Container(
                  height: 40,
                  width: Size.infinite.width,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryText, width: 1)),
                  child: Obx(() {
                    return Text(
                      (homeController.giveAmount.value -
                              (homeController.reward.value ||
                                      homeController.isNFCRewardSelected.value
                                  ? (totalPayable - rewardDiscount)
                                  : totalPayable))
                          .toStringAsFixed(2),
                      style: TextStyle(fontSize: fontSmall, color: primaryText),
                    );
                  })),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  normalButton('Close', textSecondary, white, onPressed: () {
                    Get.back();
                  }),
                  const SizedBox(width: 20),
                  normalButton('Submit', primaryColor, white,
                      onPressed: () async {
                    // showCustomDialog(
                    //     context, "", orderInvoice(context, homeController.payMethod.value), 0, 750);
                    if (textController.text.isEmpty) {
                      Utils.showSnackBar("Enter given amount");
                      return;
                    }
                    Utils.showLoading();
                    bool done = await homeController.orderPayment();

                    if (done) {
                      await homeController.getOrders();
                      showCustomDialog(
                          context,
                          "",
                          orderInvoice(context, homeController.payMethod.value),
                          50,
                          750);

                      /*await homeController.cancelOrder(homeController.orders.value //77777
                          .data![homeController.selectedOrder.value].id!
                          .toInt());
                      homeController.getOrders();*/
                    } else {
                      Utils.hidePopup();
                      Utils.showSnackBar("An error occur");
                    }
                  }),
                ],
              )
            ],
          ),
        );
      });
}

SizedBox paymentMethods(BuildContext context, Customer customer, String total) {
  return SizedBox(
    height: 40,
    width: double.infinity,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        GestureDetector(
          onTap: () async {
            await Sumup.init(affiliateKey);
            var isLogged = await Sumup.isLoggedIn;

            if (isLogged != null && !isLogged) {
              await Sumup.login();
            }

            isLogged = await Sumup.isLoggedIn;

            if (isLogged ?? false) {
              try {
                await Sumup.openSettings();
                await Sumup.wakeUpTerminal();

                var payment = SumupPayment(
                  title: customer.data?.name ?? "Order payment",
                  total: double.parse(total),
                  currency: 'GBP',
                  foreignTransactionId: '',
                  saleItemsCount: 1,
                  skipSuccessScreen: false,
                  skipFailureScreen: true,
                  tipOnCardReader: true,
                  customerEmail: customer.data?.email ?? "",
                  customerPhone: customer.data?.phone ?? "",
                );
                var request = SumupPaymentRequest(payment);
                var checkout = await Sumup.checkout(request);

                if (checkout.success ?? false) {
                  homeController.getOrders();
                  Utils.showSnackBar("Payment Successful");
                  showCustomDialog(
                      context,
                      "",
                      orderInvoice(context, homeController.payMethod.value),
                      50,
                      750);
                } else {
                  Utils.showSnackBar("Payment Failed");
                }
              } catch (e) {
                Utils.showSnackBar("Something went wrong");
              }
            }
          },
          child: banksLogo("sumup.png"),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () async {
            PaymentController paymentController = Get.put(PaymentController());
            await paymentController.createDeviceCode();
            showCustomDialog(
              context,
              "Square Device Code",
              squareDeviceCodeCreation(),
              200,
              500,
            );
          },
          child: banksLogo("square.png"),
        ),
      ],
    ),
  );
}

SizedBox banksLogo(String name) {
  return SizedBox(
    height: 30,
    width: 80,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Image.asset(
        'assets/$name',
        fit: BoxFit.fill,
      ),
    ),
  );
}

Widget orderInvoice(BuildContext context, String method) {
  bool isTableAvailable =
      (homeController.order.value.data!.tables!.data != null &&
          homeController.order.value.data!.tables!.data!.isNotEmpty);
  double dueOrChange = (homeController.giveAmount.value -
      double.parse(homeController.order.value.data!.grandTotal!));
  return Column(
    children: [
      Expanded(
          flex: 18,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(children: [
                Center(
                  child: Text(
                    'klio',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                        color: textSecondary),
                  ),
                ),
                Center(
                  child: Text(
                    'We are just preparing your food, and will bring it to \nyour table as soon as possible',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontVerySmall,
                        color: textSecondary),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: isTableAvailable
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.center,
                  children: [
                    if (isTableAvailable)
                      textMixer(
                          "Table: ",
                          Utils.getTables(homeController
                              .order.value.data!.tables!.data!
                              .toList()),
                          MainAxisAlignment.start),
                    textMixer(
                        "Order Number: ",
                        homeController.order.value.data!.invoice.toString(),
                        MainAxisAlignment.start),
                  ],
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Order Summary',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontVeryBig,
                        color: primaryText),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        "SL",
                        style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Name",
                        style: TextStyle(
                            fontSize: fontVerySmall, color: primaryText),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Variant Name",
                        style: TextStyle(
                            fontSize: fontVerySmall, color: primaryText),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "Price",
                        style: TextStyle(
                            fontSize: fontVerySmall, color: primaryText),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "Qty",
                        style: TextStyle(
                            fontSize: fontVerySmall, color: primaryText),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "Vat(%)",
                        style: TextStyle(
                            fontSize: fontVerySmall, color: primaryText),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "Total",
                        style: TextStyle(
                            fontSize: fontVerySmall, color: primaryText),
                      ),
                    ),
                  ],
                ),
                Divider(color: textSecondary, thickness: 1, height: 1),
                Expanded(
                    flex: 2,
                    child: ListView.builder(
                        itemCount: homeController
                            .order.value.data!.orderDetails!.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        (index + 1).toString(),
                                        style: TextStyle(
                                            fontSize: fontVerySmall,
                                            color: primaryText,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        homeController
                                            .order
                                            .value
                                            .data!
                                            .orderDetails!
                                            .data![index]
                                            .food!
                                            .name
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: fontVerySmall,
                                            color: textSecondary,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        homeController
                                            .order
                                            .value
                                            .data!
                                            .orderDetails!
                                            .data![index]
                                            .variant!
                                            .name
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: fontVerySmall,
                                            color: textSecondary,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "${homeController.settings.value.data![11].value}${homeController.order.value.data!.orderDetails!.data![index].price}",
                                        style: TextStyle(
                                            fontSize: fontVerySmall,
                                            color: textSecondary,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        homeController.order.value.data!
                                            .orderDetails!.data![index].quantity
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: fontVerySmall,
                                            color: textSecondary,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        homeController.order.value.data!
                                            .orderDetails!.data![index].vat!,
                                        style: TextStyle(
                                            fontSize: fontVerySmall,
                                            color: textSecondary,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "${homeController.settings.value.data![11].value}${homeController.order.value.data!.orderDetails!.data![index].totalPrice}",
                                        style: TextStyle(
                                            fontSize: fontVerySmall,
                                            color: textSecondary,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Divider(
                                  color: textSecondary,
                                  thickness: 0.1,
                                  height: 0.1),
                              homeController.order.value.data!.orderDetails!
                                          .data![index].addons!.data!.length >
                                      0
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              for (var addons in homeController
                                                  .order
                                                  .value
                                                  .data!
                                                  .orderDetails!
                                                  .data![index]
                                                  .addons!
                                                  .data!
                                                  .toList())
                                                Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 2),
                                                    margin: const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        color: alternate,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                10)),
                                                    child: Text(
                                                        '${addons.name}  ${addons.quantity}x${addons.price}',
                                                        style: TextStyle(
                                                            fontSize:
                                                                fontVerySmall,
                                                            color:
                                                                textSecondary)))
                                            ],
                                          ),
                                          Divider(
                                              color: textSecondary,
                                              thickness: 0.1,
                                              height: 0.1),
                                        ],
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          );
                        })),
                const SizedBox(height: 10),
                Divider(color: textSecondary, thickness: 0.1, height: 0.1),
                textMixer2(
                    "Order Type",
                    homeController.order.value.data!.type.toString(),
                    MainAxisAlignment.spaceBetween),
                textMixer2(
                    "Subtotal",
                    '${homeController.settings.value.data![11].value}${Utils.orderSubTotal(homeController.order.value.data!.orderDetails!.data!.toList()).toStringAsFixed(2)}',
                    MainAxisAlignment.spaceBetween),
                textMixer2(
                    "Discount",
                    '${homeController.settings.value.data![11].value}' +
                        homeController.order.value.data!.discount.toString(),
                    MainAxisAlignment.spaceBetween),
                textMixer2(
                    "Vat",
                    Utils.vatTotal2(homeController
                            .order.value.data!.orderDetails!.data!
                            .toList())
                        .toStringAsFixed(2),
                    MainAxisAlignment.spaceBetween),
                textMixer2(
                    "Service",
                    '${homeController.settings.value.data![11].value}' +
                        homeController.order.value.data!.serviceCharge
                            .toString(),
                    MainAxisAlignment.spaceBetween),
                textMixer2(
                    "Give Amount",
                    homeController.giveAmount.value.toStringAsFixed(2),
                    MainAxisAlignment.spaceBetween),
                textMixer2(
                    dueOrChange < 0 ? "Due Amount" : "Change Amount",
                    dueOrChange.abs().toStringAsFixed(2),
                    MainAxisAlignment.spaceBetween),
                textMixer2(
                    "Payment Method", method, MainAxisAlignment.spaceBetween),
                textMixer2(
                    "Delivery Charge",
                    '${homeController.settings.value.data![11].value}' +
                        homeController.order.value.data!.deliveryCharge
                            .toString(),
                    MainAxisAlignment.spaceBetween),
                Divider(color: textSecondary, thickness: 0.1, height: 0.1),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    'Total Payable Amount',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSmall,
                        color: primaryText),
                  ),
                ),
                Center(
                  child: Text(
                    '${homeController.settings.value.data![11].value}${homeController.order.value.data!.grandTotal.toString()}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSmall,
                        color: primaryText),
                  ),
                ),
                Center(
                  child: Text(
                    'Thanks for ordering with klio',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: fontSmall,
                        color: primaryText),
                  ),
                ),
                const SizedBox(height: 10),
              ]))),
      Expanded(
        flex: 2,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: MaterialButton(
              elevation: 0,
              color: primaryColor,
              minWidth: 130,
              onPressed: () async {
                // DefaultPrinter.startPrinting();
                Utils.showSnackBar("Printing... wait!");
                bool isTableAvailable =
                    (homeController.order.value.data!.tables!.data != null &&
                        homeController
                            .order.value.data!.tables!.data!.isNotEmpty);
                await SumniPrinter.printText(isTableAvailable);
                CustomerDisplay.sleep();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/print.png',
                    color: white,
                    height: 15,
                    width: 15,
                  ),
                  const SizedBox(width: 5),
                  const Text("Print",
                      style: TextStyle(color: white, fontSize: fontSmall)),
                ],
              )),
        ),
      ),
    ],
  );
}

// Widget addMisc(BuildContext context) {
//   return Container(
//     height: Size.infinite.height,
//     width: Size.infinite.width,
//     padding: EdgeInsets.fromLTRB(30, 0, 30, 30),
//     child: ListView(children: [
//       textRow1('Name', 'Variant Name'),
//       textFieldRow1('Enter menu name', 'Normal'),
//       SizedBox(height: 10),
//       textRow1('Variant Price', 'Processing Time'),
//       textFieldRow1('000.00', 'Enter food processing time'),
//       SizedBox(height: 10),
//       textRow1('Vat (%)', 'Calorie'),
//       textFieldRow1('food vat', '000.00'),
//       SizedBox(height: 10),
//       textRow1('Image (130x130)', 'Select Menu Meal Period'),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//           Expanded(
//               flex: 1,
//               child: SizedBox(
//                   height: 40,
//                   child: MaterialButton(
//                       elevation: 0,
//                       color: primaryBackground,
//                       onPressed: () {},
//                       child: Text(
//                         'No file chosen',
//                         style: TextStyle(
//                             color: textSecondary, fontSize: fontSmall),
//                       ))
//                   // child: normalButton('No file chosen', primaryColor, primaryColor),
//                   )),
//           SizedBox(width: 20),
//           Expanded(
//               flex: 1,
//               child: SizedBox(
//                 height: 40,
//                 child: TextFormField(
//                     keyboardType: TextInputType.text,
//                     style: TextStyle(
//                         fontSize: fontVerySmall, color: textSecondary),
//                     decoration: InputDecoration(
//                         fillColor: secondaryBackground,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                         hintStyle: TextStyle(
//                             fontSize: fontVerySmall, color: textSecondary))),
//               )),
//         ],
//       ),
//       SizedBox(height: 10),
//       textRow1('Select Menu Category', 'Select Menu Addons'),
//       textFieldRow1('', ''),
//       SizedBox(height: 10),
//       textRow1('Select Menu Allergies', ''),
//       SizedBox(
//         height: 35,
//         child: TextFormField(
//             keyboardType: TextInputType.text,
//             style: TextStyle(fontSize: fontVerySmall, color: textSecondary),
//             decoration: InputDecoration(
//                 fillColor: secondaryBackground,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 hintStyle:
//                     TextStyle(fontSize: fontVerySmall, color: textSecondary))),
//       ),
//       SizedBox(height: 10),
//       textRow1('Menu Description', ''),
//       TextFormField(
//           keyboardType: TextInputType.text,
//           maxLines: 2,
//           style: TextStyle(fontSize: fontSmall, color: textSecondary),
//           decoration: InputDecoration(
//             fillColor: secondaryBackground,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(6),
//             ),
//             hintStyle: TextStyle(fontSize: fontVerySmall, color: textSecondary),
//           )),
//       SizedBox(height: 10),
//       Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           normalButton('Submit', primaryColor, white, onPressed: () {}),
//         ],
//       ),
//     ]),
//   );
// }

Widget addNewMenuForm(FoodManagementController foodCtlr) {
  return Container(
    height: Size.infinite.height,
    width: Size.infinite.width,
    padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
    child: Form(
      key: foodCtlr.uploadMenuFormKey,
      child: ListView(children: [
        textRow('Name', 'Variant Price'),
        textFieldRow('Enter menu name', 'Enter variant price',
            controller1: foodCtlr.nameTextCtlr,
            controller2: foodCtlr.varinetPriceEditingCtlr,
            validator1: foodCtlr.textValidator,
            validator2: foodCtlr.textValidator,
            textInputType1: TextInputType.text,
            textInputType2: TextInputType.number),
        const SizedBox(height: 10),
        textRow('Vat (%)', 'Processing Time'),
        textFieldRow('Enter VAT', 'Processing time ( in Min )',
            controller1: foodCtlr.vatEditingCtlr,
            controller2: foodCtlr.processTimeEditingCtlr,
            validator1: foodCtlr.textValidator,
            validator2: foodCtlr.textValidator,
            textInputType1: TextInputType.number,
            textInputType2: TextInputType.number),
        const SizedBox(height: 10),
        textRow('Image (130x130)', 'Calorie'),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                flex: 1,
                child: SizedBox(
                    height: 35,
                    child: MaterialButton(
                      elevation: 0,
                      color: primaryBackground,
                      onPressed: () async {
                        foodCtlr.menuStoreImage = await foodCtlr.getImage();
                      },
                      child: GetBuilder<FoodManagementController>(
                          builder: (context) {
                        return Text(
                          foodCtlr.menuStoreImage == null
                              ? 'No file chosen'
                              : basename(foodCtlr.menuStoreImage!.path
                                  .split(Platform.pathSeparator.tr)
                                  .last),
                          style: TextStyle(
                              color: textSecondary, fontSize: fontSmall),
                        );
                      }),
                    )
                    // child: normalButton('No file chosen', primaryColor, primaryColor),
                    )),
            const SizedBox(width: 20),
            Expanded(
              flex: 1,
              child: SizedBox(
                //  height: 45,
                child: TextFormField(
                    onChanged: (text) async {},
                    controller: foodCtlr.caloriesEditingCtlr,
                    onEditingComplete: () async {},
                    keyboardType: TextInputType.number,
                    maxLines: 1,
                    validator: foodCtlr.textValidator,
                    style: TextStyle(fontSize: fontSmall, color: textSecondary),
                    decoration: InputDecoration(
                      hintText: "Enter Calories",
                      fillColor: secondaryBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      hintStyle: TextStyle(
                          fontSize: fontVerySmall, color: textSecondary),
                    )),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        textRow('Select Menu Meal Period', 'Select Menu Category'),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                flex: 1,
                child:
                    GetBuilder<FoodManagementController>(builder: (controller) {
                  return MultiSelectDropDown(
                    backgroundColor: secondaryBackground,
                    optionsBackgroundColor: secondaryBackground,
                    selectedOptionTextColor: primaryText,
                    selectedOptionBackgroundColor: primaryColor,
                    optionTextStyle:
                        TextStyle(color: primaryText, fontSize: 16),
                    onOptionSelected: (List<ValueItem> selectedOptions) {
                      foodCtlr.uploadMealPeriodIdList = selectedOptions
                          .map((ValueItem e) => int.parse(e.value!))
                          .toList();
                      print(foodCtlr.uploadMealPeriodIdList);
                    },
                    // selectedOptions: foodCtlr.foodSingleItemDetails.value.data!.addons!.data!.map((MenuAddon e) {
                    //   return ValueItem(
                    //     label:e.name!,
                    //     value: e.id.toString(),
                    //   );
                    // }).toList(),
                    options: controller.addMenuModel.mealPeriods
                        .map((MealPeriods e) {
                      return ValueItem(
                        label: e.name,
                        value: e.id.toString(),
                      );
                    }).toList(),
                    hint: 'Select Meal Period',
                    selectionType: SelectionType.multi,
                    chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                    dropdownHeight: 300,
                    selectedOptionIcon: const Icon(Icons.check_circle),
                    inputDecoration: BoxDecoration(
                      color: secondaryBackground,
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      border: Border.all(
                        color: primaryBackground,
                      ),
                    ),
                  );
                })),
            const SizedBox(width: 20),
            Expanded(
                flex: 1,
                child:
                    GetBuilder<FoodManagementController>(builder: (controller) {
                  return MultiSelectDropDown(
                    backgroundColor: secondaryBackground,
                    optionsBackgroundColor: secondaryBackground,
                    selectedOptionTextColor: primaryText,
                    selectedOptionBackgroundColor: primaryColor,
                    optionTextStyle:
                        TextStyle(color: primaryText, fontSize: 16),
                    onOptionSelected: (List<ValueItem> selectedOptions) {
                      foodCtlr.uploadMenuCategoryIdList = selectedOptions
                          .map((ValueItem e) => int.parse(e.value!))
                          .toList();
                    },
                    // selectedOptions: foodCtlr.foodSingleItemDetails.value.data!.addons!.data!.map((MenuAddon e) {
                    //   return ValueItem(
                    //     label:e.name!,
                    //     value: e.id.toString(),
                    //   );
                    // }).toList(),
                    options:
                        controller.addMenuModel.categories.map((Categories e) {
                      return ValueItem(
                        label: e.name,
                        value: e.id.toString(),
                      );
                    }).toList(),
                    hint: 'Select Menu Category',
                    selectionType: SelectionType.multi,
                    chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                    dropdownHeight: 300,
                    selectedOptionIcon: const Icon(Icons.check_circle),
                    inputDecoration: BoxDecoration(
                      color: secondaryBackground,
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      border: Border.all(
                        color: primaryBackground,
                      ),
                    ),
                  );
                })),
          ],
        ),
        const SizedBox(height: 10),
        textRow('Select Menu Addons', 'Select Menu Allergies '),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                flex: 1,
                child:
                    GetBuilder<FoodManagementController>(builder: (controller) {
                  return MultiSelectDropDown(
                    backgroundColor: secondaryBackground,
                    optionsBackgroundColor: secondaryBackground,
                    selectedOptionTextColor: primaryText,
                    selectedOptionBackgroundColor: primaryColor,
                    optionTextStyle:
                        TextStyle(color: primaryText, fontSize: 16),
                    onOptionSelected: (List<ValueItem> selectedOptions) {
                      foodCtlr.uploadMenuAddonsIdList = selectedOptions
                          .map((ValueItem e) => int.parse(e.value!))
                          .toList();
                    },
                    // selectedOptions: foodCtlr.foodSingleItemDetails.value.data!.addons!.data!.map((MenuAddon e) {
                    //   return ValueItem(
                    //     label:e.name!,
                    //     value: e.id.toString(),
                    //   );
                    // }).toList(),
                    options: controller.addMenuModel.addons.map((Addons e) {
                      return ValueItem(
                        label: e.name,
                        value: e.id.toString(),
                      );
                    }).toList(),
                    hint: 'Select Menu Addons',
                    selectionType: SelectionType.multi,
                    chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                    dropdownHeight: 300,
                    selectedOptionIcon: const Icon(Icons.check_circle),
                    inputDecoration: BoxDecoration(
                      color: secondaryBackground,
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      border: Border.all(
                        color: primaryBackground,
                      ),
                    ),
                  );
                })),
            const SizedBox(width: 20),
            Expanded(
                flex: 1,
                child:
                    GetBuilder<FoodManagementController>(builder: (controller) {
                  return MultiSelectDropDown(
                    backgroundColor: secondaryBackground,
                    optionsBackgroundColor: secondaryBackground,
                    selectedOptionTextColor: primaryText,
                    selectedOptionBackgroundColor: primaryColor,
                    optionTextStyle:
                        TextStyle(color: primaryText, fontSize: 16),
                    onOptionSelected: (List<ValueItem> selectedOptions) {
                      foodCtlr.uploadMenuAllergyIdList = selectedOptions
                          .map((ValueItem e) => int.parse(e.value!))
                          .toList();
                    },
                    // selectedOptions: foodCtlr.foodSingleItemDetails.value.data!.addons!.data!.map((MenuAddon e) {
                    //   return ValueItem(
                    //     label:e.name!,
                    //     value: e.id.toString(),
                    //   );
                    // }).toList(),
                    options: controller.addMenuModel.allergies
                        .map((add_menu_model.Allergies e) {
                      return ValueItem(
                        label: e.name,
                        value: e.id.toString(),
                      );
                    }).toList(),
                    hint: 'Select Menu Allergies',
                    selectionType: SelectionType.multi,
                    chipConfig: const ChipConfig(wrapType: WrapType.wrap),
                    dropdownHeight: 300,
                    selectedOptionIcon: const Icon(Icons.check_circle),
                    inputDecoration: BoxDecoration(
                      color: secondaryBackground,
                      borderRadius: const BorderRadius.all(Radius.circular(6)),
                      border: Border.all(
                        color: primaryBackground,
                      ),
                    ),
                  );
                })),
          ],
        ),
        const SizedBox(height: 10),
        const SizedBox(height: 10),
        textRow('Menu Description', ''),
        TextFormField(
            onChanged: (text) async {},
            onEditingComplete: () async {},
            keyboardType: TextInputType.text,
            validator: foodCtlr.textValidator,
            controller: foodCtlr.descriptionEditingCtlr,
            maxLines: 2,
            style: TextStyle(fontSize: fontSmall, color: textSecondary),
            decoration: InputDecoration(
              fillColor: secondaryBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              hintStyle:
                  TextStyle(fontSize: fontVerySmall, color: textSecondary),
            )),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            normalButton('Submit', primaryColor, white, onPressed: () async {
              if (foodCtlr.uploadMenuFormKey.currentState!.validate()) {
                if (foodCtlr.uploadMenuCategoryIdList.isEmpty) {
                  Utils.showSnackBar("Please select menu category");
                } else if (foodCtlr.menuStoreImage == null) {
                  Utils.showSnackBar("Please select menu image");
                } else {
                  await foodCtlr.addMenu(
                    foodCtlr.nameTextCtlr.text,
                    foodCtlr.varinetPriceEditingCtlr.text,
                    foodCtlr.processTimeEditingCtlr.text,
                    foodCtlr.vatEditingCtlr.text,
                    foodCtlr.caloriesEditingCtlr.text,
                    foodCtlr.descriptionEditingCtlr.text,
                    foodCtlr.uploadMealPeriodIdList,
                    foodCtlr.uploadMenuAddonsIdList,
                    foodCtlr.uploadMenuAllergyIdList,
                    foodCtlr.uploadMenuCategoryIdList,
                  );

                  await homeController.getMenuByKeyword();
                  homeController.filteredMenu.refresh();
                  foodCtlr.nameTextCtlr.clear();
                  foodCtlr.varinetPriceEditingCtlr.clear();
                  foodCtlr.vatEditingCtlr.clear();
                  foodCtlr.processTimeEditingCtlr.clear();
                  foodCtlr.caloriesEditingCtlr.clear();
                  foodCtlr.descriptionEditingCtlr.clear();
                  foodCtlr.menuStoreImage = null;
                }
              }
            }),
          ],
        ),
      ]),
    ),
  );
}

Widget showNotification() {
  return Container(
    height: Size.infinite.height,
    width: Size.infinite.width,
    padding: const EdgeInsets.fromLTRB(30, 0, 30, 30),
    child: GetBuilder(builder: (HomeController homeController) {
      return ListView.builder(
          itemCount: homeController.onlineOrder.value.data!.length,
          itemBuilder: (ctx, index) {
            return Column(
              children: [
                ListTile(
                  title: Text(
                      homeController.onlineOrder.value.data![index].invoice!
                          .toString(),
                      style: TextStyle(color: primaryText)),
                  subtitle: Text(
                      homeController.onlineOrder.value.data![index].grandTotal!
                          .toString(),
                      style: TextStyle(color: primaryText)),
                  leading: Image.asset(
                    'assets/takeway.png',
                    color: primaryColor,
                  ),
                  trailing:
                      Text('1 month ago', style: TextStyle(color: primaryText)),
                  onTap: () {
                    showWarningDialog(
                        'Are you sure? \nYou want accept this order...!',
                        onAccept: () async {
                      Utils.showLoading();
                      bool done = await homeController.acceptOrder(
                          homeController.onlineOrder.value.data![index].id!
                              .toInt());
                      Utils.hidePopup();
                      if (done) {
                        homeController.getOrders();
                        homeController.getOnlineOrder(0);
                        homeController.orders.refresh();
                        Utils.hidePopup();
                        Utils.hidePopup();
                        Utils.showSnackBar("Order added successfully");
                      } else {
                        Utils.showSnackBar("Failed! Try again");
                      }
                    });
                  },
                ),
                Divider(color: textSecondary, thickness: 0.1, height: 0.1),
              ],
            );
          });
    }),
  );
}
