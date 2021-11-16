import 'package:flutter/material.dart';
import 'package:study/pages/home_page.dart';
import 'package:study/pages/login_page.dart';
import '../controllers/token.dart';

class Redirect extends StatefulWidget {
  const Redirect({Key? key}) : super(key: key);

  @override
  _RedirectState createState() => _RedirectState();
}

class _RedirectState extends State<Redirect> {
  Future<String> finalAttemptoGetToken() async {
    var tkn = await getValue("token");
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
          return WelcomePage();
          // return HomePage();
        } else {
          print("token not present");
          print(snapshot);
          
          return WelcomePage();
        }
      },
    );
  }
}
