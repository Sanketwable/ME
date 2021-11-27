import 'dart:io';

import 'package:flutter/material.dart';
import 'package:study/pages/faculty_home_page.dart';
import 'package:study/pages/student_home_page.dart';

import 'package:study/pages/welcome_page.dart';
import '../controllers/token.dart';
import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_svg/svg.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;

import './faculty_home_page.dart';
import './student_home_page.dart';
import '../constants/constants.dart';
import './signup_page.dart';

var loginType = "";
var userName = "";

class Redirect extends StatefulWidget {
  const Redirect({Key? key}) : super(key: key);

  @override
  _RedirectState createState() => _RedirectState();
}

class _RedirectState extends State<Redirect> {

  Future<String> finalAttemptoGetToken() async {
    var tkn = await getValue("token");

    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.get(
      url + '/verifyuser',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
    );
    
    if (response1.statusCode == 200) {
      loginType = await getLoginType();
      userName = await getUserName();
      return tkn;
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: FutureBuilder(
        future: finalAttemptoGetToken(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            // return WelcomePage();
            return loginType == "faculty"
                ? FacultyHomePage(userName)
                : StudentHomePage(userName);
            // return StudentInfo("sanket", snapshot.toString());
          } else {
            return const WelcomePage();
          }
        },
      ),
    );
  }
}
