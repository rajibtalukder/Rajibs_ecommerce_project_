
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:klio_staff/mvc/controller/error_controller.dart';
import 'package:klio_staff/mvc/model/customer_list_model.dart';

import '../../constant/value.dart';
import '../../service/api/api_client.dart';
import '../../service/local/shared_pref.dart';
import '../../utils/utils.dart';
import '../model/Customer.dart';

class CustomerController extends GetxController with ErrorController{
  Rx<CustomerListModel> customerData = CustomerListModel(data: []).obs;
  Rx<Customer> singleCustomerData = Customer().obs;

  ///add new Customer
  final uploadCustomerFormKey = GlobalKey<FormState>();
  TextEditingController fNameCtlr = TextEditingController();
  TextEditingController lNameCtlr = TextEditingController();
  TextEditingController emailCtlr = TextEditingController();
  TextEditingController phoneCtlr = TextEditingController();
  TextEditingController addressCtlr = TextEditingController();

  ///Show Customer data


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    customerDataLoading();
  }
  @override
  void onReady() {
    // TODO: implement onReady
    super.onReady();
  }
  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }

  Future<void> customerDataLoading()async{
    token = (await SharedPref().getValue('token'))!;
    getCustomerDataList();
  }

  // Validator
  String? Function(String?)? textValidator = (String? value) {
    if (value!.isEmpty) {
      return 'This filed is required';
    } else {
      return null;
    }
  };

  Future<void> getCustomerDataList({dynamic id = ''})async{
    String endPoint ='pos/customer';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    customerData.value = customerListModelFromJson(response);
    update();
  }
  Future<void> getSingleCustomerDetails(dynamic id )async{
    String endPoint = 'pos/customer/$id';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    singleCustomerData.value = cusFromJson(response);
    update();
    print('checkResponseDetails${singleCustomerData.value}');
  }

  void addNewCustomer(
      String firstName,
      String lastName,
      String email,
      String phone,
      String deliveryAddress,
      )async{
    Utils.showLoading();
    var body = jsonEncode({
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "phone": phone,
      "delivery_address": deliveryAddress,
    });
    var  response = await ApiClient()
        .post('pos/customer', body, header: Utils.apiHeader)
        .catchError(handleApiError);
    Utils.hidePopup();
    Get.back();
    if (response == null) return;
    customerDataLoading();
    Utils.showSnackBar("Customer added successfully");
  }

  // Future <void> deleteCustomerData({id = ''})async {
  //   Utils.showLoading();
  //   String endPoint = 'pos/customer/$id';
  //   var response = await ApiClient()
  //       .delete(endPoint, header: Utils.apiHeader)
  //       .catchError(handleApiError);
  //   customerDataLoading();
  //   Utils.hidePopup();
  // }

}