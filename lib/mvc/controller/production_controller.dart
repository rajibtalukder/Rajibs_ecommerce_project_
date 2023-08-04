import 'dart:convert';

import 'package:get/get.dart';
import 'package:klio_staff/mvc/controller/Ingredient_management_controller.dart';
import 'package:klio_staff/mvc/controller/error_controller.dart';
import 'package:klio_staff/mvc/model/single_production_unit.dart';
import 'package:klio_staff/mvc/model/variant_name_model.dart';

import '../../service/api/api_client.dart';
import '../../utils/utils.dart';
import '../model/Ingredient_list_model.dart';
import '../model/production_unit_item_model.dart';
import '../model/production_unit_model.dart';

class ProductionController extends GetxController with ErrorController {
  Rx<ProductionUnitModel> productionUnit =
      ProductionUnitModel(data: [], links: null, meta: null).obs;
  List<VariantNameModel> variantName = [];
  Rx<SingleProductionUnit> singleProductionUnit = SingleProductionUnit().obs;

  List<ProductionUnitItemModel> productionItem = [];
  List<Ingrediant> ingredients = [];
  double totalAmount = 0;

  ///Add Production unit data...
  Rx<int> foodId = 0.obs;
  Rx<int> variantId = 0.obs;
  List<dynamic> itemsData = [];

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getProductionDataList();
    //getVariantName();
  }

  Future<void> getProductionDataList({dynamic id = ''}) async {
    String endPoint = 'production/production-unit';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    productionUnit.value = productionUnitModelFromJson(response);
    update(['productionListUpdate']);
  }

  Future<void> getVariantName({dynamic id = ''}) async {
    //
    String endPoint = 'production/$id/variant';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    variantName = variantNameModelFromJson(response);
    update(['variantName']);
    //Utils.hidePopup();
  }

  Future<void> deleteProductionUnitData({id = ''}) async {
    Utils.showLoading();
    String endPoint = 'production/production-unit/$id';
    var response = await ApiClient()
        .delete(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    getProductionDataList();
    Utils.hidePopup();
    Utils.showSnackBar("Deleted Successfully");
  }

  Future<void> deleteProductionItemData({id = ''}) async {
    String endPoint = 'production/production-item/$id/remove';
    await ApiClient()
        .delete(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    // getProductionDataList();
    Utils.showSnackBar("Deleted Successfully");
  }

  Future<void> addNewProductionUnit(bool isUpdate, {String? id}) async {
    try {
      Utils.showLoading();
      String endPoint = isUpdate
          ? 'production/production-unit/$id'
          : 'production/production-unit';
      var body = jsonEncode({
        "food": foodId.value,
        "variant": variantId.value,
        "items": itemsData,
      });

      var response = isUpdate
          ? await ApiClient()
              .put(endPoint, body, header: Utils.apiHeader)
              .catchError(handleApiError)
          : await ApiClient()
              .post(endPoint, body, header: Utils.apiHeader)
              .catchError(handleApiError);

      if (response == null) return;
      clearProduction();
      getProductionDataList();
      Utils.hidePopup();
      Get.back();
      Utils.showSnackBar("Successfully Added");
    } catch (e) {
      Utils.hidePopup();
      Utils.showSnackBar("Something went wrong");
    }
  }

  Future<void> getSingleProductionUnit({dynamic id = ''}) async {
    String endPoint = 'production/production-unit/$id';
    var response = await ApiClient()
        .get(endPoint, header: Utils.apiHeader)
        .catchError(handleApiError);
    singleProductionUnit.value = singleProductionUnitFromJson(response);
    update();
    print('checkResponseDetails${singleProductionUnit}');
  }

  clearProduction() {
    foodId.value = 0;
    variantId.value = 0;
    totalAmount = 0;
    productionItem.clear();
    ingredients.clear();
    itemsData.clear();
  }
}
