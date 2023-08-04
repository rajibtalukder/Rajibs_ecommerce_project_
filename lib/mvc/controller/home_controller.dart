import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:klio_staff/mvc/model/Customer.dart';
import 'package:klio_staff/mvc/model/settings.dart';
import 'package:klio_staff/utils/utils.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import '../../constant/value.dart';
import '../../service/api/api_client.dart';
import '../../service/local/shared_pref.dart';
import '../model/Tables.dart';
import '../model/dash_model.dart';
import '../model/menu.dart';
import '../model/category.dart';
import '../model/customers.dart';
import '../model/customers.dart' as cus;

import '../model/menus.dart';
import '../model/online_order.dart';
import '../model/order.dart';
import '../model/orders.dart';
import '../model/pos_riders.dart' as pos_riders;
import '../model/pos_riders.dart';
import '../model/riders_model.dart';
import '../model/riders_model.dart' as riders_model;

import '../model/user.dart';
import 'error_controller.dart';

class HomeController extends GetxController with ErrorController {
  Rx<User> user = User().obs;
  Rx<Category> category = Category().obs;
  Rx<Menus> menus = Menus(data: []).obs;
  Rx<Customers> customers = Customers().obs;
  Rx<RidersModel> deliveryMans = RidersModel().obs;
  Rx<PosRiders> posRiders = PosRiders(data: []).obs;
  Rx<Orders> orders = Orders().obs;
  Rx<Orders> searchedOrders = Orders().obs;
  Rx<Order> order = Order().obs;
  Rx<OnlineOrder> onlineOrder = OnlineOrder().obs;
  Rx<Settings> settings = Settings().obs;
  Rx<TableList> tables = TableList(data: []).obs;
  Rx<TextEditingController> controllerName =
      TextEditingController(text: '').obs;
  Rx<TextEditingController> lastNameComtroller =
      TextEditingController(text: '').obs;
  Rx<TextEditingController> controllerEmail =
      TextEditingController(text: '').obs;
  Rx<TextEditingController> controllerPhone =
      TextEditingController(text: '').obs;
  Rx<TextEditingController> controllerAddress =
      TextEditingController(text: '').obs;
  Rx<TextEditingController> controllerPassword =
      TextEditingController(text: '').obs;
  Rx<TextEditingController> controllerConfirmPass =
      TextEditingController(text: '').obs;
  RxBool withoutTable = false.obs;
  int orderTypeNumber = 1;
  Rx<DashData> dashData = DashData().obs;

  // temp variables
  RxList filteredMenu = [].obs;
  RxString customerName = ''.obs;
  RxString riderName = ''.obs;
  Rx<MenuData> menuData = MenuData().obs;
  List<MenuData> cardList = [];
  String selectedSearchType = "table";
  TextEditingController searchController = TextEditingController();

  // RxDouble variantPrice = 0.0.obs;
  RxDouble discount = 0.0.obs;
  RxString discType = 'In Flat Amount'.obs;
  RxDouble giveAmount = 0.0.obs;
  RxString payMethod = 'Cash'.obs;
  int orderUpdateId = 0;

  // ui variables
  RxInt topBtnPosition = 1.obs;
  RxBool isUpdate = false.obs;
  RxBool reward = false.obs;
  RxBool isNFCRewardSelected = false.obs;
  RxInt selectedOrder = (-1).obs;
  RxInt currentPage = 0.obs;

  bool haveMoreMenu = true;
  int menuPageNumber = 1;
  bool isLoading = false;

  Future<void> loadHomeData() async {
    token = (await SharedPref().getValue('token'))!;
    try {
      await SunmiPrinter.bindingPrinter(); // must bind the printer first
      await SunmiPrinter.lcdInitialize(); //Initialize the LCD screen
    } catch (e) {
      Utils.showSnackBar(e.toString());
    }
    Utils.showLoading();
    await getCurrentUserData();
    getOrders();
    getCustomers();
    getPosRiders();
    await getCategory();
    await getMenuByKeyword();
    getOnlineOrder(0);
    Utils.hidePopup();
    Utils.hidePopup();
    Utils.hidePopup();
  }

  Future<void> getCurrentUserData() async {
    var response = await ApiClient()
        .get('user', header: Utils.apiHeader)
        .catchError(handleApiError);

    /// check token validity to logout later
    if (response == null) return;
    user.value = userFromJson(response);
    response = await ApiClient()
        .get('setting', header: Utils.apiHeader)
        .catchError(handleApiError);
    settings.value = settingsFromJson(response);
  }

  Future<void> getCategory() async {
    var response = await ApiClient()
        .get('pos/category', header: Utils.apiHeader)
        .catchError(handleApiError);
    category.value = categoryFromJson(response);
  }

  Future<void> getDashboardData() async {
    token = (await SharedPref().getValue('token'))!;
    Utils.showLoading();
    var response = await ApiClient()
        .get('dashboard', header: Utils.apiHeader)
        .catchError(handleApiError);
    dashData.value = dashDataFromJson(response);
    Utils.hidePopup();
  }

  Future<void> getMenuByKeyword({String keyword = ''}) async {
    if (!haveMoreMenu) {
      return;
    }
    if (keyword != '') {
      menus.value.data!.clear();
    }
    isLoading = true;
    //Map<String, String> qParams = {'keyword': keyword};
    //String endPoint = "pos/menu?page=$menuPageNumber";
    String endPoint = keyword == ''
        ? "pos/menu?page=$menuPageNumber"
        : "pos/menu?page=$menuPageNumber&keyword=$keyword";
    var response = await ApiClient().get(endPoint, header: Utils.apiHeader);
    // .catchError(handleApiError);

    var temp = menuFromJson(response);
    List<MenuData> menuItem = temp.data!;

    menus.value.data?.addAll(menuItem);

    //menus.value = menuFromJson(response);

    filteredMenu.value = Utils.filterCategory(menus.value, -1)!;

    var res = json.decode(response);
    int to = res['meta']['to'];
    int total = res['meta']['total'];

    if (total <= to) {
      haveMoreMenu = false;
    }

    menuPageNumber++;
    isLoading = false;
    filteredMenu.refresh();
  }

  Future<void> getCustomers() async {
    var response = await ApiClient()
        .get('pos/customer', header: Utils.apiHeader)
        .catchError(handleApiError);

    var temp = customerFromJson(response);
    List<cus.Datum> customersData = temp.data!;

    customers.value.data = [cus.Datum(id: 0, name: "None")];
    customers.value.data?.addAll(customersData);

    //customers.value = customerFromJson(response);
    customers.refresh();
    customerName.value = "None";
  }

  Future<void> getPosRiders() async {
    var response = await ApiClient()
        .get('pos/rider', header: Utils.apiHeader)
        .catchError(handleApiError);

    var temp = posRidersModelFromJson(response);
    List<pos_riders.Data> ridersData = temp.data ?? [];

    if (posRiders.value.data.isNotEmpty) {
      posRiders.value.data.clear();
    }

    posRiders.value.data.insert(0, pos_riders.Data(id: 0, name: "None"));
    riderName.value = "None";
    posRiders.value.data.addAll(ridersData);
    update(["UpdateDeliveryManUi"]);
  }

  Future<Customer?> getCustomer(String id) async {
    var response = await ApiClient()
        .get('pos/customer/$id', header: Utils.apiHeader)
        .catchError(handleApiError);
    if(response == null){
      Utils.showSnackBar("Customer not found");
      return null;
    }
    return cusFromJson(response);
  }

  Future<riders_model.Data> getRider(String id) async {
    var response = await ApiClient()
        .get('client/rider/$id', header: Utils.apiHeader)
        .catchError(handleApiError);

    return riderFromJson(response);
  }

  Future<void> getOrders() async {
    var response = await ApiClient()
        .get('pos/order', header: Utils.apiHeader)
        .catchError(handleApiError);
    if (response == null) return;
    orders.value = ordersFromJson(response);
    searchedOrders.value = orders.value;
    orders.refresh();
  }

  Future<void> searchOrders() async {
    var response = await ApiClient()
        .get('pos/order?keyword=${searchController.text}&search=$selectedSearchType', header: Utils.apiHeader)
        .catchError(handleApiError);
    if (response == null) return;
    searchedOrders.value = ordersFromJson(response);
    searchedOrders.refresh();
  }

  Future<void> cancelOrder(int id) async {
    var response = await ApiClient()
        .post('pos/order/$id/cancel', jsonEncode({}), header: Utils.apiHeader)
        .catchError(handleApiError);
    if (response == null) return;
  }

  Future<bool> acceptOrder(int id) async {
    var response = await ApiClient()
        .put('pos/order/$id/accept', jsonEncode({}), header: Utils.apiHeader)
        .catchError(handleApiError);
    if (response == null) false;
    return true;
  }

  Future<void> getOrder(int id) async {
    var response = await ApiClient()
        .get('pos/order/$id', header: Utils.apiHeader)
        .catchError(handleApiError);
    if (response == null) {
      Utils.showSnackBar("Server error");
      order.value.data = null;
      return;
    }
    order.value = orderFromJson(response);
  }

  Future<void> getTables() async {
    print("=========================");
    var response = await ApiClient()
        .get('pos/table', header: Utils.apiHeader)
        .catchError(handleApiError);
    if (response == null) return;
    tables.value = tableListFromJson(response);
  }

  Future<void> addUpdateRider(bool add, {String id = ''}) async {
    Utils.showLoading();
    var body = jsonEncode({
      "first_name": controllerName.value.text,
      "last_name": lastNameComtroller.value.text,
      "email": controllerEmail.value.text,
      "phone": controllerPhone.value.text,
      "address": controllerAddress.value.text,
      if (add) "password": controllerPassword.value.text,
      if (add) "password_confirmation": controllerConfirmPass.value.text,
    });

    var response;
    if (add) {
      if (lastNameComtroller.value.text.isNotEmpty &&
          controllerName.value.text.isNotEmpty &&
          controllerPhone.value.text.isNotEmpty &&
          controllerPassword.value.text.isNotEmpty &&
          controllerConfirmPass.value.text.isNotEmpty &&
          controllerPassword.value.text == controllerConfirmPass.value.text &&
          controllerPassword.value.text.length >= 8) {
        response = await ApiClient()
            .post('client/rider', body, header: Utils.apiHeader)
            .catchError(handleApiError);
      } else {
        if (controllerName.value.text.isEmpty) {
          Utils.showSnackBar("First name is required");
        } else if (lastNameComtroller.value.text.isEmpty) {
          Utils.showSnackBar("Last name is required");
        } else if (controllerPhone.value.text.isEmpty) {
          Utils.showSnackBar("Phone is required");
        } else if (controllerPassword.value.text.isEmpty) {
          Utils.showSnackBar("Password is required");
        } else if (controllerConfirmPass.value.text.isEmpty) {
          Utils.showSnackBar("Password is required");
        } else if (controllerPassword.value.text !=
            controllerConfirmPass.value.text) {
          Utils.showSnackBar("Password did not match");
        }else if(controllerPassword.value.text.length < 8){
          Utils.showSnackBar("Password must be 8 character long");
        }
      }
    } else {
      if (lastNameComtroller.value.text.isNotEmpty &&
          controllerName.value.text.isNotEmpty &&
          controllerPhone.value.text.isNotEmpty) {
        response = await ApiClient()
            .put('client/rider/$id', body, header: Utils.apiHeader)
            .catchError(handleApiError);
      } else {
        if (controllerName.value.text.isEmpty) {
          Utils.showSnackBar("First name is required");
        } else if (lastNameComtroller.value.text.isEmpty) {
          Utils.showSnackBar("Last name is required");
        } else if (controllerPhone.value.text.isEmpty) {
          Utils.showSnackBar("Phone is required");
        }
      }
    }
    if (response == null) return;
    getPosRiders();
    Utils.hidePopup();
    if (add) {
      Utils.showSnackBar("Rider added successfully");
    } else {
      Utils.showSnackBar("Rider updated successfully");
    }

    controllerName.value.clear();
    lastNameComtroller.value.clear();
    controllerEmail.value.clear();
    controllerPhone.value.clear();
    controllerAddress.value.clear();
  }

  Future<void> addUpdateCustomer(bool add, {String id = ''}) async {
    Utils.showLoading();
    var body = jsonEncode({
      "first_name": controllerName.value.text,
      "email": controllerEmail.value.text,
      "phone": controllerPhone.value.text,
      "delivery_address": controllerAddress.value.text
    });

    var response;
    if (add) {
      if (controllerAddress.value.text.isNotEmpty &&
          controllerName.value.text.isNotEmpty &&
          controllerPhone.value.text.isNotEmpty) {
        response = await ApiClient()
            .post('pos/customer', body, header: Utils.apiHeader)
            .catchError(handleApiError);
      } else {
        if (controllerName.value.text.isEmpty) {
          Utils.showSnackBar("Name is required");
        } else if (controllerPhone.value.text.isEmpty) {
          Utils.showSnackBar("Phone is required");
        } else if (controllerAddress.value.text.isEmpty) {
          Utils.showSnackBar("Address is required");
        }
      }
    } else {
      response = await ApiClient()
          .put('pos/customer/$id', body, header: Utils.apiHeader)
          .catchError(handleApiError);
    }
    if (response == null) return;
    getCustomers();
    Utils.hidePopup();
    if (add) {
      Utils.showSnackBar("Customer added successfully");
    } else {
      Utils.showSnackBar("Customer updated successfully");
    }
  }

  Future<void> addUpdateOrder() async {
    if (orderTypeNumber == 1 && withoutTable.isFalse) {
      Utils.showSnackBar("No table selected for new order");
      return;
    }
    Utils.showLoading();
    List<Map> items = [{}];
    for (var element in cardList) {
      MenuData add = element;
      items.add(
        {
          "id": add.id,
          "quantity": add.quantity,
          "variant_id": int.parse(add.variant!),
          "addons": [
            for (var i in add.addons!.data!)
              if (i.isChecked == true) {"id": i.id, "quantity": i.quantity}
          ],
        },
      );
    }
    items.removeAt(0);
    String customerId = Utils.findIdByListNearValue(
        customers.value.data!.toList(), customerName.value);

    String riderId = Utils.findIdByListNearValue(
        posRiders.value.data.toList(), riderName.value);
    var body = jsonEncode({
      "order_type": orderTypes.entries.elementAt(topBtnPosition.value - 1).key,
      "customer": customerId == "0" ? "" : customerId,
      if(orderTypeNumber == 3 && riderId.isNotEmpty && riderId != "0") "rider": riderId,
      "items": items,
      "discount": discount.value,
      "tables": [
        for (var i in tables.value.data!.toList())
          if (i.person != 0)
            {"id": i.id, "person": int.parse(i.person.toString())}
      ]
    });

    var response;
    if (isUpdate.value) {
      response = await ApiClient()
          .put('pos/order/${order.value.data!.id!.toInt()}', body,
              header: Utils.apiHeader)
          .catchError(handleApiError);
    } else {
      response = await ApiClient()
          .post('pos/order', body, header: Utils.apiHeader)
          .catchError(handleApiError);
    }
    print(response);
    print("                            json.decode(response)");
    if (response == null) return;

    cardList.clear();
    tables.value.data!.clear();
    discount.value = 0;
    withoutTable.value = false;

    topBtnPosition.value = 1;
    orderTypeNumber = 1;
    customerName.value = "None";
    discount.refresh();
    getOrders();
    update(["cardUpdate"]);

    Utils.hidePopup();
    if (isUpdate.value) {
      isUpdate.value = false;
      isUpdate.refresh();
      Utils.showSnackBar("Order updated successfully");
    } else {
      Utils.showSnackBar("Order added successfully");
    }
  }

  Future<bool> orderPayment() async {
    var body = jsonEncode({
      "order_id": order.value.data!.id,
      "payment_method": payMethod.value,
      "give_amount": giveAmount.value,
      "use_rewards": reward.value ? 'use_rewards' : '',
    });
    var response = await ApiClient()
        .post('pos/payment', body, header: Utils.apiHeader)
        .catchError(handleApiError);
    if (response == null) return false;
    Utils.hidePopup();
    Utils.showSnackBar("Order placed successfully");
    return true;
  }

  Future<void> getOnlineOrder(int id) async {
    var response = await ApiClient()
        .get('pos/order/online', header: Utils.apiHeader)
        .catchError(handleApiError);
    if (response == null) return;
    onlineOrder.value = onlineOrderFromJson(response);
  }
}
