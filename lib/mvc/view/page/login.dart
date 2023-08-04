import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:klio_staff/mvc/view/page/kitchen.dart';
import 'package:klio_staff/service/api/api_client.dart';
import 'package:klio_staff/service/local/shared_pref.dart';
import '../../../constant/color.dart';
import '../../../constant/value.dart';
import '../../../utils/utils.dart';
import '../widget/custom_widget.dart';
import 'home.dart';
import 'dart:typed_data';
import 'package:nfc_manager/nfc_manager.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final formKey = GlobalKey<FormState>();

  TextEditingController controllerEmail = TextEditingController();
  TextEditingController controllerPass = TextEditingController();
  String selected = 'Login as Staff';
  bool staffUser = true;
  bool passHide = true;

  ValueNotifier<dynamic> nfcResult = ValueNotifier(null);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    applyThem(darkMode);
    tagRead();
  }

  @override
  void dispose() {
    controllerEmail.dispose();
    controllerPass.dispose();
    //NfcManager.instance.stopSession();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryBackground,
        elevation: 3,
        title: Text("klio",
            style: TextStyle(
                color: textSecondary,
                fontSize: fontVeryBig,
                fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: topBarIconBtn(
                Image.asset('assets/moon.png', color: primaryColor),
                primaryBackground,
                0,
                25,
                35, onPressed: () {
              darkMode ? darkMode = false : darkMode = true;
              applyThem(darkMode);
              setState(() {});
            }),
          ),
        ],
      ),
      body: Center(
        child: SizedBox(
          height: 500,
          width: 330,
          child: Card(
            elevation: 3,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            color: secondaryBackground,
            child: Container(
              height: Size.infinite.height,
              width: Size.infinite.width,
              padding: EdgeInsets.all(30),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'User Login',
                        style: TextStyle(
                            fontSize: fontVeryBig,
                            fontWeight: FontWeight.bold,
                            color: primaryText),
                      ),
                      SizedBox(height: 10),
                      Text('Enter your details to sign in your user account',
                          style: TextStyle(
                              fontSize: fontVerySmall, color: textSecondary)),
                      SizedBox(height: 30),
                      SizedBox(
                        height: 50,
                        child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border:
                                    Border.all(color: textSecondary, width: 1)),
                            child: DropdownButton<String>(
                              items: loginTypes.map((dynamic val) {
                                return DropdownMenuItem<String>(
                                  value: val,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Text(val,
                                        style: TextStyle(
                                            color: primaryText,
                                            fontSize: fontVerySmall)),
                                  ),
                                );
                              }).toList(),
                              borderRadius: BorderRadius.circular(30),
                              underline: SizedBox(),
                              isExpanded: true,
                              dropdownColor: secondaryBackground,
                              value: selected,
                              onChanged: (value) {
                                if (value == loginTypes[0]) {
                                  staffUser = true;
                                } else {
                                  staffUser = false;
                                }
                                setState(() => selected = value!);
                                SharedPref().saveValue('loginType', selected);
                              },
                            )),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        child: TextFormField(
                            onChanged: (text) async {},
                            onEditingComplete: () async {},
                            keyboardType: TextInputType.text,
                            controller: controllerEmail,
                            validator: (value) {
                              if (Utils.isEmailValid(value!)) {
                                return null;
                              } else {
                                return "Invalid Email";
                              }
                            },
                            style: TextStyle(
                                fontSize: fontVerySmall, color: primaryText),
                            decoration: InputDecoration(
                              fillColor: textSecondary,
                              suffixIcon: Image.asset(
                                'assets/user.png',
                                color: textSecondary,
                              ),
                              hintText: "Username",
                              labelText: "Email Address",
                              labelStyle: TextStyle(
                                  fontSize: fontVerySmall,
                                  color: textSecondary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: textSecondary,
                                  )),
                              hintStyle: TextStyle(
                                  fontSize: fontVerySmall,
                                  color: textSecondary),
                            )),
                      ),
                      SizedBox(height: 10),
                      SizedBox(
                        height: 50,
                        child: TextFormField(
                            onChanged: (text) async {},
                            onEditingComplete: () async {},
                            keyboardType: TextInputType.text,
                            obscureText: passHide,
                            controller: controllerPass,
                            validator: (value) {
                              if (Utils.isPasswordValid(value!)) {
                                return null;
                              } else {
                                return "Minimum password length is six";
                              }
                            },
                            style: TextStyle(
                                fontSize: fontVerySmall, color: primaryText),
                            decoration: InputDecoration(
                              fillColor: textSecondary,
                              suffixIcon: GestureDetector(
                                onTap: (){
                                  setState(() {
                                    passHide=!passHide;
                                  });
                                },
                                child: Image.asset(
                                  'assets/hide.png',
                                  color: textSecondary,
                                ),
                              ),
                              hintText: "Password",
                              labelText: "Password",
                              labelStyle: TextStyle(
                                  fontSize: fontVerySmall,
                                  color: textSecondary),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(40),
                                  borderSide: BorderSide(
                                    width: 1,
                                    color: textSecondary,
                                  )),
                              hintStyle: TextStyle(
                                  fontSize: fontVerySmall, color: primaryText),
                            )),
                      ),
                      const SizedBox(height: 30),
                      normalButton('Login', primaryColor, white,
                          onPressed: logIn),
                      const SizedBox(height: 20),
                      FutureBuilder<bool>(
                          future: NfcManager.instance.isAvailable(),
                          builder: (context, ss) {
                            if (ss.data == true) tagRead();
                            return ss.data != true
                                ? Center(
                                    child: Text(
                                      'NFC login is not available',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: red),
                                    ),
                                  )
                                : Text(
                                    'NFC login available',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor),
                                  );
                          }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: secondaryBackground,
    );
  }

  void tagRead() {
    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        nfcResult.value = tag.data;
        NfcManager.instance.stopSession();
        Map tagData = tag.data;
        Map tagNdef = tagData['ndef'];
        if (tagNdef['cachedMessage'] == null) {
          Utils.showSnackBar("Empty Card");
          return;
        }
        Map cachedMessage = tagNdef['cachedMessage'];
        Map records = cachedMessage['records'][0];
        Uint8List payload = records['payload'];
        String payloadAsString = String.fromCharCodes(payload);
        final emailStartIndex = payloadAsString.indexOf("/");
        final passwordStartIndex = payloadAsString.lastIndexOf("/");
        final email =
            payloadAsString.substring(emailStartIndex + 1, passwordStartIndex);
        final password = payloadAsString.substring(passwordStartIndex + 1);

        print(email.isNotEmpty);
        print(password.isNotEmpty);

        if (email.isNotEmpty && password.isNotEmpty) {
          controllerEmail.text = email;
          controllerPass.text = password;

          logIn(directLogin: false);
        }
      },
    );
  }

  logIn({bool directLogin = true}) async {
    if (formKey.currentState!.validate() || directLogin) {
      Utils.showLoading();
      formKey.currentState!.save();
      var response = await ApiClient().post('login', {
        "email": directLogin ? "admin@gmail.com" : controllerEmail.text,
        "password": directLogin ? "12345678" : controllerPass.text,
      }).catchError((e) {
        Utils.showSnackBar("Invalid Username or Password");
      });
      Utils.hidePopup();
      if (response == null) return;
      Utils.showSnackBar(jsonDecode(response)["message"]);
      await SharedPref().saveValue('token', jsonDecode(response)["token"]);
      await SharedPref().saveValue('loginType', selected);

      if (staffUser) {
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (BuildContext context) => Home()));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => const Kitchen()));
      }
    }
  }
}
