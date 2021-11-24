import 'package:flutter/material.dart';
import 'package:study/pages/faculty_home_page.dart';
import 'package:study/pages/student_home_page.dart';
import 'package:study/pages/login_page.dart';
import '../controllers/token.dart';

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
    loginType = await getLoginType();
    userName = await getUserName();
    return tkn;
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
