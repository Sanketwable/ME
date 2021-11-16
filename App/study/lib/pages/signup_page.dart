import 'dart:io';

import 'package:flutter/Material.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:http/io_client.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:study/pages/home_page.dart';
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
var userName = "";

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
                            Text(
                              "Enter OTP",
                              style: TextStyle(color: Colors.blue[400]),
                            ),
                            OTPTextField(
                              length: 6,
                              width: MediaQuery.of(context).size.width,
                              fieldWidth: 50,
                              style: TextStyle(fontSize: 17),
                              textFieldAlignment: MainAxisAlignment.spaceAround,
                              fieldStyle: FieldStyle.underline,
                              onCompleted: (pin) async {
                                showAlertDialog(context, "Signing Up");
                                if (await signupWithOtp(pin) == "verified") {
                                  print("otp verified");
                                  store('token', Token);
                                  loginType == "faculty"
                                      ? Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => FacultyInfo(userName, Token)),
                                          ModalRoute.withName("/FacultyInfo"))
                                      : Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  StudentInfo(userName, Token)),
                                          ModalRoute.withName("/StudentInfo"));
                                } else {
                                  setState(() {
                                    validOtp = false;
                                    Navigator.pop(context, Signup());
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
                              showAlertDialog(context, "Signing Up");
                              if (await signup() == "Otpsent") {
                                print("change window to enter otp");
                                setState(() {
                                  otpRequested = true;
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => Signup()),
                                      ModalRoute.withName("/Home"));
                                });
                              } else {
                                setState(() {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => Signup()),
                                      ModalRoute.withName("/Home"));
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

  showAlertDialog(BuildContext context, String lodingText) {
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
      return Future.value("verified");
    }
    print("\nworng password\n");
    return Future.value("Error");
  }
}
