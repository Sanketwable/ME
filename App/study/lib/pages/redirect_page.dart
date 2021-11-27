import 'dart:io';

import 'package:flutter/material.dart';
import 'package:study/pages/faculty_home_page.dart';
import 'package:study/pages/student_home_page.dart';

import 'package:study/pages/welcome_page.dart';
import '../controllers/token.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_svg/svg.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;

import './faculty_home_page.dart';
import './student_home_page.dart';
import '../constants/constants.dart';

var loginType = "";
var userName = "";

class Redirect extends StatefulWidget {
  const Redirect({Key? key}) : super(key: key);

  @override
  _RedirectState createState() => _RedirectState();
}

class _RedirectState extends State<Redirect> {
  Future finalAttemptoGetToken() async {
    var tkn = await getValue("token");

    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.get(
      url + '/verifyuser',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + tkn,
      },
    );

    if (response1.statusCode == 200) {
      loginType = await getLoginType();
      userName = await getUserName();
      return tkn;
    }

    Future;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: FutureBuilder(
        future: finalAttemptoGetToken(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MainPage();
          } else if (snapshot.hasData) {
            return loginType == "faculty"
                ? FacultyHomePage(userName)
                : StudentHomePage(userName);
          } else {
            // return MainPage();
            return const WelcomePage();
          }
        },
      ),
    );
  }

  Widget MainPage() {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: size.height * 0.30,
                  left: size.width * 0.1,
                  right: size.width * 0.1),
              child: Center(
                child: SvgPicture.asset(
                  "assets/icons/teacher.svg",
                  height: size.height * 0.30,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: size.height * 0.2),
              child: Center(
                child: Text(
                  "Study",
                  style: TextStyle(
                      color: Colors.grey, fontSize: size.width * 0.15),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
