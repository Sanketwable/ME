import 'package:flutter/material.dart';
import 'package:study/controllers/token.dart';
import 'package:study/pages/redirect_page.dart';

var facultyUsername = "";

class FacultyHomePage extends StatefulWidget {
  FacultyHomePage(String username) {
    facultyUsername = username;
  }
  @override
  _FacultyHomePageState createState() => _FacultyHomePageState();
}

class _FacultyHomePageState extends State<FacultyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Faculty'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(facultyUsername),
            ),
            ListTile(
              title: const Text('Sign Out'),
              onTap: () {
                delete();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const Redirect()),
                    ModalRoute.withName("/Home"));
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Container(
          height: 400,
          width: 300,
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(10)),
          child: TextButton(
            onPressed: () {},
            child: Text(
              'Welcome' + facultyUsername,
              style: TextStyle(color: Colors.white, fontSize: 25),
            ),
          ),
        ),
      ),
    );
  }
}
