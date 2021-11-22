import 'package:flutter/material.dart';
import 'package:study/pages/faculty_home_page.dart';
import 'package:study/pages/student_home_page.dart';
import 'package:study/pages/login_page.dart';
import 'package:study/pages/student_home_page.dart';
import 'package:study/pages/student_info.dart';
import '../controllers/token.dart';

var LoginType = "";
var UserName = "";

class Redirect extends StatefulWidget {
  const Redirect({Key? key}) : super(key: key);

  @override
  _RedirectState createState() => _RedirectState();
}

class _RedirectState extends State<Redirect> {
  Future<String> finalAttemptoGetToken() async {
    var tkn = await getValue("token");
    LoginType = await getLoginType();
    UserName = await getUserName();
    return tkn;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: finalAttemptoGetToken(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        print("printing snapshot");
        print(snapshot);
        if (snapshot.hasData) {
          print("token is ");
          print(snapshot);
          // return WelcomePage();
          return LoginType == "faculty" ? FacultyHomePage(UserName) :StudentHomePage(UserName);
          // return StudentInfo("sanket", snapshot.toString());
        } else {
          print("token not present");
          print(snapshot);
          return WelcomePage();
        }
      },
    );
  }
}
