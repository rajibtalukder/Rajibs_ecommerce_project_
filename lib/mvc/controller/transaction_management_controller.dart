import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klio_staff/constant/value.dart';
import 'package:klio_staff/mvc/controller/error_controller.dart';
import 'package:klio_staff/mvc/model/bank_list_data_model.dart';
import 'package:klio_staff/mvc/model/bank_list_data_model.dart' as Bank;
import 'package:klio_staff/mvc/model/transaction_list_data_model.dart';
import 'package:klio_staff/mvc/model/transaction_list_data_model.dart'
    as Transaction;
import 'package:klio_staff/service/api/api_client.dart';
import 'package:klio_staff/service/local/shared_pref.dart';
import 'package:klio_staff/utils/utils.dart';
import 'package:http/http.dart' as http;
import '../../service/api/api_exception.dart';

class TransactionsController extends GetxController with ErrorController {
  Rx<BankListModel> bankListData = BankListModel(data: []).obs;
  Rx<TransactionListModel> transactionListData =
      TransactionListModel(data: []).obs;
  File? signatureStoreImage;

  ///Api data fetch varriable
  int bankPageNumber = 1;
  int transitionPageNumber = 1;

  bool isLoadingBank = false;
  bool isLoadingTransition = false;

  bool haveMoreBank = true;
  bool haveMoreTransition = true;

  ///upload bank data
  final uploadBankKey = GlobalKey<FormState>();
  TextEditingController nameCtlr = TextEditingController();
  TextEditingController accNameCtlr = TextEditingController();
  TextEditingController accNumCtlr = TextEditingController();
  TextEditingController branchCtlr = TextEditingController();
  TextEditingController balanceCtlr = TextEditingController();

  String searchText='';

  // Validator
  String? Function(String?)? textValidator = (String? value) {
    if (value!.isEmpty) {
      return 'This filed is required';
    } else {
      return null;
    }
  };

  @override
  Future<void> onInit() async {
    super.onInit();
    transactionsDataLoading();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
  }

  @override
  void onClose() {}

  Future<void> transactionsDataLoading() async {
    token = (await SharedPref().getValue('token'))!;
    bankListDataList();
    transactionDataList();
  }

  Future<File> getImage() async {
    File? imageFile;
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File signatureStoreImage = File(pickedFile.path);
      imageFile = signatureStoreImage;
      update();
    } else {
      print('No image selected.');
    }
    return imageFile!;
  }

  Future<void> bankListDataList({dynamic id = ''}) async {
    if (!haveMoreBank) {
      return;
    }
    if (bankPageNumber == 1 && bankListData.value.data.isNotEmpty) {
      bankListData.value.data.clear();
    }
    isLoadingBank = true;
    String endPoint =searchText.isEmpty?
    'finance/bank?page$bankPageNumber'
    :'finance/bank?keyword=$searchText&page$bankPageNumber';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    var temp = bankListModelFromJson(response);
    List<Bank.Datum> datums = [];
    for (Bank.Datum it in temp.data) {
      datums.add(it);
    }
    bankListData.value.data.addAll(datums);
    bankPageNumber++;
    var res = json.decode(response);
    int to = res['meta']['to'];
    int total = res['meta']['total'];
    if (total <= to) {
      haveMoreBank = false;
    }
    isLoadingBank = false;
    update(['bankId']);
  }

  void addNewBank(String name, String accountName, String accountNumber,
      String branchName, String balance, File? signatureImg) async {
    Utils.showLoading();
    var uri = Uri.parse(baseUrl + 'finance/bank');
    try {
      http.MultipartRequest request = http.MultipartRequest('POST', uri);
      request.headers.addAll(Utils.apiHeader);
      if (signatureImg != null) {
        http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
            'signature_image', signatureImg.path);
        request.files.add(multipartFile);
      }
      Map<String, String> _fields = Map();
      _fields.addAll(<String, String>{
        "name": name,
        "account_name": accountName,
        "account_number": accountNumber,
        "branch_name": branchName,
        "balance": balance,
      });
      request.fields.addAll(_fields);
      http.StreamedResponse response = await request.send();
      var res = await http.Response.fromStream(response);
      Utils.hidePopup();
      Get.back();
      _processResponse(res);
      bankPageNumber = 1;
      haveMoreBank = true;
      bankListDataList();
    } on SocketException {
      throw ProcessDataException("No internet connection", uri.toString());
    } on TimeoutException {
      throw ProcessDataException("Not responding in time", uri.toString());
    }
  }

  // Future<void> deleteBank({id =''}) async{
  //   Utils.showLoading();
  //   String endPoint = 'finance/bank/$id';
  //   var response = await ApiClient()
  //       .delete(endPoint, header: Utils.apiHeader)
  //       .catchError(handleApiError);
  //   bankPageNumber = 1;
  //   haveMoreBank = true;
  //   bankListDataList();
  //   Utils.hidePopup();
  // }

  Future<void> transactionDataList({dynamic id = ''}) async {
    if (!haveMoreTransition) {
      return;
    }
    isLoadingTransition = true;
    String endPoint =searchText.isEmpty?
    'finance/bank-transaction?page=$transitionPageNumber'
    : 'finance/bank-transaction?keyword=$searchText&page=$transitionPageNumber';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    var temp = transactionListModelFromJson(response);
    List<Transaction.Datum> datums = [];
    for (Transaction.Datum it in temp.data) {
      datums.add(it);
    }
    transactionListData.value.data.addAll(datums);
    transitionPageNumber++;
    var res = json.decode(response);
    int to = res['meta']['to'];
    int total = res['meta']['total'];
    if (total <= to) {
      haveMoreTransition = false;
    }
    isLoadingTransition = false;
    update(['transId']);
  }

  /// Search methods for bank and bank transaction....

  Future<void> getBankByKeyword({String keyword = '', bool showLoading = true}) async {
    if(showLoading)Utils.showLoading();
    String endPoint =
        keyword.isNotEmpty ? "finance/bank?keyword=$keyword" : "finance/bank";
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    print(response);
    bankListData.value = bankListModelFromJson(response);
    var res = json.decode(response);
    int to = res['meta']['to']??0;
    int total = res['meta']['total']??0;
    if (total <= to) {
      haveMoreBank = false;
    }else{
      haveMoreBank=true;
      bankPageNumber=2;
    }
    update(["bankId"]);
    if(showLoading)Utils.hidePopup();
  }

  Future<void> getBankTransactionByKeyword({String keyword = '', bool showLoading = true}) async {
    if(showLoading)Utils.showLoading();
    String endPoint = keyword.isNotEmpty
        ? "finance/bank-transaction?keyword=$keyword"
        : "finance/bank-transaction";
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    print(response);
    transactionListData.value = transactionListModelFromJson(response);
    var res = json.decode(response);
    int to = res['meta']['to']??0;
    int total = res['meta']['total']??0;
    if (total <= to) {
      haveMoreTransition = false;
    }else{
      haveMoreTransition=true;
      transitionPageNumber=2;
    }
    update(["transId"]);
    if(showLoading)Utils.hidePopup();
  }

  dynamic _processResponse(http.Response response) {
    var jsonResponse = utf8.decode(response.bodyBytes);
    print('check body response${response.body}');
    var jsonDecode = json.decode(response.body);
    Utils.showSnackBar(jsonDecode['message']);
    print(response.statusCode);
    print(response.request!.url);
    switch (response.statusCode) {
      case 200:
        return jsonResponse;
      case 201:
        return jsonResponse;
      case 422:
        return jsonResponse;
      case 400:
        throw BadRequestException(
            jsonResponse, response.request!.url.toString());
      case 500:
        throw BadRequestException(
            jsonResponse, response.request!.url.toString());
      default:
        throw ProcessDataException(
            "Error occurred with code ${response.statusCode}",
            response.request!.url.toString());
    }
  }
}
