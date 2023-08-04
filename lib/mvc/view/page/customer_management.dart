import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constant/color.dart';
import '../../../constant/value.dart';
import '../../controller/customer_management_controller.dart';
import '../dialog/custom_dialog.dart';
import '../widget/custom_widget.dart';

class CustomerManagement extends StatefulWidget {
  const CustomerManagement({Key? key}) : super(key: key);

  @override
  State<CustomerManagement> createState() => _CustomerManagementState();
}

class _CustomerManagementState extends State<CustomerManagement> with SingleTickerProviderStateMixin {
  CustomerController cusController = Get.put(CustomerController());

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              children: [
                itemHeaderTitle(),
                Expanded(child: customerDataTable()),
              ],
            )));
  }
  itemHeaderTitle() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        mainAxisAlignment:  MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 25),
            child: Text(
              'Customer List',
              style: TextStyle(fontSize: fontBig, color: primaryText),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 25),
            child: Row(
              children: [
                OutlinedButton.icon(
                  icon: Icon(
                    Icons.add,
                    color: primaryText,
                  ),
                  label: Text(
                    "Add New Customer",
                    style: TextStyle(
                      color: primaryText,
                    ),
                  ),
                  onPressed: () {
                    showCustomDialog(context, "Add New Customer",
                        addNewCustomer(), 30, 400);
                  },
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(width: 1.0, color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget customerDataTable() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: secondaryBackground,
        child: SingleChildScrollView(
            child: GetBuilder<CustomerController>(builder: (customerController) {
              if(customerController.customerData.value.data!.isEmpty){
                return  Center(child: Container(
                    height:40,
                    width: 40,
                    margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.3),
                    child: const CircularProgressIndicator()));
              }
              return DataTable(
                dataRowHeight: 70,
                columns:
                [
                  DataColumn(
                    label: Text(
                      'SL NO',
                      style: TextStyle(color: textSecondary),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Name',
                      style: TextStyle(color: textSecondary),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Action',
                      style: TextStyle(color: textSecondary),
                    ),
                  )
                ],
                //rows: [],

                rows: customerController.customerData.value.data!
                    .map((item)=>DataRow(
                    cells: [
                      DataCell(
                          Text('${item.id ?? ""}',
                            style: TextStyle(color: primaryText),
                          )
                      ),
                      DataCell(
                          Text('${item.name ?? ""}',
                            style: TextStyle(color: primaryText),
                          )
                      ),
                      DataCell(
                        Container(
                          height: 35,
                          width:35,
                          decoration: BoxDecoration(
                            color:const Color(0xffFFE7E6),
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              cusController.getSingleCustomerDetails(item.id)
                              .then((value) {
                                showCustomDialog(context, 'View Customer Details',
                                    viewCustomer(), 100, 300);
                              });
                            },
                            child: Image.asset(
                              "assets/hide.png",
                              height: 15,
                              width: 15,
                              color: const Color(0xff00A600),
                            ),
                          ),
                        ),
                      )
                    ])) .toList(),

              );
            })),
      ),
    );
  }

  Widget addNewCustomer() {
    return
      Container(
          height: Size.infinite.height,
          width: Size.infinite.width,
          padding: const EdgeInsets.all(30),
          child: Form(
            key: cusController.uploadCustomerFormKey,
            child: ListView(children: [
              textRow('First Name', 'Last Name'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                    height:52,
                    child: TextFormField(
                         controller: cusController.fNameCtlr,
                        validator: cusController.textValidator,
                        style: TextStyle(color: primaryText),
                        decoration: InputDecoration(
                          fillColor: secondaryBackground,
                          hintText: 'Enter First Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: alternate)
                          ),
                          hintStyle:
                          TextStyle(fontSize: fontVerySmall, color: textSecondary),

                        ),keyboardType: TextInputType.text),
                  ),),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height:52,
                      child: TextFormField(
                          controller: cusController.lNameCtlr,
                          validator: cusController.textValidator,
                          style: TextStyle(color: primaryText),
                          decoration: InputDecoration(
                            fillColor: secondaryBackground,
                            hintText: 'Enter Last Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: alternate)
                            ),
                            hintStyle:
                            TextStyle(fontSize: fontVerySmall, color: textSecondary),

                          ),keyboardType: TextInputType.text),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              textRow('Email', 'Phone'),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height:52,
                      child: TextFormField(
                          controller: cusController.emailCtlr,
                          validator: cusController.textValidator,
                          style: TextStyle(color: primaryText),
                          decoration: InputDecoration(
                            fillColor: secondaryBackground,
                            hintText: 'Enter Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: alternate)
                            ),
                            hintStyle:
                            TextStyle(fontSize: fontVerySmall, color: textSecondary),

                          ),keyboardType: TextInputType.emailAddress),
                    ),),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height:52,
                      child: TextFormField(
                          controller: cusController.phoneCtlr,
                          validator: cusController.textValidator,
                          style: TextStyle(color: primaryText),
                          decoration: InputDecoration(
                            fillColor: secondaryBackground,
                            hintText: 'Enter Phone Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: alternate)
                            ),
                            hintStyle:
                            TextStyle(fontSize: fontVerySmall, color: textSecondary),
                            ),
                          keyboardType: TextInputType.number),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              textRow('Delivery Address', ''),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height:52,
                      child: TextFormField(
                          controller: cusController.addressCtlr,
                          validator: cusController.textValidator,
                          style: TextStyle(color: primaryText),
                          decoration: InputDecoration(
                            fillColor: secondaryBackground,
                            hintText: 'Enter Delivery Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: alternate)
                            ),
                            hintStyle:
                            TextStyle(fontSize: fontVerySmall, color: textSecondary),

                          ),keyboardType: TextInputType.text),
                    ),),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: SizedBox(
                      height:52,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    normalButton('Submit', primaryColor, white, onPressed: (){
                      if(cusController.uploadCustomerFormKey.currentState!.validate()){
                        cusController.addNewCustomer(
                            cusController.fNameCtlr.text,
                            cusController.lNameCtlr.text,
                            cusController.emailCtlr.text,
                            cusController.phoneCtlr.text,
                            cusController.addressCtlr.text,
                        );
                        cusController.fNameCtlr.clear();
                        cusController.lNameCtlr.clear();
                        cusController.emailCtlr.clear();
                        cusController.phoneCtlr.clear();
                        cusController.addressCtlr.clear();
                      }
                    }),
                  ],
                )
            ]),
          ),
    );
  }

  Widget viewCustomer() {
    return Container(
      padding: const EdgeInsets.only(left: 40, right: 15),
      child: ListView(
        children: [
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text(
                      'Name:',
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    )),
                Expanded(
                    flex: 7,
                    child: Text(
                      cusController.singleCustomerData.value.data!.name.toString(),
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ),
          const SizedBox(height:10),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text(
                      'Email:',
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    )),
                Expanded(
                    flex: 7,
                    child: Text(
                      cusController.singleCustomerData.value.data!.email.toString(),
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ),
          const SizedBox(height:10),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text(
                      'Phone:',
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    )),
                Expanded(
                    flex: 7,
                    child: Text(
                      cusController.singleCustomerData.value.data!.phone.toString(),
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    ),),
              ],
            ),
          ),
          const SizedBox(height:10),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text(
                      'Delivery Address:',
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    )),
                Expanded(
                    flex: 7,
                    child: Text(
                      cusController.singleCustomerData.value.data!.deliveryAddress.toString(),
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ),
          const SizedBox(height:10),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text(
                      'Number of Visit:',
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    )),
                Expanded(
                    flex: 7,
                    child: Text(
                      cusController.singleCustomerData.value.data!.noOfVisit.toString(),
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ),
          const SizedBox(height:10),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text(
                      'Last Visit:',
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    )),
                Expanded(
                    flex: 7,
                    child: Text(
                      cusController.singleCustomerData.value.data!.lastVisit.toString(),
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    ),),
              ],
            ),
          ),
          const SizedBox(height:10),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text(
                      'Point Acquired:',
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    )),
                Expanded(
                    flex: 7,
                    child: Text(
                      cusController.singleCustomerData.value.data!.pointsAcquired.toString(),
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ),
          const SizedBox(height:10),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                    flex: 3,
                    child: Text(
                      'Used Points:',
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    )),
                Expanded(
                    flex: 7,
                    child: Text(
                      cusController.singleCustomerData.value.data!.usedPoints.toString(),
                      style: TextStyle(
                          fontSize: fontVerySmall,
                          color: primaryText,
                          fontWeight: FontWeight.bold),
                    )),
              ],
            ),
          ),
          const SizedBox(height:10),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }

}
