import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_svg/svg.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:study/components/already_have_an_account_acheck.dart';
import 'package:study/components/rounded_button.dart';
import 'package:study/components/rounded_input_field.dart';

import 'package:study/components/text_field_container.dart';
import 'package:study/pages/Faculty/faculty_home_page.dart';
import 'package:study/pages/Student/student_home_page.dart';

import '../constants/constants.dart';
import './signup_page.dart';
import '../controllers/token.dart';

// ignore: prefer_typing_uninitialized_variables
var dropdownValue;
String token = "";
var incorrectDetails = false;
var loginError = "";
var userName = "";
var userID = "";
bool _passwordVisible = false;

final emailcontroller = TextEditingController();
final passwordcontroller = TextEditingController();

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPage createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text("Study"),
        ),
        body: SizedBox(
          width: double.infinity,
          height: size.height,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                top: 0,
                left: 0,
                child: Image.asset(
                  "assets/images/main_top.png",
                  width: size.width * 0.35,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Image.asset(
                  "assets/images/login_bottom.png",
                  width: size.width * 0.4,
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      "LOGIN",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: size.height * 0.03),
                    SvgPicture.asset(
                      "assets/icons/login.svg",
                      height: size.height * 0.30,
                    ),
                    SizedBox(height: size.height * 0.03),
                    incorrectDetails
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Text(
                              loginError.toString(),
                              style: const TextStyle(
                                color: Colors.red,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          )
                        : const SizedBox.shrink(),
                    RoundedInputField(
                      hintText: "Your Email",
                      textController: emailcontroller,
                      onChanged: (value) {},
                    ),
                    TextFieldContainer(
                      child: TextFormField(
                        keyboardType: TextInputType.text,
                        controller: passwordcontroller,
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
                          value: dropdownValue,
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
                              dropdownValue = newValue;
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
                                            padding: const EdgeInsets.only(
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
                      text: "LOGIN",
                      press: () async {
                        var dialogContext =
                            showAlertDialog(context, "Logging IN");
                        if (await login() == "Error") {
                          Navigator.pop(dialogContext);
                          setState(() {
                            incorrectDetails = true;
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginPage()),
                                ModalRoute.withName("/Home"));
                          });
                        } else {
                          loginSucessfull();
                        }
                      },
                    ),
                    SizedBox(height: size.height * 0.03),
                    AlreadyHaveAnAccountCheck(
                      press: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const Signup();
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 90,
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

  Future<String> login() async {
    if (emailcontroller.text == "") {
      loginError = "email cannot be empty";
      return Future.value("Error");
    } else if (passwordcontroller.text == "" ||
        passwordcontroller.text.length < 6 ||
        passwordcontroller.text.length > 15) {
      loginError = "password must be 6-15 characters";
      return Future.value("Error");
    } else if (dropdownValue.toString() == "") {
      loginError = "select proper loginType";
      return Future.value("Error");
    }
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.post(
      url + '/login',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'email': emailcontroller.text,
        'password': passwordcontroller.text,
        'login_type': dropdownValue.toString()
      }),
    );

    if (response1.statusCode == 200) {
      var res = response1.body;

      var obj = json.decode(res);
      token = (obj['token']);
      userName = obj['username'];
      userID = obj['id'].toString();

      return Future.value("loggedIN");
    }
    var res = response1.body;

    var obj = json.decode(res);
    if (obj['error'] ==
        "crypto/bcrypt: hashedPassword is not the hash of the given password") {
      loginError = "Email or password incorrect";
    } else {
      loginError = obj['error'];
    }

    return Future.value("Error");
  }

  void loginSucessfull() {
    incorrectDetails = false;
    loginError = "";
    _passwordVisible = false;

    store('token', token, dropdownValue.toString(), userName, userID);
    emailcontroller.clear();
    passwordcontroller.clear();
    dropdownValue.toString() == 'faculty'
        ? Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => FacultyHomePage(userName)),
            ModalRoute.withName("/Home"))
        : Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => StudentHomePage(userName)),
            ModalRoute.withName("/Home"));
  }
}
