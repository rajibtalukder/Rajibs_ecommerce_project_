import 'dart:convert';

import 'package:get/get.dart';
import 'package:klio_staff/constant/value.dart';
import 'package:klio_staff/mvc/controller/error_controller.dart';
import '../../constant/constant.dart';
import '../../service/api/api_client.dart';
import '../../utils/utils.dart';
import '../model/square_device_code_model.dart';

class PaymentController extends GetxController with ErrorController {
  SquareDeviceCodeModel? squareDeviceCode;

  static final paymentAPIHeader = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $squareToken'
  };

  Future<void> createDeviceCode() async {
    Utils.showLoading();
    String endPoint = 'v2/devices/codes';
    var body = jsonEncode({
      "idempotency_key": "4bffb735-5ea9-45b4-889a-d33200b12ad2",
      "device_code": {"name": "Counter 1", "product_type": "TERMINAL_API"}
    });
    var response = await ApiClient()
        .post(endPoint, body,
            header: paymentAPIHeader, differentBaseUrl: squareBaseUrl)
        .catchError(handleApiError);
    if (response == null) return;

    squareDeviceCode = SquareDeviceCodeModel.fromJson(json.decode(response));
    update(["updateSquare"]);
    Utils.hidePopup();
  }

  Future<void> checkStatus() async {
    if (squareDeviceCode == null) {
      Utils.showSnackBar("Device code is not available");
      return;
    }
    Utils.showLoading();
    String endPoint = 'v2/devices/codes/${squareDeviceCode?.deviceCode.id}';

    var response = await ApiClient()
        .get(endPoint,
            header: paymentAPIHeader, differentBaseUrl: squareBaseUrl)
        .catchError(handleApiError);

    if (response == null) return;

    squareDeviceCode = SquareDeviceCodeModel.fromJson(json.decode(response));
    update(["updateSquare"]);
    Utils.hidePopup();
  }
}
