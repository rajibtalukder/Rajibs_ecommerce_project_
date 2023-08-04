import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:klio_staff/mvc/controller/payment_controller.dart';
import '../../../../constant/color.dart';
import '../../widget/custom_widget.dart';

Widget squareDeviceCodeCreation() {
  List<String> header = [
    "name",
    "code",
    "product_type",
    "location_id",
    "status",
  ];
  PaymentController paymentController = Get.put(PaymentController());
  return GetBuilder<PaymentController>(
    id: "updateSquare",
    builder: (controller) {
      return controller.squareDeviceCode == null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                normalButton(
                  'Request Code',
                  primaryColor,
                  white,
                  onPressed: () {
                    controller.createDeviceCode();
                  },
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "The code should be use within 5 minutes or else it will not work",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        color: primaryText),
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "Once you used the code for Sign-in, you can reuse the device code to sign in to the same Square Terminal for subsequent sign-in attempts",
                    style: TextStyle(fontSize: 18, color: textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 30),
                DataTable(
                  dataRowHeight: 70,
                  columns: [
                    for (int i = 0; i < header.length; i++)
                      DataColumn(
                        label: Text(
                          header[i],
                          style: TextStyle(color: textSecondary),
                        ),
                      ),
                    // column to set the name
                  ],
                  rows: [
                    DataRow(
                      cells: [
                        DataCell(
                          Text(
                            controller.squareDeviceCode!.deviceCode.name,
                            style: TextStyle(color: primaryText),
                          ),
                        ),
                        DataCell(
                          Text(
                            controller.squareDeviceCode!.deviceCode.code,
                            style: TextStyle(color: primaryText),
                          ),
                        ),
                        DataCell(
                          Text(
                            controller.squareDeviceCode!.deviceCode.productType,
                            style: TextStyle(color: primaryText),
                          ),
                        ),
                        DataCell(
                          Text(
                            controller.squareDeviceCode!.deviceCode.locationId,
                            style: TextStyle(color: primaryText),
                          ),
                        ),
                        DataCell(
                          Text(
                            controller.squareDeviceCode!.deviceCode.status,
                            style: TextStyle(color: primaryText),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    normalButton(
                      'Request Code',
                      primaryColor,
                      white,
                      onPressed: () {
                        controller.createDeviceCode();
                      },
                    ),
                    const SizedBox(width: 20),
                    normalButton(
                      'Check Status',
                      primaryColor,
                      white,
                      onPressed: () {
                        controller.checkStatus();
                      },
                    ),
                  ],
                ),
              ],
            );
    },
  );
}
