import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:klio_staff/constant/color.dart';
import 'package:klio_staff/constant/value.dart';
import 'package:klio_staff/mvc/controller/transaction_management_controller.dart';
import 'package:klio_staff/mvc/view/widget/custom_widget.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:klio_staff/mvc/model/bank_list_data_model.dart' as Bank;
import 'package:klio_staff/mvc/model/transaction_list_data_model.dart'
    as Transaction;

class TransactionManagement extends StatefulWidget {
  const TransactionManagement({Key? key}) : super(key: key);

  @override
  State<TransactionManagement> createState() => _TransactionManagementState();
}

class _TransactionManagementState extends State<TransactionManagement>
    with SingleTickerProviderStateMixin {
  TransactionsController _transactionsController =
      Get.put(TransactionsController());
  TextEditingController? textController = TextEditingController();
  int _currentSelection = 0;
  late TabController controller;
  late ScrollController scrollController;

  @override
  void initState() {
    // TODO: implement initState
    controller = TabController(vsync: this, length: 2);
    controller.addListener(() {
      _currentSelection = controller.index;
      _transactionsController.update(['changeCustomTabBar']);

      if (_currentSelection == 0) {
          textController!.text = '';
          _transactionsController.getBankByKeyword(showLoading: false);
      } else {
          textController!.text = '';
          _transactionsController
              .getBankTransactionByKeyword(showLoading: false);
      }
    });



    scrollController = ScrollController();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent * 0.95) {
        if (_currentSelection == 0 && !_transactionsController.isLoadingBank) {
          _transactionsController.bankListDataList();
        } else if (_currentSelection == 1 &&
            !_transactionsController.isLoadingTransition) {
          _transactionsController.transactionDataList();
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Column(
          children: [
            GetBuilder<TransactionsController>(
              id: "changeCustomTabBar",
              builder: (controller) => itemTitleHeader(),
            ),
            customTapbarHeader(controller),
            Expanded(
              child: TabBarView(controller: controller, children: [
                bankListDataTable(context),
                bankTransactionsDataTable(context),
              ]),
            )
          ],
        ),
      ),
    );
  }

  itemTitleHeader() {
    return Builder(builder: (context) {
      if (_currentSelection == 0) {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  'Bank',
                  style: TextStyle(fontSize: fontBig, color: primaryText),
                ),
              ),
              // Container(
              //   child: OutlinedButton.icon(
              //     icon: Icon(
              //       Icons.add,
              //       color: primaryText,
              //     ),
              //     label: Text(
              //       "Add New Bank",
              //       style: TextStyle(
              //         color: primaryText,
              //       ),
              //     ),
              //     onPressed: () {
              //       showCustomDialog(
              //           context, 'Add New Bank', newBankForm(), 100, 300);
              //     },
              //     style: ElevatedButton.styleFrom(
              //       side: const BorderSide(width: 1.0, color: primaryColor),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(25),
              //       ),
              //     ),
              //   ),
              // )
            ],
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 25),
                child: Text(
                  'Bank Transactions',
                  style: TextStyle(fontSize: fontBig, color: primaryText),
                ),
              ),
              // const SizedBox(height: 48)
            ],
          ),
        );
      }
    });
  }

  Widget customTapbarHeader(TabController controller) {
    Timer? stopOnSearch;
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          GetBuilder<TransactionsController>(
              id: 'changeCustomTabBar',
              builder: (context) {
                return Expanded(
                  flex: 1,
                  child: MaterialSegmentedControl(
                    children: {
                      0: Text(
                        'Bank List',
                        style: TextStyle(
                            color: _currentSelection == 0 ? white : black),
                      ),
                      1: Text(
                        'Bank Transactions',
                        style: TextStyle(
                            color: _currentSelection == 1 ? white : black),
                      ),
                    },
                    selectionIndex: _currentSelection,
                    borderColor: Colors.grey,
                    selectedColor: primaryColor,
                    unselectedColor: Colors.white,
                    borderRadius: 32.0,
                    disabledChildren: const [
                      6,
                    ],
                    onSegmentChosen: (index) {
                      // if (index == 0 &&
                      //     _transactionsController
                      //         .bankListData.value.data.isEmpty) {
                      //   _transactionsController.bankListDataList();
                      // } else if (index == 1 &&
                      //     _transactionsController
                      //         .transactionListData.value.data.isEmpty) {
                      //   _transactionsController.transactionDataList();
                      // }
                      print(index);
                      setState(() {
                        _currentSelection = index;
                        controller.index = _currentSelection;
                      });
                    },
                  ),
                );
              }),
          Container(
            margin: const EdgeInsets.only(left: 100),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Card(
                  elevation: 0.0,
                  child: SizedBox(
                      width: 300,
                      height: 40,
                      child: TextField(
                          onChanged: (text) async {
                            if (_currentSelection == 0) {
                              _transactionsController.searchText=text;
                              const duration = Duration(seconds: 1);
                              if (stopOnSearch != null) {
                                stopOnSearch?.cancel();
                              }
                              stopOnSearch = Timer(
                                  duration,
                                  () => _transactionsController
                                      .getBankByKeyword(keyword: text,showLoading: false));
                            } else {
                              _transactionsController.searchText=text;
                              const duration = Duration(seconds: 1);
                              if (stopOnSearch != null) {
                                stopOnSearch?.cancel();
                              }
                              stopOnSearch = Timer(
                                  duration,
                                  () => _transactionsController
                                      .getBankTransactionByKeyword(
                                          keyword: text,showLoading: false));
                            }
                          },
                          keyboardType: TextInputType.text,
                          controller: textController,
                          textInputAction: TextInputAction.search,
                          style: const TextStyle(
                            fontSize: fontSmall,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white10,
                            contentPadding:
                                const EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 0.0),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.close,
                                color: textSecondary,
                              ),
                              onPressed: () {
                                if (_currentSelection == 0) {
                                  _transactionsController.searchText='';
                                  setState(() {
                                    textController!.text = '';
                                    _transactionsController.getBankByKeyword();
                                  });
                                } else {
                                  _transactionsController.searchText='';
                                  setState(() {
                                    textController!.text = '';
                                    _transactionsController
                                        .getBankTransactionByKeyword();
                                  });
                                }
                              },
                            ),
                            hintText: "Search Item",
                            hintStyle: const TextStyle(
                                fontSize: fontSmall, color: black),
                            border: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            disabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            errorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                            focusedErrorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1, color: Colors.transparent)),
                          ))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget bankListDataTable(BuildContext context) {
    return Card(
      color: secondaryBackground,
      child: SingleChildScrollView(
        controller: scrollController,
        child: GetBuilder<TransactionsController>(
            id: 'bankId',
            builder: (controller) {
              if (controller.bankListData.value.data.isEmpty && controller.haveMoreBank) {
                return Center(
                    child: Container(
                        height: 40,
                        width: 40,
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.3),
                        child: CircularProgressIndicator()));
              }
              if (!controller.haveMoreBank &&
                  controller.bankListData.value.data.isNotEmpty &&
                  controller.bankListData.value.data.last.id != 0) {
                controller.bankListData.value.data.add(Bank.Datum(id: 0));
              }else if(controller.bankListData.value.data.isEmpty && !controller.haveMoreBank){
                controller.bankListData.value.data.add(Bank.Datum(id: 0));
              }
              return DataTable(
                  dataRowHeight: 70,
                  columns: [
                    // column to set the name
                    DataColumn(
                      label: Text(
                        'SL NO',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Bank Name',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'AC Name',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'AC Number',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Branch Name',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Balance',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                  ],
                  rows: controller.bankListData.value.data.map(
                    (item) {
                      if (item.id == 0 && !controller.haveMoreBank) {
                        return DataRow(cells: [
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(Text('No Data',
                              style: TextStyle(color: primaryText))),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                        ]);
                      } else if (item ==
                              controller.bankListData.value.data.last &&
                          !controller.isLoadingBank &&
                          controller.haveMoreBank) {
                        return const DataRow(cells: [
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator()),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                        ]);
                      }
                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '${item.id ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.name ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.accountName ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.accountNumber ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.branchName ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${item.balance ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList());
            }),
      ),
    );
  }

  Widget bankTransactionsDataTable(BuildContext context) {
    return Card(
      color: secondaryBackground,
      child: SingleChildScrollView(
        controller: scrollController,
        child: GetBuilder<TransactionsController>(
            id: 'transId',
            builder: (controller) {
              if (!controller.haveMoreTransition &&
                  controller.transactionListData.value.data.isNotEmpty &&
                  controller.transactionListData.value.data.last.id != 0) {
                controller.transactionListData.value.data
                    .add(Transaction.Datum(id: 0));
              }else if(controller.transactionListData.value.data.isEmpty && !controller.haveMoreTransition){
                controller.transactionListData.value.data
                    .add(Transaction.Datum(id: 0));
              }
              return DataTable(
                  columnSpacing: 50,
                  columns: [
                    // column to set the name
                    DataColumn(
                      label: Text(
                        'SL NO',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Bank',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Date',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Withdraw/ID',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Amount',
                        style: TextStyle(color: textSecondary),
                      ),
                    ),
                  ],
                  rows: controller.transactionListData.value.data.map(
                    (item) {
                      if (item.id == 0 && !controller.haveMoreTransition) {
                        return DataRow(cells: [
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(Text('No Data',
                              style: TextStyle(color: primaryText))),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          const DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                        ]);
                      } else if (item ==
                              controller.transactionListData.value.data.last &&
                          !controller.isLoadingTransition &&
                          controller.haveMoreTransition) {
                        return const DataRow(cells: [
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator()),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                          DataCell(CircularProgressIndicator(
                              color: Colors.transparent)),
                        ]);
                      }

                      return DataRow(
                        cells: [
                          DataCell(
                            Text(
                              '${item.id ?? ""}',
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.bank?.name ?? "",
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.date ?? "",
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.withdrawDepositeId ?? "",
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                          DataCell(
                            Text(
                              item.amount ?? "",
                              style: TextStyle(color: primaryText),
                            ),
                          ),
                        ],
                      );
                    },
                  ).toList());
            }),
      ),
    );
  }

  Widget newBankForm() {
    return Container(
        padding: const EdgeInsets.all(25.0),
        child: Form(
          key: _transactionsController.uploadBankKey,
          child: ListView(
            children: [
              textRow('Bank Name', 'Account Name'),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: TextFormField(
                        controller: _transactionsController.nameCtlr,
                        validator: _transactionsController.textValidator,
                        decoration: InputDecoration(
                          fillColor: secondaryBackground,
                          hintText: 'Enter Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          hintStyle: TextStyle(
                              fontSize: fontVerySmall, color: textSecondary),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: TextFormField(
                        controller: _transactionsController.accNameCtlr,
                        validator: _transactionsController.textValidator,
                        decoration: InputDecoration(
                          fillColor: secondaryBackground,
                          hintText: 'Enter Account Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          hintStyle: TextStyle(
                              fontSize: fontVerySmall, color: textSecondary),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              textRow('Account Number', 'Branch Name'),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: TextFormField(
                        controller: _transactionsController.accNumCtlr,
                        validator: _transactionsController.textValidator,
                        decoration: InputDecoration(
                          fillColor: secondaryBackground,
                          hintText: 'Enter Account Number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          hintStyle: TextStyle(
                              fontSize: fontVerySmall, color: textSecondary),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: TextFormField(
                        controller: _transactionsController.branchCtlr,
                        validator: _transactionsController.textValidator,
                        decoration: InputDecoration(
                          fillColor: secondaryBackground,
                          hintText: 'Enter Branch Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          hintStyle: TextStyle(
                              fontSize: fontVerySmall, color: textSecondary),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              textRow('Balance', 'Signature'),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: TextFormField(
                        controller: _transactionsController.balanceCtlr,
                        validator: _transactionsController.textValidator,
                        decoration: InputDecoration(
                          fillColor: secondaryBackground,
                          hintText: 'Enter Balance',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          hintStyle: TextStyle(
                              fontSize: fontVerySmall, color: textSecondary),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      flex: 1,
                      child: SizedBox(
                          height: 52,
                          child: MaterialButton(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6)),
                            color: primaryBackground,
                            onPressed: () async {
                              _transactionsController.signatureStoreImage =
                                  await _transactionsController.getImage();
                            },
                            child: GetBuilder<TransactionsController>(
                                builder: (context) {
                              return Text(
                                _transactionsController.signatureStoreImage ==
                                        null
                                    ? 'No file chosen'
                                    : basename(_transactionsController
                                        .signatureStoreImage!.path
                                        .split(Platform.pathSeparator.tr)
                                        .last),
                                style: TextStyle(
                                    color: textSecondary, fontSize: fontSmall),
                              );
                            }),
                          )
                          // child: normalButton('No file chosen', primaryColor, primaryColor),
                          )),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  normalButton('Submit', primaryColor, white, onPressed: () {
                    if (_transactionsController.uploadBankKey.currentState!
                        .validate()) {
                      _transactionsController.addNewBank(
                          _transactionsController.nameCtlr.text,
                          _transactionsController.accNameCtlr.text,
                          _transactionsController.accNumCtlr.text,
                          _transactionsController.branchCtlr.text,
                          _transactionsController.balanceCtlr.text,
                          _transactionsController.signatureStoreImage!);
                      _transactionsController.nameCtlr.clear();
                      _transactionsController.accNameCtlr.clear();
                      _transactionsController.accNumCtlr.clear();
                      _transactionsController.branchCtlr.clear();
                      _transactionsController.balanceCtlr.clear();
                      _transactionsController.signatureStoreImage = null;
                    }
                  }),
                ],
              )
            ],
          ),
        ));
  }
}
