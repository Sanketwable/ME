import 'dart:io';

import 'package:flutter/Material.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:http/io_client.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:study/pages/student_info.dart';
import 'package:study/pages/teacher_info.dart';
import '../constants/constants.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import '../controllers/token.dart';

final signUpEmailController = TextEditingController();
final signUpPasswordController = TextEditingController();
var Token = "";
var loginType;
var otpRequested = false;
var validOtp = true;
var incorrectOTP = false;
var userName = "";
var userID = "";
var signUpError;
var signUpErrorWithOTP;
var IncorrectDetails = false;

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {
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
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: EdgeInsets.all(10),
                        height: 330,
                        child: Column(
                          children: [
                            incorrectOTP
                                ? Text(
                                    signUpErrorWithOTP.toString(),
                                    style: TextStyle(color: Colors.red),
                                  )
                                : const Text(
                                    "Enter OTP",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                            OTPTextField(
                              length: 6,
                              width: MediaQuery.of(context).size.width,
                              fieldWidth: 25,
                              style: TextStyle(fontSize: 18),
                              textFieldAlignment: MainAxisAlignment.spaceAround,
                              fieldStyle: FieldStyle.underline,
                              onCompleted: (pin) async {
                                var dialogContext =
                                    showAlertDialog(context, "Signing Up");
                                if (await signupWithOtp(pin) == "verified") {
                                  Navigator.pop(dialogContext);
                                  print("otp verified");
                                  store('token', Token, loginType.toString(),
                                      userName, userID);
                                  loginType == "faculty"
                                      ? Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  FacultyInfo(userName, Token)),
                                          ModalRoute.withName("/FacultyInfo"))
                                      : Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  StudentInfo(userName, Token)),
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
                : Container(
                    child: Column(
                      children: <Widget>[
                        IncorrectDetails
                            ? Padding(
                                padding: EdgeInsets.symmetric(
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
                          padding: EdgeInsets.symmetric(horizontal: 15),
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
                          padding: EdgeInsets.only(
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
                            margin: EdgeInsets.all(20),
                            child: DropdownButtonHideUnderline(
                              child: GFDropdown(
                                padding: const EdgeInsets.all(15),
                                borderRadius: BorderRadius.circular(10),
                                border: const BorderSide(
                                    color: Colors.black12, width: 1),
                                dropdownButtonColor: Colors.grey[300],
                                value: loginType,
                                hint: Text("Select Login Type"),
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
                              var alert =
                                  showAlertDialog(context, "Signing Up");
                              if (await signup() == "Otpsent") {
                                Navigator.pop(alert);
                                print("change window to enter otp");
                                setState(() {
                                  otpRequested = true;
                                });
                              } else {
                                Navigator.pop(alert);
                                setState(() {
                                  IncorrectDetails = true;
                                });
                              }
                            },
                            child: const Text(
                              'SignUp',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 130,
                        ),
                      ],
                    ),
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
          CircularProgressIndicator(),
          Container(margin: EdgeInsets.only(left: 5), child: Text(lodingText)),
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
    print(signUpEmailController.text);
    print(signUpPasswordController.text);
    print(loginType.toString());
    final ioc = new HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = new IOClient(ioc);
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
      print("\notp send\n");
      var res = response1.body;
      print(res);
      var obj = json.decode(res);
      var Error = obj['message'];
      var Expires = obj['expires_at'];

      print(Error);
      print(Expires);
      return Future.value("Otpsent");
    }
    var res = response1.body;
    print(res);
    var obj = json.decode(res);
    signUpError = obj['error'];
    print("\nworng password\n");
    print("\notp not send\n");
    return Future.value("Error");
  }

  Future<String> signupWithOtp(String otp) async {
    print(signUpEmailController.text);
    print(signUpPasswordController.text);
    print(loginType.toString());
    print(otp);
    final ioc = new HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = new IOClient(ioc);
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
      print(res);
      var obj = json.decode(res);
      var Error = obj['error'];
      Token = (obj['token']);
      print("this is the token ---" + Token);
      print(Error);
      userName = obj['username'];
      userID = obj['id'].toString();
      return Future.value("verified");
    }
    var res = response1.body;
    print(res);
    var obj = json.decode(res);
    signUpErrorWithOTP = obj['error'];
    print("\nworng password\n");

    return Future.value("Error");
  }
}
