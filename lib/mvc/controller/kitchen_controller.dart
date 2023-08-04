import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../constant/value.dart';
import '../../service/api/api_client.dart';
import '../../service/local/shared_pref.dart';
import '../../utils/utils.dart';
import '../model/kitchen_order.dart';
import 'error_controller.dart';

class KitchenController extends GetxController with ErrorController {
  Rx<KitchenOrder> kitchenOrder = KitchenOrder().obs;


  Future<void> getKitchenOrder(bool isUpdate) async {
    token = (await SharedPref().getValue('token'))!;

    Utils.showLoading();
    if (isUpdate) {
      List<int> ids = [];
      List<String> availableTime = [];
      for (int i = 0; i < kitchenOrder.value.data!.length; i++) {
        if (kitchenOrder.value.data![i].id != null &&
            kitchenOrder.value.data![i].availableTime != null &&  kitchenOrder.value.data![i].availableTime!.isNotEmpty) {
          ids.add(kitchenOrder.value.data![i].id!);
          String time = kitchenOrder.value.data![i].availableTime!;
          int hour = int.parse(time[0] + time[1]);
          int minute = int.parse(time[3] + time[4]);
          int second = int.parse(time[6] + time[7]);
          if (minute <= 0) {
            if (hour <= 0) {
              hour == 0;
              minute = 0;
            } else {
              hour--;
              minute = 60;
            }
          } else {
            minute--;
          }

          String hourS = hour < 10 ? "0$hour" : hour.toString();
          String minuteS = minute < 10 ? "0$minute" : minute.toString();
          String secondS = second < 10 ? "0$second" : second.toString();

          availableTime.add("$hourS:$minuteS:$secondS");
        }
      }
      var queryParameters = {"ids": ids, "available_times": availableTime};


      String queryString = queryParameters.entries
          .map((e) => '${e.key}[]=${e.value.join('&${e.key}[]=')}')
          .join('&');

      log(queryString);
      log(ids.length.toString());
      log(availableTime.length.toString());


      var response = await ApiClient()
          .get(
            'kitchen/order?$queryString',
            header: Utils.apiHeader,
          )
          .catchError(handleApiError);

      kitchenOrder.value = kitchenOrderFromJson(response);

      update(['changeKitchenUi']);
      Utils.hidePopup();
      return;
    }

    var response = await ApiClient()
        .get(
          'kitchen/order',
          header: Utils.apiHeader,
        )
        .catchError(handleApiError);

    kitchenOrder.value = kitchenOrderFromJson(response);

    Utils.hidePopup();

    print("---- ******************************** 12121");

  }

  Future<bool> updateTimer(int id, List<int> itemList, String status) async {
    var response = await ApiClient()
        .put('kitchen/$id/order',
            jsonEncode({"item_ids": itemList, "status": status}),
            header: Utils.apiHeader)
        .catchError(handleApiError);
    if (response == null) false;
    return true;
  }

  Future<bool> acceptOrder(int id, List<int> itemList, String status) async {
    var response = await ApiClient()
        .put('kitchen/$id/order',
            jsonEncode({"item_ids": itemList, "status": status}),
            header: Utils.apiHeader)
        .catchError(handleApiError);
    if (response == null) false;
    return true;
  }
}
