import 'package:flutter/material.dart';
import 'package:material_segmented_control/material_segmented_control.dart';
import 'package:multi_dropdown/multiselect_dropdown.dart';
import 'package:nfc_manager/nfc_manager.dart';
import '../../../constant/color.dart';
import '../../../constant/value.dart';
import '../../../service/printer/print_service.dart';
import '../../../utils/utils.dart';
import '../widget/custom_widget.dart';

class NFCManagement extends StatefulWidget {
  const NFCManagement({Key? key}) : super(key: key);

  @override
  State<NFCManagement> createState() => _NFCManagementState();
}

class _NFCManagementState extends State<NFCManagement> {
  int _currentSelection = 0;
  TextEditingController customerID = TextEditingController();
  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPass = TextEditingController();

  ValueNotifier<bool> result = ValueNotifier(false);

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPass.dispose();
    NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Column(
          children: [
            itemTitleHeader(),
            customTapBarHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 80),
                children: [
                  wrapWIthRow(
                    SizedBox(
                      width: 400,
                      child: Text(
                        _currentSelection == 0
                            ? 'Enter email and password of the staff to create login and attendance card'
                            : 'Enter customer id to create reward card',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: fontBig, color: primaryText),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (_currentSelection == 1) wrapWIthRow(customDropDown()),
                  if (_currentSelection == 0)
                    wrapWIthRow(
                        customTextField(controllerEmail, "Email Address")),
                  if (_currentSelection == 0) const SizedBox(height: 20),
                  if (_currentSelection == 0)
                    wrapWIthRow(customTextField(controllerPass, "Password")),
                  const SizedBox(height: 20),
                  wrapWIthRow(
                      normalButton('Write', primaryColor, white, onPressed: () {
                    print("/${controllerEmail.text}/${controllerPass.text}");

                    if (_currentSelection == 0 &&
                        Utils.isPasswordValid(controllerPass.text) &&
                        Utils.isEmailValid(controllerEmail.text)) {
                      _ndefWrite();
                    } else if (_currentSelection == 1 &&
                        Utils.isIDValid(customerID.text)) {
                      _ndefWrite();
                    } else {
                      Utils.showSnackBar("Please provide valid info");
                    }
                  })),
                  const SizedBox(height: 40),
                  wrapWIthRow(ValueListenableBuilder<dynamic>(
                    valueListenable: result,
                    builder: (context, value, _) {
                      return result.value
                          ? Text(
                              'Writing... Please tap the card into the nfc reader',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: green),
                            )
                          : const SizedBox(height: 20);
                    },
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget customDropDown() {
    return SizedBox(
      width: 300,
      child: MultiSelectDropDown(
        backgroundColor: secondaryBackground,
        optionsBackgroundColor: secondaryBackground,
        selectedOptionTextColor: primaryText,
        selectedOptionBackgroundColor: primaryColor,
        showClearIcon: false,
        optionTextStyle: TextStyle(color: primaryText, fontSize: 16),
        onOptionSelected: (List<ValueItem> selectedOptions) {
          if (selectedOptions.first.value == null) return;
          customerID.text = (selectedOptions.first.value == '0'
              ? ""
              : selectedOptions.first.value)!;
          print(customerID.text);
        },
        options: homeController.customers.value.data!.map((e) {
          return ValueItem(
            label: e.name ?? "",
            value: e.id.toString(),
          );
        }).toList(),
        hint: 'Select Customer',
        hintColor: primaryText,
        selectionType: SelectionType.single,
        chipConfig: const ChipConfig(wrapType: WrapType.wrap),
        dropdownHeight: 300,
        selectedOptionIcon: const Icon(Icons.check_circle),
        inputDecoration: BoxDecoration(
          color: secondaryBackground,
          borderRadius: const BorderRadius.all(Radius.circular(50)),
          border: Border.all(
            color: textSecondary.withOpacity(0.4),
          ),
        ),
      ),
    );
  }

  Widget wrapWIthRow(Widget widget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [widget],
    );
  }

  SizedBox customTextField(TextEditingController controller, String name) {
    return SizedBox(
      height: 50,
      width: 350,
      child: TextFormField(
        onChanged: (text) async {},
        onEditingComplete: () async {},
        keyboardType: TextInputType.text,
        controller: controller,
        style: TextStyle(fontSize: fontVerySmall, color: primaryText),
        decoration: InputDecoration(
          fillColor: textSecondary,
          labelText: name,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          hintStyle: TextStyle(fontSize: fontVerySmall, color: primaryText),
        ),
      ),
    );
  }

  itemTitleHeader() {
    return Builder(builder: (context) {
      if (_currentSelection == 0) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Staff Card',
              style: TextStyle(fontSize: fontBig, color: primaryText),
            ),
          ),
        );
      } else {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Customer Card',
              style: TextStyle(fontSize: fontBig, color: primaryText),
            ),
          ),
        );
      }
    });
  }

  Widget customTapBarHeader() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: MaterialSegmentedControl(
              children: {
                0: Text(
                  'Assign staff card',
                  style:
                      TextStyle(color: _currentSelection == 0 ? white : black),
                ),
                1: Text(
                  'Assign customer card',
                  style:
                      TextStyle(color: _currentSelection == 1 ? white : black),
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
              onSegmentTapped: (index) {
                setState(() {
                  _currentSelection = index;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _ndefWrite() {
    result.value = true;
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      var ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        Utils.showSnackBar('Tag is not ndef writable');
        NfcManager.instance
            .stopSession(errorMessage: 'Tag is not ndef writable');
        return;
      }

      NdefMessage message = NdefMessage([
        NdefRecord.createText(_currentSelection == 0
            ? "/${controllerEmail.text}/${controllerPass.text}"
            : "/${customerID.text}"),
      ]);

      try {
        await ndef.write(message);
        Utils.showSnackBar('Successful');
        result.value = false;
        NfcManager.instance.stopSession();
      } catch (e) {
        Utils.showSnackBar(e.toString());
        result.value = false;
        NfcManager.instance.stopSession(errorMessage: e.toString());
        return;
      }
    });
  }
}
