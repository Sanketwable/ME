import 'package:flutter/material.dart';
import 'package:study/controllers/token.dart';
import 'package:study/pages/redirect_page.dart';
import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'package:study/pages/student_class.dart';
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Colleagues',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_sharp),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Me',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.blue[800],
        onTap: (index) {},
      ), // This trailing comma makes auto-formatting nicer for build methods.
      floatingActionButton: Container(
        padding: EdgeInsets.all(20),
        // height: 100,
        // width: 100,
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              var dialogContext = addClassCode(context);
            },
            child: Icon(Icons.add),
            isExtended: true,
            autofocus: true,
          ),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
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
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              "Classes",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 9,
            child: FutureBuilder(
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
                    return snapshot.data!.isEmpty
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.width * 0.40),
                            child: const Center(
                                child: Text(
                                    'You are not enrolled to any classes')),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              var datas = snapshot.data![index];
                              return Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Center(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.95,
                                    decoration: BoxDecoration(
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(
                                              5.0,
                                              5.0,
                                            ),
                                            blurRadius: 10.0,
                                            spreadRadius: 2.0,
                                          ), //BoxShadow
                                        ],
                                        border: Border.all(
                                            color: Colors.black,
                                            width: 0.5,
                                            style: BorderStyle.none),
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    StudentClass(datas)));
                                      },
                                      child: Container(
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Text(
                                                datas["subject"]
                                                    .toString()
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 20),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  datas["branch"],
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18),
                                                ),
                                                Text(
                                                  " " +
                                                      datas["year"].toString(),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18),
                                                ),
                                                Spacer(),
                                                Container(
                                                  child: CircleAvatar(
                                                      radius: 35,
                                                      backgroundImage:
                                                          NetworkImage(datas[
                                                              "image_link"])),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "Class code : " +
                                                  datas["class_code"],
                                              style: TextStyle(
                                                  color: Colors.blueAccent,
                                                  fontSize: 12),
                                            ),
                                            Text(
                                              datas["link"] + "\n",
                                              style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 11),
                                            ),
                                            // Text(
                                            //   "sanket\n\n\n",
                                            //   style: TextStyle(
                                            //       color: Colors.white,
                                            //       fontSize: 11),
                                            // ),
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
          ),
        ],
      ),
    );
  }

  var codeSubmitted = false;
  var codeError = "";

  BuildContext addClassCode(BuildContext context) {
    AlertDialog alert = AlertDialog(
      elevation: 5.0,
      content: SizedBox(
        height: MediaQuery.of(context).size.width * 0.40,
        width: MediaQuery.of(context).size.width * 0.80,
        child: codeSubmitted
            ? Center(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: MediaQuery.of(context).size.width * 0.1,
                    child: CircularProgressIndicator()))
            : Column(
                children: [
                  codeError == ""
                      ? Text("")
                      : Text(
                          codeError,
                          style: TextStyle(color: Colors.red),
                        ),
                  SizedBox(
                    child: TextField(
                      controller: classCodeController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Code',
                          hintText: 'Enter class code'),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: TextButton(
                          onPressed: () async {
                            codeSubmitted = true;
                            var ctx = addClassCode(context);
                            var response = await addClassRequest();
                            if (response == "error") {
                              codeSubmitted = false;
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                              print("failed to add class");
                              addClassCode(context);
                              codeError = "";
                            } else {
                              setState(() {
                                codeSubmitted = false;
                              });
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                              print("class added sucessfully");
                            }
                          },
                          child: const Text(
                            'Submit',
                            style: TextStyle(color: Colors.blue, fontSize: 18),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Close',
                            style: TextStyle(color: Colors.blue, fontSize: 18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return context;
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

  Future<String> addClassRequest() async {
    var token = await getValue("token");
    print(classCodeController.text);
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.get(
      url + '/addclass?code=' + classCodeController.text,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
    );
    var res = response1.body;
    var obj = json.decode(res);
    print(obj);
    if (response1.statusCode == 200) {
      return obj.toString();
    }
    codeError = obj['error'];
    return Future.value("error");
  }
}

var classCodeController = TextEditingController();
