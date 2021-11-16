import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:study/constants/constants.dart';
import 'package:study/pages/faculty_home_page.dart';

final firstNameController = TextEditingController();
final lastNameController = TextEditingController();
final phoneNoController = TextEditingController();
final degreeController = TextEditingController();
final passoutYeatController = TextEditingController();
var experience;

var userName = "";
var Token = "";

class FacultyInfo extends StatefulWidget {
  FacultyInfo(String username, String token, {Key? key}) : super(key: key) {
    userName = username;
    Token = token;
  }

  @override
  _FacultyInfoState createState() => _FacultyInfoState();
}

class _FacultyInfoState extends State<FacultyInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Faculty"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
                child: Text(
                  "congrats " + userName + " your accout is created ",
                  style: TextStyle(color: Colors.blue, fontSize: 10),
                )),
            Padding(
              padding: EdgeInsets.only(top: 40.0, bottom: 40.0),
              child: Center(
                  child: Text(
                "    Hi " + userName + "\nEnter your basic Info ",
                style: TextStyle(color: Colors.grey, fontSize: 20),
              )),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: TextField(
                controller: firstNameController,
                obscureText: false,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'First Name',
                    hintText: 'Enter your First Name'),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: TextField(
                controller: lastNameController,
                obscureText: false,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Last Name',
                    hintText: 'Enter your Last Name'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: TextField(
                controller: phoneNoController,
                obscureText: false,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Phone No',
                    hintText: 'Enter your Phone'),
              ),
            ),
            const Padding(
              padding:
                  EdgeInsets.only(left: 15.0, right: 15.0, top: 5, bottom: 0),
              child: Center(
                  child: Text(
                "Qualification",
                style: TextStyle(fontSize: 24),
              )),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: TextField(
                controller: degreeController,
                obscureText: false,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Degree',
                    hintText: 'Eg. B.Tech, Phd'),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: TextField(
                controller: passoutYeatController,
                obscureText: false,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Passout year',
                    hintText: 'Eg. 2022'),
              ),
            ),
            const Padding(
              padding:
                  EdgeInsets.only(left: 15.0, right: 15.0, top: 5, bottom: 0),
              child: Center(
                  child: Text(
                "Experience",
                style: TextStyle(fontSize: 24),
              )),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, right: 15.0, top: 5, bottom: 0),
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
                    value: experience,
                    hint: Text("Experience"),
                    onChanged: (newValue) {
                      setState(() {
                        experience = newValue;
                      });
                    },
                    items: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10']
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
                  color: Colors.blue, borderRadius: BorderRadius.circular(20)),
              child: TextButton(
                onPressed: () async {
                  showAlertDialog(context, "Submitting");
                  if (await submitBasicInfo() == "Submitted") {
                    print("now has to stopped");
                    setState(() {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => FacultyHomePage(userName)),
                          ModalRoute.withName("/Home"));
                    });
                  } else {
                    print("error occured");
                    setState(() {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => FacultyInfo(userName, Token)),
                          ModalRoute.withName("/Home"));
                    });
                  }
                },
                child: const Text(
                  'Submit',
                  style: TextStyle(color: Colors.white, fontSize: 25),
                ),
              ),
            ),
            const SizedBox(
              height: 90,
            ),
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

  Future<String> submitBasicInfo() async {
    print(firstNameController.text);
    print(lastNameController.text);
    print(phoneNoController.text);
    print(degreeController.text);
    print(passoutYeatController.text);
    print((experience.toString()));
    final ioc = new HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = new IOClient(ioc);
    final http.Response response1 = await http1.post(
      url + '/facultyinfo',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + Token,
      },
      body: jsonEncode(<String, dynamic>{
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'phone_no': phoneNoController.text,
        'qualification': {
          'degree': degreeController.text,
          'passout_year': passoutYeatController.text,
        },
        'experience': double.parse(experience.toString()),
      }),
    );

    if (response1.statusCode == 201) {
      var res = response1.body;
      print(res);
      var obj = json.decode(res);
      return Future.value("Submitted");
    }
    print("\nworng password\n");
    return Future.value("Error");
  }
}
