import 'package:flutter/material.dart';
import 'package:study/controllers/token.dart';
import 'package:study/pages/redirect_page.dart';

var studentUserName = "";

class StudentHomePage extends StatefulWidget {
  StudentHomePage(String username) {
    studentUserName = username;
  }
  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(studentUserName),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Container(
                  height: 200,
                  width: MediaQuery.of(context).size.width*0.95,
                  decoration: BoxDecoration(
                      color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Welcome' + studentUserName,
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
