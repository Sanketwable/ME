import 'package:flutter/material.dart';
import 'package:study/controllers/token.dart';
import 'package:study/pages/redirect_page.dart';
import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import '../constants/constants.dart';
import './signup_page.dart';
import '../controllers/token.dart';

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
              padding: EdgeInsets.only(top: 10),
              child: Text(
                "Classes",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            FutureBuilder(
              builder: (context, AsyncSnapshot<List> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: MediaQuery.of(context).size.width * 0.40),
                    child:
                        const Center(child: Text('Please wait its loading...')),
                  );
                } else {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    print(snapshot);
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        var datas = snapshot.data![index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Center(
                            child: Container(
                              // height: 100,
                              width: MediaQuery.of(context).size.width * 0.95,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(10)),
                              child: TextButton(
                                onPressed: () {},
                                child: Container(
                                  child: Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          datas["subject"]
                                              .toString()
                                              .toUpperCase(),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            datas["branch"],
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                          Text(
                                            datas["year"].toString(),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                          Spacer(),
                                          Container(
                                            child: const CircleAvatar(
                                                radius: 25,
                                                backgroundImage: NetworkImage(
                                                    'https://picsum.photos/250?image=9')),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        datas["class_code"],
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                      Text(
                                        datas["link"],
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                }
              },
              future: getClasses(),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<dynamic>> getClasses() async {
    var token = await getValue("token");
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.get(
      url + '/getclasses',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
    );
    var res = response1.body;
    var obj = json.decode(res);
    if (response1.statusCode == 200) {
      return obj;
    }
    return Future.value(obj["error"]);
  }
}
