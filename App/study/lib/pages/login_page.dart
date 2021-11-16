import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import './home_page.dart';
import '../constants/constants.dart';
import './signup_page.dart';
import '../controllers/token.dart';

// ignore: prefer_typing_uninitialized_variables
var dropdownValue;
var Token;
var IncorrectDetails = false;

final emailcontroller = TextEditingController();
final passwordcontroller = TextEditingController();

class WelcomePage extends StatefulWidget {
  @override
  _WelcomePage createState() => _WelcomePage();
}

class _WelcomePage extends State<WelcomePage> {
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
                "Login",
                style: TextStyle(color: Colors.grey, fontSize: 32),
              )),
            ),
            IncorrectDetails
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "*Incorrect Details",
                      style: TextStyle(
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  )
                : const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      "Enter your details below to login",
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.left,
                    ),
                  ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: emailcontroller,
                obscureText: false,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Enter valid Email'),
              ),
            ),
            Padding(
              padding:
                  EdgeInsets.only(left: 15.0, right: 15.0, top: 15, bottom: 0),
              child: TextField(
                controller: passwordcontroller,
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
                    border: const BorderSide(color: Colors.black12, width: 1),
                    dropdownButtonColor: Colors.grey[300],
                    value: dropdownValue,
                    hint: Text("Select Login Type"),
                    onChanged: (newValue) {
                      setState(() {
                        dropdownValue = newValue;
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
            TextButton(
              onPressed: () {},
              child: const Text(
                'Forgot Password',
                style: TextStyle(color: Colors.blue, fontSize: 15),
              ),
            ),
            Container(
              height: 50,
              width: 250,
              decoration: BoxDecoration(
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () async {
                  showAlertDialog(context, "Logging IN");
                  if (await login() == "Error") {
                    print("now has to stopped");
                    setState(() {
                      IncorrectDetails = true;
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => WelcomePage()),
                          ModalRoute.withName("/Home"));
                    });
                  } else {
                    loginSucessfull();
                  }
                },
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
            const SizedBox(
              height: 90,
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => Signup()));
              },
              child: Text("New User? Create account"),
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

  Future<String> login() async {
    print(emailcontroller.text);
    print(passwordcontroller.text);
    print(dropdownValue.toString());
    final ioc = new HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = new IOClient(ioc);
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
      print(res);
      var obj = json.decode(res);
      var Error = obj['error'];
      Token = (obj['token']);
      print("this is the token ---" + Token);
      print(Error);
      return Future.value("loggedIN");
    }
    print("\nworng password\n");
    return Future.value("Error");
  }

  void loginSucessfull() {
    store('token', Token);
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
        ModalRoute.withName("/Home"));
  }
}
