import 'dart:io';

import 'package:flutter/Material.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'package:study/pages/student_info.dart';
import 'package:study/pages/faculty_info.dart';
import '../constants/constants.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import '../controllers/token.dart';

final signUpEmailController = TextEditingController();
final signUpPasswordController = TextEditingController();
var token = "";
// ignore: prefer_typing_uninitialized_variables

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final signUpEmailController = TextEditingController();
  final signUpPasswordController = TextEditingController();
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Study"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(top: 60.0, bottom: 80.0),
              child: Center(
                  child: Text(
                "Signup",
                style: TextStyle(color: Colors.grey, fontSize: 32),
              )),
            ),
            otpRequested
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        height: 330,
                        child: Column(
                          children: [
                            incorrectOTP
                                ? Text(
                                    signUpErrorWithOTP.toString(),
                                    style: const TextStyle(color: Colors.red),
                                  )
                                : const Text(
                                    "Enter OTP",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                            OTPTextField(
                              length: 6,
                              width: MediaQuery.of(context).size.width,
                              fieldWidth: 25,
                              style: const TextStyle(fontSize: 18),
                              textFieldAlignment: MainAxisAlignment.spaceAround,
                              fieldStyle: FieldStyle.underline,
                              onCompleted: (pin) async {
                                var dialogContext =
                                    showAlertDialog(context, "Signing Up");
                                if (await signupWithOtp(pin) == "verified") {
                                  Navigator.pop(dialogContext);

                                  store('token', token, loginType.toString(),
                                      userName, userID);
                                  loginType == "faculty"
                                      ? Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  FacultyInfo(userName, token)),
                                          ModalRoute.withName("/FacultyInfo"))
                                      : Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  StudentInfo(userName, token)),
                                          ModalRoute.withName("/StudentInfo"));
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
                    children: <Widget>[
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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: TextField(
                          controller: signUpEmailController,
                          obscureText: false,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Email',
                              hintText: 'Enter valid Email'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 15, bottom: 0),
                        child: TextField(
                          controller: signUpPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Password',
                              hintText: 'Enter secure password'),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 15, bottom: 0),
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.all(20),
                          child: DropdownButtonHideUnderline(
                            child: GFDropdown(
                              padding: const EdgeInsets.all(15),
                              borderRadius: BorderRadius.circular(10),
                              border: const BorderSide(
                                  color: Colors.black12, width: 1),
                              dropdownButtonColor: Colors.grey[300],
                              value: loginType,
                              hint: const Text("Select Login Type"),
                              onChanged: (newValue) {
                                setState(() {
                                  loginType = newValue;
                                });
                              },
                              items: ['faculty', 'student']
                                  .map((value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 250,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20)),
                        child: TextButton(
                          onPressed: () async {
                            var alert = showAlertDialog(context, "Signing Up");
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
                          child: const Text(
                            'SignUp',
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 130,
                      ),
                    ],
                  )
          ],
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
    signUpError = obj['error'];

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
