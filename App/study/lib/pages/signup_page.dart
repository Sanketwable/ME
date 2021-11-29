import 'dart:io';

import 'package:flutter/Material.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_svg/svg.dart';
import 'package:getwidget/getwidget.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'package:study/components/already_have_an_account_acheck.dart';
import 'package:study/components/rounded_button.dart';
import 'package:study/components/rounded_input_field.dart';
import 'package:study/components/text_field_container.dart';
import 'package:study/pages/Faculty/faculty_info.dart';
import 'package:study/pages/Student/student_info.dart';

import 'package:study/pages/login_page.dart';

import '../constants/constants.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import '../controllers/token.dart';

final signUpEmailController = TextEditingController();
final signUpPasswordController = TextEditingController();
var token = "";
var _passwordVisible = false;
// ignore: prefer_typing_uninitialized_variables

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final signUpEmailController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  // ignore: prefer_typing_uninitialized_variables
  var loginType;
  var otpRequested = false;
  var validOtp = true;
  var incorrectOTP = false;
  var userName = "";
  var userID = "";
  var signUpError = "";
  var signUpErrorWithOTP = "";
  var incorrectDetails = false;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text("Study"),
        ),
        body: SizedBox(
          height: size.height,
          width: double.infinity,
          // Here i can use size.width but use double.infinity because both work as a same
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                child: Image.asset(
                  "assets/images/signup_top.png",
                  width: size.width * 0.35,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Image.asset(
                  "assets/images/main_bottom.png",
                  width: size.width * 0.25,
                ),
              ),
              SingleChildScrollView(
                child: otpRequested
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: GestureDetector(
                          onTap: () {},
                          child: SizedBox(
                            // padding: const EdgeInsets.all(10),
                            height: 330,
                            child: Column(
                              children: [
                                incorrectOTP
                                    ? Text(
                                        signUpErrorWithOTP.toString(),
                                        style:
                                            const TextStyle(color: Colors.red),
                                      )
                                    : const Text(
                                        "Enter OTP",
                                        style: TextStyle(color: kPrimaryColor),
                                      ),
                                OTPTextField(
                                  length: 6,
                                  width:
                                      MediaQuery.of(context).size.width * 0.7,
                                  fieldWidth: 30,
                                  style: const TextStyle(fontSize: 20),
                                  textFieldAlignment:
                                      MainAxisAlignment.spaceAround,
                                  fieldStyle: FieldStyle.underline,
                                  onCompleted: (pin) async {
                                    var dialogContext =
                                        showAlertDialog(context, "Signing Up");
                                    if (await signupWithOtp(pin) ==
                                        "verified") {
                                      Navigator.pop(dialogContext);

                                      store(
                                          'token',
                                          token,
                                          loginType.toString(),
                                          userName,
                                          userID);
                                      loginType == "faculty"
                                          ? Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => FacultyInfo(
                                                      userName, token)),
                                              ModalRoute.withName(
                                                  "/FacultyInfo"))
                                          : Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (_) => StudentInfo(
                                                      userName, token)),
                                              ModalRoute.withName(
                                                  "/StudentInfo"));
                                    } else {
                                      Navigator.pop(dialogContext);
                                      setState(() {
                                        validOtp = false;
                                        incorrectOTP = true;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          behavior: HitTestBehavior.opaque,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                            "SIGNUP",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: size.height * 0.03),
                          SvgPicture.asset(
                            "assets/icons/signup.svg",
                            height: size.height * 0.20,
                          ),
                          incorrectDetails
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  child: Text(
                                    signUpError.toString(),
                                    style: const TextStyle(
                                      color: Colors.red,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                )
                              : const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 20),
                                  child: Text(
                                    "Enter your details below to signup",
                                    style: TextStyle(color: Colors.black),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                          RoundedInputField(
                            textController: signUpEmailController,
                            hintText: "Your Email",
                            onChanged: (value) {},
                          ),
                          TextFieldContainer(
                            child: TextFormField(
                              keyboardType: TextInputType.text,
                              controller: signUpPasswordController,
                              obscureText: !_passwordVisible,
                              cursorColor: kPrimaryColor,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                icon: const Icon(
                                  Icons.lock,
                                  color: kPrimaryColor,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: kPrimaryColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _passwordVisible = !_passwordVisible;
                                    });
                                  },
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Container(
                            height: 55,
                            margin: const EdgeInsets.all(20),
                            child: DropdownButtonHideUnderline(
                              child: GFDropdown(
                                dropdownColor: kPrimaryLightColor,
                                focusColor: kPrimaryColor,
                                borderRadius: BorderRadius.circular(50),
                                dropdownButtonColor: kPrimaryLightColor,
                                value: loginType,
                                hint: Container(
                                    padding: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                      top: 10,
                                      bottom: 10,
                                    ),
                                    child: const Text(
                                      "Select Login Type",
                                    )),
                                onChanged: (newValue) {
                                  setState(() {
                                    loginType = newValue;
                                  });
                                },
                                items: ['faculty', 'student']
                                    .map((value) => DropdownMenuItem(
                                          value: value,
                                          child: Row(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.all(5.0),
                                                child: Icon(Icons.person_sharp,
                                                    color: kPrimaryColor),
                                              ),
                                              Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 15,
                                                    right: 10,
                                                    top: 10,
                                                    bottom: 10,
                                                  ),
                                                  child: Text(value)),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                              ),
                            ),
                          ),
                          RoundedButton(
                            text: "SIGNUP",
                            press: () async {
                              var alert =
                                  showAlertDialog(context, "Signing Up");
                              if (await signup() == "Otpsent") {
                                Navigator.pop(alert);

                                setState(() {
                                  otpRequested = true;
                                });
                              } else {
                                Navigator.pop(alert);
                                setState(() {
                                  incorrectDetails = true;
                                });
                              }
                            },
                          ),
                          SizedBox(height: size.height * 0.03),
                          AlreadyHaveAnAccountCheck(
                            login: false,
                            press: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return const LoginPage();
                                  },
                                ),
                              );
                            },
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BuildContext showAlertDialog(BuildContext context, String lodingText) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 5), child: Text(lodingText)),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return context;
  }

  Future<String> signup() async {
    if (signUpEmailController.text == "") {
      signUpError = "email cannot be empty";
      return Future.value("Error");
    } else if (signUpPasswordController.text == "" ||
        signUpPasswordController.text.length < 6 ||
        signUpPasswordController.text.length > 15) {
      signUpError = "password must be 6-15 characters";
      return Future.value("Error");
    } else if (loginType.toString() == "null") {
      signUpError = "select proper loginType";
      return Future.value("Error");
    }
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.post(
      url + '/signup',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'email': signUpEmailController.text,
        'password': signUpPasswordController.text,
        'login_type': loginType.toString()
      }),
    );

    if (response1.statusCode == 201) {
      return Future.value("Otpsent");
    }
    var res = response1.body;

    var obj = json.decode(res);
    if (obj['error'] ==
            "gomail: could not send email 1: gomail: invalid address \"sanket\": mail: missing '@' or angle-addr" ||
        obj['error'] == "mail: missing '@' or angle-addr") {
      signUpError = "email not correct";
    } else {
      signUpError = obj['error'];
    }

    return Future.value("Error");
  }

  Future<String> signupWithOtp(String otp) async {
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.post(
      url + '/signup',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'email': signUpEmailController.text,
        'password': signUpPasswordController.text,
        'login_type': loginType.toString(),
        'otp': otp
      }),
    );

    if (response1.statusCode == 200) {
      var res = response1.body;

      var obj = json.decode(res);

      token = (obj['token']);

      userName = obj['username'];
      userID = obj['id'].toString();
      return Future.value("verified");
    }
    var res = response1.body;

    var obj = json.decode(res);
    signUpErrorWithOTP = obj['error'];

    return Future.value("Error");
  }
}
