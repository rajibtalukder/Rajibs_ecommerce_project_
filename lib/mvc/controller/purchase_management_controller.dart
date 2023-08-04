import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:klio_staff/constant/value.dart';
import 'package:klio_staff/mvc/controller/error_controller.dart';
import 'package:klio_staff/mvc/model/expense_category_model.dart';
import 'package:klio_staff/mvc/model/expense_category_model.dart'
    as ExpCategory;
import 'package:klio_staff/mvc/model/expense_list_model.dart';
import 'package:klio_staff/mvc/model/expense_list_model.dart' as Expense;
import 'package:klio_staff/mvc/model/purchase_list_model.dart';
import 'package:klio_staff/mvc/model/purchase_list_model.dart' as Purchase;
import 'package:klio_staff/mvc/model/single_expense_data.dart';
import 'package:klio_staff/mvc/model/single_purchase_data.dart';
import 'package:klio_staff/service/api/api_client.dart';
import 'package:klio_staff/service/local/shared_pref.dart';
import 'package:klio_staff/utils/utils.dart';

import '../model/add_menu_model.dart';
import '../model/responsible_person_model.dart';
import 'food_management_controller.dart';

class PurchaseManagementController extends GetxController with ErrorController {
  Rx<PurchaseListModel> purchaseData = PurchaseListModel(data: []).obs;

  Rx<ExpenseDataList> expenseData = ExpenseDataList(data: []).obs;
  Rx<ExpenseCategoryModel> expenseCategoryData =
      ExpenseCategoryModel(data: []).obs;

  Rx<SinglePurchaseData> singlePurchaseData = SinglePurchaseData().obs;
  Rx<SingleExpenseData> singleExpenseData = SingleExpenseData().obs;
  List<ResponsiblePersonModel> responsiblePersons = [];

  ///Api data fetch varriable
  int purchasePageNumber = 1;
  int expencePageNumber = 1;
  int expenceCategoryPageNumber = 1;

  bool isLoadingPurchase = false;
  bool isLoadingExpence = false;
  bool isLoadingExpenceCategory = false;

  bool haveMorePurchase = true;
  bool haveMoreExpence = true;
  bool haveMoreExpenceCategory = true;

  ///Purchase Management
  Rx<TextEditingController> expenseCategoryNameCtlr =
      TextEditingController().obs;
  Rx<String> dateCtlr = ''.obs;
  Rx<TextEditingController> unitPriceCtlr = TextEditingController().obs;
  Rx<TextEditingController> quantityCtlr = TextEditingController().obs;

  Rx<TextEditingController> shippingChargeCtlr =
      TextEditingController(text: '0').obs;
  Rx<TextEditingController> discountCtlr = TextEditingController(text: '0').obs;
  Rx<TextEditingController> paidCtlr = TextEditingController(text: '0').obs;
  Rx<int> totalAmount = 0.obs;
  Rx<int> grandTotal = 0.obs;
  Rx<int> due = 0.obs;
  Rx<double> unitP = 0.0.obs;
  Rx<double> quantityA = 0.0.obs;

  var total = 0.0.obs;
  var isBank = false.obs;

  String searchText = '';

  Rx<String> itemDatetext = 'Choose Date'.obs;

  ///add purchase
  final uploadPurchaseKey = GlobalKey<FormState>();
  String supplierId = "";
  String bankId = "";
  String paymentType = "cash payment";
  String discountType = "fixed";

  List<Ingredients> ingredients = [];
  double purchaseTotal = 0;
  TextEditingController purchaseDetailController = TextEditingController();
  TextEditingController purchaseShippingChargeController =
      TextEditingController(text: "0");
  TextEditingController purchaseDiscountController =
      TextEditingController(text: "0");
  TextEditingController purchasePaidController =
      TextEditingController(text: "0");

  ///add Expense
  final uploadExpenceFormKey = GlobalKey<FormState>();
  List<int> uploadExpenceResPersonList = [];
  List<int> uploadExpenceCatList = [];
  TextEditingController expenceAmountCtlr = TextEditingController();
  TextEditingController expenceNoteCtlr = TextEditingController();

  ///update Expense
  final updateExpenceFormKey = GlobalKey<FormState>();
  List<int> updateExpenceResPersonList = [];
  List<int> updateExpenceCatList = [];
  TextEditingController updateExpenceAmountCtlr = TextEditingController();
  TextEditingController updateExpenceNoteCtlr = TextEditingController();

  @override
  Future<void> onInit() async {
    super.onInit();
    purchaseDataLoading();
    fetchResponsiblePersons();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
  }

  @override
  void onClose() {}

  Future<void> purchaseDataLoading() async {
    token = (await SharedPref().getValue('token'))!;
    getPurchaseDataList();
    getExpenseDataList();
    getExpenseCategoryList();
  }

  Future<String> getChooseDate(BuildContext context,
      {bool shouldChange = true}) async {
    DateTime? pickDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickDate == null) return "";

    if (shouldChange) {
      dateCtlr.value = DateFormat('yyyy-MM-dd').format(pickDate);
      update(['dateId']);
    }

    return DateFormat('yyyy-MM-dd').format(pickDate);
  }

  Future<void> getPurchaseDataList({dynamic id = ''}) async {
    if (!haveMorePurchase) {
      return;
    }
    isLoadingPurchase = true;
    String endPoint = searchText.isEmpty
        ? 'finance/purchase?page=$purchasePageNumber'
        : 'finance/purchase?keyword=$searchText&page=$purchasePageNumber';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    var temp = purchaseListModelFromJson(response);
    List<Purchase.Datum> datums = [];
    for (Purchase.Datum it in temp.data) {
      datums.add(it);
    }
    if (purchasePageNumber == 1) {
      purchaseData.value.data.clear();
    }
    purchaseData.value.data.addAll(datums);

    purchasePageNumber++;
    var res = json.decode(response);
    int to = res['meta']['to'];
    int total = res['meta']['total'];
    if (total <= to) {
      haveMorePurchase = false;
    }
    isLoadingPurchase = false;
    update(['purchaseId']);
  }

  Future<void> fetchResponsiblePersons() async {
    String endPoint = 'staff';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    final List<dynamic> data = json.decode(response);
    responsiblePersons =
        data.map((e) => ResponsiblePersonModel.fromJson(e)).toList();
    print(responsiblePersons[0].name);
  }

  Future<void> getSinglePurchaseData({dynamic id = ''}) async {
    String endPoint = 'finance/purchase/$id';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    singlePurchaseData.value = singlePurchaseDataFromJson(response);
    update();
    print('checkResponseDetails${singlePurchaseData.value.data!.id}');
  }

  Future<void> deletePurchaseItem({dynamic id = ''}) async {

    String endPoint = 'finance/purchase/$id/delete';
    var response = await ApiClient()
        .delete(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    if (response == null) return;

    Utils.showSnackBar("Item Removed");
  }

  Future<void> getExpenseDataList({dynamic id = ''}) async {
    if (!haveMoreExpence) {
      return;
    }
    if (expencePageNumber == 1 && haveMoreExpence) {
      expenseData.value.data.clear();
    }
    isLoadingExpence = true;
    String endPoint = searchText.isEmpty
        ? 'finance/expense?page=$expencePageNumber'
        : 'finance/expense?keyword=$searchText&page=$expencePageNumber';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    var temp = expenseDataListFromJson(response);
    List<Expense.Datum> datums = [];
    for (Expense.Datum it in temp.data) {
      datums.add(it);
    }
    expenseData.value.data.addAll(datums);
    expencePageNumber++;
    var res = json.decode(response);
    int to = res['meta']['to'];
    int total = res['meta']['total'];
    if (total <= to) {
      haveMoreExpence = false;
    }
    isLoadingExpence = false;
    update(['expenseId']);
  }

  Future<void> addNewPurchase(double discount, bool isUpdate,
      {int id = -1}) async {
    try {
      Utils.showLoading();
      String endPoint = isUpdate ? 'finance/purchase/$id' : 'finance/purchase';

      var body = jsonEncode({
        "supplier": int.parse(supplierId),
        "purchase_date": dateCtlr.value,
        "payment_type": paymentType,
        if (bankId.isNotEmpty) "bank": int.parse(bankId),
        "details": purchaseDetailController.text,
        "ingredients": [
          for (int i = 0; i < ingredients.length; i++) ingredients[i].toJson()
        ],
        "total_amount": purchaseTotal - discount,
        "shipping_charge": double.parse(purchaseShippingChargeController.text),
        "discount": discount,
        "paid": double.parse(purchasePaidController.text)
      });

      print("bodyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy");
      print(body);

      var response = isUpdate
          ? await ApiClient()
              .put(endPoint, body, header: Utils.apiHeader)
              .catchError(handleApiError)
          : await ApiClient()
              .post(endPoint, body, header: Utils.apiHeader)
              .catchError(handleApiError);

      if (response == null) return;
      haveMorePurchase = true;
      purchasePageNumber = 1;
      await getPurchaseDataList();
      update(['purchaseId']);
      Utils.hidePopup();
      Get.back();
      Utils.showSnackBar( isUpdate
          ? "Successfully Update":"Successfully Added");
      clearPurchase();
    } catch (e) {
      Utils.hidePopup();
      Utils.showSnackBar("Something went wrong");
    }
  }

  clearPurchase() {
    FoodManagementController foodManagementController = Get.find();
    supplierId = '';
    dateCtlr.value = '';
    paymentType = "cash payment";
    discountType = "fixed";
    bankId = "";
    purchaseTotal = 0;

    ingredients.clear();
    purchaseDetailController.clear();
    purchaseShippingChargeController.text = "0";
    purchaseDiscountController.text = "0";
    purchasePaidController.text = "0";

    for (var element in foodManagementController.addMenuModel.ingredients) {
      element.quantity = 1;
      element.expireDate = '';
    }
  }

  Future<void> addExpence(
      int personId, int categoryId, double amount, String date,
      {String note = ''}) async {
    Utils.showLoading();
    String endPoint = 'finance/expense';
    var body = jsonEncode({
      "person": personId,
      "category": categoryId,
      "amount": amount,
      "date": date,
      "note": note
    });
    var response = await ApiClient()
        .post(endPoint, body, header: Utils.apiHeader)
        .catchError(handleApiError);
    if (response == null) return;
    haveMoreExpence = true;
    expencePageNumber = 1;
    await getExpenseDataList();
    update(['expenceId']);
    //purchaseDataLoading();
    Utils.hidePopup();
    Get.back();
    Utils.showSnackBar("Successfully Added");
  }

  void updateExpence(
      int personId, int categoryId, double amount, String date, String note,
      {String id = ''}) async {
    Utils.showLoading();
    var body = jsonEncode({
      "person": personId,
      "category": categoryId,
      "amount": amount,
      "date": date,
      "note": note,
    });
    var response = await ApiClient()
        .put('finance/expense/$id', body, header: Utils.apiHeader)
        .catchError(handleApiError);
    print(response);
    if (response == null) return;
    haveMoreExpence = true;
    expencePageNumber = 1;
    await getExpenseDataList();
    update(['expenceId']);
    // purchaseDataLoading();
    Get.back();
    Get.back();
    Utils.showSnackBar("successfully");
  }

  Future<void> getSingleExpenseData({dynamic id = ''}) async {
    String endPoint = 'finance/expense/$id';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    singleExpenseData.value = singleExpenseDataFromJson(response);
    update();
    print('checkResponseDetails${singleExpenseData.value.data!.id}');
  }

  Future<void> deletePurchase({dynamic id = ''}) async {
    Utils.showLoading();
    String endPoint = 'finance/purchase/$id';
    var response = await ApiClient()
        .delete(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    Utils.showLoading();
    if (response == null) return;
    haveMorePurchase = true;
    purchasePageNumber = 1;
    await getPurchaseDataList();
    update(['purchaseId']);
    // purchaseDataLoading();
    Utils.hidePopup();
    Utils.showSnackBar("Purchase deleted");
  }

  Future<void> deleteExpense({dynamic id = ''}) async {
    Utils.showLoading();
    String endPoint = 'finance/expense/$id';
    var response = await ApiClient()
        .delete(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    Utils.showLoading();
    if (response == null) return;
    haveMoreExpence = true;
    expencePageNumber = 1;
    await getExpenseDataList();
    update(['expenceId']);
    // purchaseDataLoading();
    Utils.hidePopup();
    Utils.showSnackBar("Deleted Expense");
  }

  Future<void> getExpenseCategoryList({dynamic id = ''}) async {
    if (!haveMoreExpenceCategory) {
      return;
    }
    if (expenceCategoryPageNumber == 1 && haveMoreExpenceCategory) {
      expenseCategoryData.value.data.clear();
    }
    isLoadingExpenceCategory = true;
    String endPoint = searchText.isEmpty
        ? 'finance/expense-category?page=$expenceCategoryPageNumber'
        : 'finance/expense-category?keyword=$searchText&page=$expenceCategoryPageNumber';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    var temp = expenseCategoryModelFromJson(response);
    List<ExpCategory.Datum> datums = [];
    for (ExpCategory.Datum it in temp.data) {
      datums.add(it);
    }
    expenseCategoryData.value.data.addAll(datums);
    expenceCategoryPageNumber++;
    var res = json.decode(response);
    int to = res['meta']['to'];
    int total = res['meta']['total'];
    if (total <= to) {
      haveMoreExpenceCategory = false;
    }
    isLoadingExpenceCategory = false;
    update(['expCategoryId']);
  }

  Future<void> addNewExpenseCategory(String name) async {
    Utils.showLoading();
    String endPoint = 'finance/expense-category';
    var body = jsonEncode({
      "name": name,
    });
    var response = await ApiClient()
        .post(endPoint, body, header: Utils.apiHeader)
        .catchError(handleApiError);
    if (response == null) return;
    haveMoreExpenceCategory = true;
    expenceCategoryPageNumber = 1;
    await getExpenseCategoryList();
    update(['expCategoryId']);
    // purchaseDataLoading();
    Utils.hidePopup();

    Get.back();
    Utils.showSnackBar("Successfully Added");
  }

  Future<void> deleteExpenseCategory({dynamic id = ''}) async {
    Utils.showLoading();
    String endPoint = 'finance/expense-category/$id';
    var response = await ApiClient()
        .delete(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    Utils.showLoading();
    if (response == null) return;
    haveMoreExpenceCategory = true;
    expenceCategoryPageNumber = 1;
    await getExpenseCategoryList();
    update(['expCategoryId']);
    //purchaseDataLoading();
    Utils.hidePopup();
    Get.back();
    Utils.showSnackBar("Deleted Category");
  }

  ///Search methods for all items....
  ///
  Future<void> getPurchaseByKeyword(
      {String keyword = '', bool showLoading = true}) async {
    if (showLoading) Utils.showLoading();
    String endPoint = keyword.isNotEmpty
        ? "finance/purchase?keyword=$keyword"
        : "finance/purchase";
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    print("ik$response");
    purchaseData.value = purchaseListModelFromJson(response);
    var res = json.decode(response);
    int to = res['meta']['to'] ?? 0;
    int total = res['meta']['total'] ?? 0;
    if (total <= to) {
      haveMorePurchase = false;
    } else {
      haveMorePurchase = true;
      purchasePageNumber = 2;
    }
    update(["purchaseId"]);
    if (showLoading) Utils.hidePopup();
  }

  Future<void> getExpenseByKeyword(
      {String keyword = '', bool showLoading = true}) async {
    if (showLoading) Utils.showLoading();
    String endPoint = keyword.isNotEmpty
        ? "finance/expense?keyword=$keyword"
        : "finance/expense";
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    print(response);
    expenseData.value = expenseDataListFromJson(response);
    var res = json.decode(response);
    int to = res['meta']['to'] ?? 0;
    int total = res['meta']['total'] ?? 0;
    if (total <= to) {
      haveMoreExpence = false;
    } else {
      haveMoreExpence = true;
      expencePageNumber = 2;
    }
    update(["expenceId"]);
    if (showLoading) Utils.hidePopup();
  }

  Future<void> getExpenseCategoryByKeyword(
      {String keyword = '', bool showLoading = true}) async {
    if (showLoading) Utils.showLoading();
    String endPoint = keyword.isNotEmpty
        ? "finance/expense-category?keyword=$keyword"
        : "finance/expense-category";
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    print(response);
    expenseCategoryData.value = expenseCategoryModelFromJson(response);
    var res = json.decode(response);
    int to = res['meta']['to'] ?? 0;
    int total = res['meta']['total'] ?? 0;
    if (total <= to) {
      haveMoreExpenceCategory = false;
    } else {
      haveMoreExpenceCategory = true;
      expenceCategoryPageNumber = 2;
    }
    update(["expCategoryId"]);
    if (showLoading) Utils.hidePopup();
  }
}
