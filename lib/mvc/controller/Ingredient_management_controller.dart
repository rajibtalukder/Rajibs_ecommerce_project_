import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klio_staff/constant/value.dart';
import 'package:klio_staff/mvc/controller/error_controller.dart';
import 'package:klio_staff/mvc/model/Ingredient_list_model.dart';
import 'package:klio_staff/mvc/model/ingredient_category_model.dart';
import 'package:klio_staff/mvc/model/ingredient_supplier_model.dart';
import 'package:klio_staff/mvc/model/ingredient_unit_model.dart';
import 'package:klio_staff/service/api/api_client.dart';
import 'package:klio_staff/service/api/api_exception.dart';
import 'package:klio_staff/service/local/shared_pref.dart';
import 'package:klio_staff/utils/utils.dart';

import '../model/ingredient_supplier_single_item.dart';
import '../model/single_Ingredient_Data_Model.dart';

class IngredientController extends GetxController with ErrorController {
  Rx<IngredinetListModel> ingredientData = IngredinetListModel(data: []).obs;
  Rx<SingleIngredientData> singleIngredientData = SingleIngredientData().obs;
  Rx<IngredineCategoryModel> ingredientCategoryData =
      IngredineCategoryModel(data: []).obs;
  Rx<IngredineUnitModel> ingredientUnitData = IngredineUnitModel(data: []).obs;
  Rx<IngredineSupplierModel> ingredientSupplierData =
      IngredineSupplierModel(data: []).obs;
  Rx<IngredientSupplierSingleItem> ingredientSupplierSingleItem =
      IngredientSupplierSingleItem().obs;

  // add Ingedinat//
  final addIngredintFormKey = GlobalKey<FormState>();
  TextEditingController addIngrediantNameCtlr = TextEditingController();
  TextEditingController addIngredientPriceCtlr = TextEditingController();
  TextEditingController addIngredintCodeCtlr = TextEditingController();
  TextEditingController addIngredintQtyCtlr = TextEditingController();
  List<int> addIngredintCatgoryList = [];
  List<int> addIngredintUnitList = [];

  // update ingredinat//
  final updateIngredintFormKey = GlobalKey<FormState>();
  TextEditingController updateIngrediantNameCtlr = TextEditingController();
  TextEditingController updateIngredientPriceCtlr = TextEditingController();
  TextEditingController updateIngredintCodeCtlr = TextEditingController();
  TextEditingController updateIngredintUnitCtlr = TextEditingController();
  TextEditingController updateIngredintAlertQtyCtlr = TextEditingController();
  List<int> updateIngredientCatgoryList = [];
  List<int> updateIngredientUnitList = [];

  //add Ingredint Category
  final IngredintCategoryFormKey = GlobalKey<FormState>();
  TextEditingController ingredientCategoryNameCtlr = TextEditingController();
  TextEditingController ingredientCategoryStatusCtlr = TextEditingController();

  //add Ingredint Unit
  final IngredintUnitFormKey = GlobalKey<FormState>();
  TextEditingController ingredientUnitNameCtlr = TextEditingController();
  TextEditingController ingredientUnitDescriptionCtlr = TextEditingController();

  // add Ingredinat Supplier//
  final addIngredintSupplierFormKey = GlobalKey<FormState>();
  TextEditingController addIngrediantSupplierNameCtlr = TextEditingController();
  TextEditingController addIngredientSupplierEmailCtlr =
      TextEditingController();
  TextEditingController addIngredintSupplierPhoneCtlr = TextEditingController();
  TextEditingController addIngredintSupplierRefCtlr = TextEditingController();
  TextEditingController addIngredintSupplierAddressCtlr =
      TextEditingController();
  TextEditingController addIngredintSupplierStatusCtlr =
      TextEditingController();
  File? idCardFront;
  File? idCardBack;

  // update supplier//
  final updateSupplierFormKey = GlobalKey<FormState>();
  TextEditingController updateSupplierNameCtlr =
      TextEditingController(text: 'Update Name');
  TextEditingController updateSupplierEmailCtlr =
      TextEditingController(text: 'Update Email');
  TextEditingController updateSupplierPhoneCtlr =
      TextEditingController(text: 'Update Phone');
  TextEditingController updateSupplierRefCtlr =
      TextEditingController(text: 'Update Reference');
  TextEditingController updateSupplierAddressCtlr =
      TextEditingController(text: 'Update Address');

  int ingredientPageNumber = 1;
  int categoryPageNumber = 1;
  int unitPageNumber = 1;
  int supplierPageNumber = 1;

  bool isLoading = false;

  bool haveMoreIngredient = true;
  bool haveMoreCategory = true;
  bool haveMoreUnit = true;
  bool haveMoreSupplier = true;

  String searchText = '';

  ///
  ///

  final data = <Map<String, dynamic>>[].obs;

  Future<void> fetchData({dynamic id = ''}) async {
    String endPoint = 'master/ingredient/$id';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    final decodedData = jsonDecode(response);
    data.add(decodedData);
    print(data);
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    ingredientDataLoading();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
  }

  @override
  void onClose() {}

  Future<void> ingredientDataLoading() async {
    token = (await SharedPref().getValue('token'))!;
    getIngredientDataList();
    getIngredientCategory();
    getIngredientUnit();
    getIngredientSupplier();
  }

  //image upload **

  Future<File> getIdCardImage() async {
    File? imageFile;
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File menuStoreImage = File(pickedFile.path);
      imageFile = menuStoreImage;
      update();
    } else {
      print('No image selected.');
    }
    return imageFile!;
  }

  // Validator
  String? Function(String?)? textValidator = (String? value) {
    if (value!.isEmpty) {
      return 'This filed is required';
    } else {
      return null;
    }
  };

  Future<void> getIngredientDataList({dynamic id = ''}) async {
    if (!haveMoreIngredient) {
      return;
    }
    if (ingredientPageNumber == 1 && ingredientData.value.data!.isNotEmpty) {
      ingredientData.value.data!.clear();
    }
    isLoading = true;
    String endPoint = id == ''
        ? searchText.isEmpty
            ? 'master/ingredient'
            : 'master/ingredient?keyword=$searchText'
        : 'master/ingredient/$id';
    var response = await ApiClient()
        .get("$endPoint?page=$ingredientPageNumber", header: Utils.apiHeader)
        .catchError(handleApiError);

    var temp = ingredinetListModelFromJson(response);
    List<Ingrediant> ingredient = temp.data!;

    ingredientData.value.data?.addAll(ingredient);

    var res = json.decode(response);
    int to = res['meta']['to'] ?? 0;
    int total = res['meta']['total'] ?? 0;

    if (total <= to) {
      haveMoreIngredient = false;
    }
    ingredientPageNumber++;
    isLoading = false;
    update(['ingredientTab']);
  }

  void deleteIngredientDataList({id = ''}) async {
    Utils.showLoading();
    ingredientPageNumber = 1;
    haveMoreIngredient = true;
    String endPoint = 'master/ingredient/$id';
    var response = await ApiClient()
        .delete(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    getIngredientDataList();
    Utils.hidePopup();
    Utils.showSnackBar("Deleted Successfully");
  }

  Future<void> getSingleIngredientData({dynamic id = ''}) async {
    String endPoint = 'master/ingredient/$id';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    singleIngredientData.value = singleIngredientDataFromJson(response);
    update();
  }

  Future<void> getIngredientCategory({dynamic id = ''}) async {
    if (!haveMoreCategory) {
      return;
    }

    if (categoryPageNumber == 1 &&
        ingredientCategoryData.value.data.isNotEmpty) {
      ingredientCategoryData.value.data.clear();
    }
    isLoading = true;

    String endPoint = id == ''
        ? searchText.isEmpty
            ? 'master/ingredient-category?page=$categoryPageNumber'
            : 'master/ingredient-category?keyword=$searchText&page=$categoryPageNumber'
        : 'master/ingredient-category/$id';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);

    var temp = ingredineCategoryModelFromJson(response);
    List<IngrediantCategory> ingredientCategory = temp.data;

    ingredientCategoryData.value.data.addAll(ingredientCategory);

    var res = json.decode(response);
    int to = res['meta']['to'] ?? 0;
    int total = res['meta']['total'] ?? 0;

    if (total <= to) {
      haveMoreCategory = false;
    }

    categoryPageNumber++;
    isLoading = false;
    update(["categoryTab"]);
  }

  void deleteIngredientCategory({id = ''}) async {
    Utils.showLoading();
    haveMoreCategory = true;
    categoryPageNumber = 1;
    String endPoint = 'master/ingredient-category/$id';
    var response = await ApiClient()
        .delete(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    getIngredientCategory();
    Utils.hidePopup();
    Utils.showSnackBar("Deleted Successfully");
  }

  Future<void> getIngredientUnit({dynamic id = ''}) async {
    if (!haveMoreUnit) {
      return;
    }
    if (unitPageNumber == 1 && ingredientUnitData.value.data.isNotEmpty) {
      ingredientUnitData.value.data.clear();
    }
    isLoading = true;

    String endPoint = id == ''
        ? searchText.isEmpty
            ? 'master/ingredient-unit?page=$unitPageNumber'
            : 'master/ingredient-unit?keyword=$searchText&page=$unitPageNumber'
        : 'master/ingredient-unit/$id';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);

    var temp = ingredineUnitModelFromJson(response);
    List<IngrediantUnit> ingredientUnit = temp.data;

    ingredientUnitData.value.data.addAll(ingredientUnit);

    var res = json.decode(response);
    int to = res['meta']['to'] ?? 0;
    int total = res['meta']['total'] ?? 0;

    if (total <= to) {
      haveMoreUnit = false;
    }

    unitPageNumber++;
    isLoading = false;
    update(["unitTab"]);
    /*ingredientUnitData.value = ingredineUnitModelFromJson(response);
    update();
    debugPrint("checkIngredientUnit${ingredientUnitData.value.data[0].id}");*/
  }

  void deleteIngredientUnit({id = ''}) async {
    Utils.showLoading();
    unitPageNumber = 1;
    haveMoreUnit = true;
    String endPoint = 'master/ingredient-unit/$id';
    var response = await ApiClient()
        .delete(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    getIngredientUnit();
    Utils.hidePopup();
    Utils.showSnackBar("Deleted Successfully");
  }

  Future<void> getIngredientSupplier({dynamic id = ''}) async {
    if (!haveMoreSupplier) {
      return;
    }
    if (supplierPageNumber == 1 &&
        ingredientSupplierData.value.data.isNotEmpty) {
      ingredientSupplierData.value.data.clear();
    }
    isLoading = true;

    String endPoint = id == ''
        ? searchText.isEmpty
            ? 'master/supplier?page=$supplierPageNumber'
            : 'master/supplier?keyword=$searchText&page=$supplierPageNumber'
        : 'master/supplier/$id';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);

    var temp = ingredineSupplierModelFromJson(response);
    List<Datum> ingredientUnit = temp.data;

    ingredientSupplierData.value.data.addAll(ingredientUnit);

    var res = json.decode(response);
    int to = res['meta']['to'] ?? 0;
    int total = res['meta']['total'] ?? 0;

    if (total <= to) {
      haveMoreSupplier = false;
    }

    supplierPageNumber++;
    isLoading = false;
    update(["supplierTab"]);

    /*  ingredientSupplierData.value = ingredineSupplierModelFromJson(response);
    update();
    debugPrint(
        "checkIngredinetSupplierData${ingredientSupplierData.value.data[0].id}");*/
  }

  Future<void> getSupplierSingleDetails({dynamic id = ''}) async {
    String endPoint = 'master/supplier/$id';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    ingredientSupplierSingleItem.value =
        ingredientSupplierSingleItemFromJson(response);
    update();
    print(
        'checkResponseDetails${ingredientSupplierSingleItem.value.data!.name}');
  }

  void deleteIngredientSupplier({id = ''}) async {
    Utils.showLoading();
    haveMoreSupplier = true;
    supplierPageNumber = 1;
    String endPoint = 'master/supplier/$id';
    await ApiClient()
        .delete(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    getIngredientSupplier();
    Utils.hidePopup();
    Utils.showSnackBar("Deleted Successfully");
  }

  Future addAndUpdateIngrediant(bool add, String name, String price,
      String code, String quantity, int categoryId, int unitId,
      {String id = ''}) async {
    print(categoryId);
    Utils.showLoading();
    var body = jsonEncode({
      "name": name,
      "purchase_price": price,
      "category": categoryId,
      "alert_qty": quantity,
      "unit": unitId,
      "code": code
    });
    var response;
    if (add) {
      response = await ApiClient()
          .post('master/ingredient', body, header: Utils.apiHeader)
          .catchError(handleApiError);
    } else {
      response = await ApiClient()
          .put('master/ingredient/$id', body, header: Utils.apiHeader)
          .catchError(handleApiError);
    }
    if (response == null) return;
    getIngredientDataList();
    Utils.hidePopup();
    Utils.showSnackBar("Successfully Added");
  }

  Future addAndUpdateIngrediantCategory(bool add, String name,
      {String id = ''}) async {
    Utils.showLoading();
    var body = jsonEncode({
      "name": name,
    });
    var response;
    if (add) {
      response = await ApiClient()
          .post('master/ingredient-category', body, header: Utils.apiHeader)
          .catchError(handleApiError);
      Utils.hidePopup();
    } else {
      response = await ApiClient()
          .put('master/ingredient-category/$id', body, header: Utils.apiHeader)
          .catchError(handleApiError);
    }
    if (response == null) return;
    getIngredientCategory();
    Utils.hidePopup();
    Utils.showSnackBar("Successfully Added");
  }

  Future addAndUpdateIngrediantUnit(
      bool add, String name, String description, bool status,
      {String id = ''}) async {
    Utils.showLoading();
    var body = jsonEncode({
      "name": name,
      "description": description,
      "status": status,
    });
    var response;
    if (add) {
      response = await ApiClient()
          .post('master/ingredient-unit', body, header: Utils.apiHeader)
          .catchError(handleApiError);
    } else {
      response = await ApiClient()
          .put('master/ingredient-unit/$id', body, header: Utils.apiHeader)
          .catchError(handleApiError);
    }
    print(response);
    if (response == null) return print('No response...!!');
    await getIngredientUnit();
    Utils.hidePopup();
    Utils.showSnackBar("Successfully Added");
  }

  Future addSupplierMethod(
      String name,
      String email,
      String phone,
      String reference,
      String address,
      String status,
      File? idCardFront,
      File? idCardBack,
      {id = ''}) async {
    Utils.showLoading();
    var uri = Uri.parse(baseUrl + "master/supplier");
    try {
      var responseData;

      http.MultipartRequest request = http.MultipartRequest('POST', uri);
      request.headers.addAll(Utils.apiHeader);
      if (idCardFront != null) {
        http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
            'id_card_front', idCardFront.path);
        request.files.add(multipartFile);
      }
      if (idCardBack != null) {
        http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
            'id_card_back', idCardBack.path);
        request.files.add(multipartFile);
      }
      Map<String, String> _fields = Map();
      _fields.addAll(<String, String>{
        "name": name,
        "email": email,
        "phone": phone,
        "reference": reference,
        "address": address,
        "status": status,
      });
      request.fields.addAll(_fields);
      http.StreamedResponse response = await request.send();
      responseData = await http.Response.fromStream(response);
      print("+++++++++++++++++++++++++++++++++++++");
      Utils.hidePopup();
      Get.back();
      _processResponse(responseData);
      getIngredientSupplier();
    } on SocketException {
      throw ProcessDataException("No internet connection", uri.toString());
    } on TimeoutException {
      throw ProcessDataException("Not responding in time", uri.toString());
    }
  }

  Future updateSupplierMethod(String name, String email, String phone,
      String reference, String address, String status,
      // File? idCardFront,
      // File? idCardBack,
      {id = ''}) async {
    Utils.showLoading();
    var uri = Uri.parse(baseUrl + "master/supplier/$id");

    try {
      http.MultipartRequest request = http.MultipartRequest('POST', uri);
      request.headers.addAll(Utils.apiHeader);
      if (idCardFront != null) {
        http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
            "id_card_front", idCardFront!.path);
        request.files.add(multipartFile);
      }
      if (idCardBack != null) {
        http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
            "id_card_back", idCardFront!.path);
        request.files.add(multipartFile);
      }
      Map<String, String> _fields = Map();
      _fields.addAll(<String, String>{
        "name": name,
        "email": email,
        "phone": phone,
        "reference": reference,
        "address": address,
        '_method': 'PUT',
      });
      request.fields.addAll(_fields);
      http.StreamedResponse response = await request.send();
      var res = await http.Response.fromStream(response);
      Utils.hidePopup();
      Get.back();
      _processResponse(res);
      getIngredientSupplier();
    } on SocketException {
      throw ProcessDataException("No internet connection", uri.toString());
    } on TimeoutException {
      throw ProcessDataException("Not responding in time", uri.toString());
    }
  }

  /// search methods for all items....
  Future<void> getIngredientByKeyword(
      {String keyword = '', bool showLoading = true}) async {
    if (showLoading) Utils.showLoading();
    String endPoint = keyword.isNotEmpty
        ? "master/ingredient?keyword=$keyword"
        : "master/ingredient";
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    print(response);
    ingredientData.value = ingredinetListModelFromJson(response);
    var res = json.decode(response);
    int to = res['meta']['to'] ?? 0;
    int total = res['meta']['total'] ?? 0;
    if (total <= to) {
      haveMoreIngredient = false;
    } else {
      haveMoreIngredient = true;
      ingredientPageNumber = 2;
    }
    update(["ingredientTab"]);
    if (showLoading) Utils.hidePopup();
  }

  Future<void> getIngredientCategoryByKeyword(
      {String keyword = '', bool showLoading = true}) async {
    if (showLoading) Utils.showLoading();
    String endPoint = keyword.isNotEmpty
        ? "master/ingredient-category?keyword=$keyword"
        : "master/ingredient-category";
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    print(response);
    ingredientCategoryData.value = ingredineCategoryModelFromJson(response);
    var res = json.decode(response);
    int to = res['meta']['to'] ?? 0;
    int total = res['meta']['total'] ?? 0;
    if (total <= to) {
      haveMoreCategory = false;
    } else {
      haveMoreCategory = true;
      categoryPageNumber = 2;
    }
    update(['categoryTab']);
    if (showLoading) Utils.hidePopup();
  }

  Future<void> getIngredientUnitByKeyword(
      {String keyword = '', bool showLoading = true}) async {
    if (showLoading) Utils.showLoading();
    String endPoint = keyword.isNotEmpty
        ? "master/ingredient-unit?keyword=$keyword"
        : "master/ingredient-unit";
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    print(response);
    ingredientUnitData.value = ingredineUnitModelFromJson(response);
    var res = json.decode(response);
    int to = res['meta']['to'] ?? 0;
    int total = res['meta']['total'] ?? 0;
    if (total <= to) {
      haveMoreUnit = false;
    } else {
      haveMoreUnit = true;
      unitPageNumber = 2;
    }
    update(['unitTab']);
    if (showLoading) Utils.hidePopup();
  }

  Future<void> getIngredientSupplierByKeyword(
      {String keyword = '', bool showLoading = true}) async {
    if (showLoading) Utils.showLoading();
    String endPoint = keyword.isNotEmpty
        ? "master/supplier?keyword=$keyword"
        : "master/supplier";
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    print(response);
    ingredientSupplierData.value = ingredineSupplierModelFromJson(response);
    var res = json.decode(response);
    int to = res['meta']['to'] ?? 0;
    int total = res['meta']['total'] ?? 0;
    if (total <= to) {
      haveMoreSupplier = false;
    } else {
      haveMoreSupplier = true;
      supplierPageNumber = 2;
    }
    update(['supplierTab']);
    if (showLoading) Utils.hidePopup();
  }

  dynamic _processResponse(http.Response response) {
    var jsonResponse = utf8.decode(response.bodyBytes);
    //print('check body response${response.body}');
    var jsonDecode = json.decode(response.body);
    print('check body response${jsonDecode}');
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
