import 'dart:developer';

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

var classData;

class FacultyClass extends StatefulWidget {
  FacultyClass(data) {
    classData = data;
  }

  @override
  _FacultyClassState createState() => _FacultyClassState();
}

class _FacultyClassState extends State<FacultyClass> {
  int _selectedPage = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Timeline',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_sharp),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Students',
          ),
        ],
        currentIndex: _selectedPage,
        selectedItemColor: Colors.blue[800],
        onTap: (index) {
          _onItemTapped(index);
        },
      ),
      appBar: AppBar(
        title: Text('Faculty'),
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.all(20),
        child: FittedBox(
          child: FloatingActionButton(
            onPressed: () {
              var dialogContext = addStudentEmail(context);
            },
            child: Icon(Icons.add),
            tooltip: "Add Student to Class",
            isExtended: true,
            autofocus: true,
          ),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: FutureBuilder(
                builder: (context, AsyncSnapshot snapshot) {
                  return Text(snapshot.data.toString());
                },
                future: getUserName(),
              ),
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
      body: _selectedPage == 0
          ? timeLinePage()
          : (_selectedPage == 1 ? AssignmentPage() : StudentsPage()),
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

  var emailSubmitted = false;
  var emailError = "";
  var studentEmailController = TextEditingController();

  BuildContext addStudentEmail(BuildContext context) {
    AlertDialog alert = AlertDialog(
      elevation: 5.0,
      content: SizedBox(
        height: MediaQuery.of(context).size.width * 0.40,
        width: MediaQuery.of(context).size.width * 0.80,
        child: emailSubmitted
            ? Center(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: MediaQuery.of(context).size.width * 0.1,
                    child: CircularProgressIndicator()))
            : Column(
                children: [
                  emailError == ""
                      ? Text("")
                      : Text(
                          emailError,
                          style: TextStyle(color: Colors.red),
                        ),
                  SizedBox(
                    child: TextField(
                      controller: studentEmailController,
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Email',
                          hintText: 'Enter student mailID'),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: TextButton(
                          onPressed: () async {
                            emailSubmitted = true;
                            var ctx = addStudentEmail(context);
                            var response = await addStudentEmailRequest();
                            if (response == "error") {
                              emailSubmitted = false;
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                              print("failed to add student");
                              addStudentEmail(context);
                              emailError = "";
                            } else {
                              setState(() {
                                emailSubmitted = false;
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

  Widget timeLinePage() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              // border: Border.all(
              //     color: Colors.white, width: 0.5, style: BorderStyle.solid),
              boxShadow: const [
                BoxShadow(
                  color: Colors.blueGrey,
                  offset: Offset(
                    5.0,
                    5.0,
                  ),
                  blurRadius: 10.0,
                  spreadRadius: 2.0,
                ), //BoxShadow
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      classData["branch"] + " ",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    Text(
                      classData["year"].toString(),
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    Spacer(),
                    Container(
                      child: CircleAvatar(
                          radius: 35,
                          backgroundImage:
                              NetworkImage(classData["image_link"])),
                    ),
                  ],
                ),
                Text(
                  "Class code : " + classData["class_code"],
                  style: TextStyle(color: Colors.blueAccent, fontSize: 12),
                ),
                Text(
                  classData["link"] + "\n",
                  style: TextStyle(color: Colors.blue, fontSize: 11),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 15, bottom: 10),
                  child: Text(
                    classData["subject"].toString().toUpperCase(),
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Expanded(
        //   flex: 9,
        //   child: FutureBuilder(
        //     builder: (context, AsyncSnapshot<List> snapshot) {
        //       if (snapshot.connectionState == ConnectionState.waiting) {
        //         return Padding(
        //           padding: EdgeInsets.symmetric(
        //               vertical: MediaQuery.of(context).size.width * 0.40),
        //           child:
        //               const Center(child: Text('Please wait its loading...')),
        //         );
        //       } else {
        //         if (snapshot.hasError) {
        //           return Center(child: Text('Error: ${snapshot.error}'));
        //         } else {
        //           print(snapshot);
        //           return snapshot.data!.isEmpty
        //               ? Padding(
        //                   padding: EdgeInsets.symmetric(
        //                       vertical:
        //                           MediaQuery.of(context).size.width * 0.40),
        //                   child: const Center(
        //                       child: Text(
        //                           'You are not enrolled to any classes')),
        //                 )
        //               : ListView.builder(
        //                   scrollDirection: Axis.vertical,
        //                   shrinkWrap: true,
        //                   itemCount: snapshot.data!.length,
        //                   itemBuilder: (context, index) {
        //                     var datas = snapshot.data![index];
        //                     return Padding(
        //                       padding: const EdgeInsets.only(top: 10),
        //                       child: Center(
        //                         child: Container(
        //                           // height: 100,
        //                           width: MediaQuery.of(context).size.width *
        //                               0.95,
        //                           decoration: BoxDecoration(
        //                               color: Colors.grey,
        //                               borderRadius:
        //                                   BorderRadius.circular(10)),
        //                           child: TextButton(
        //                             onPressed: () {},
        //                             child: Container(
        //                               child: Column(
        //                                 children: [
        //                                   Padding(
        //                                     padding:
        //                                         const EdgeInsets.all(2.0),
        //                                     child: Text(
        //                                       datas["subject"]
        //                                           .toString()
        //                                           .toUpperCase(),
        //                                       style: TextStyle(
        //                                           color: Colors.white,
        //                                           fontSize: 20),
        //                                     ),
        //                                   ),
        //                                   Row(
        //                                     children: [
        //                                       Text(
        //                                         datas["branch"],
        //                                         style: TextStyle(
        //                                             color: Colors.white,
        //                                             fontSize: 18),
        //                                       ),
        //                                       Text(
        //                                         datas["year"].toString(),
        //                                         style: TextStyle(
        //                                             color: Colors.white,
        //                                             fontSize: 18),
        //                                       ),
        //                                       Spacer(),
        //                                       Container(
        //                                         child: CircleAvatar(
        //                                             radius: 35,
        //                                             backgroundImage:
        //                                                 NetworkImage(datas[
        //                                                     "image_link"])),
        //                                       ),
        //                                     ],
        //                                   ),
        //                                   Text(
        //                                     "Class code : " +
        //                                         datas["class_code"],
        //                                     style: TextStyle(
        //                                         color: Colors.white,
        //                                         fontSize: 12),
        //                                   ),
        //                                   Text(
        //                                     datas["link"] + "\n",
        //                                     style: TextStyle(
        //                                         color: Colors.white,
        //                                         fontSize: 11),
        //                                   ),
        //                                   // Text(
        //                                   //   "sanket\n\n\n",
        //                                   //   style: TextStyle(
        //                                   //       color: Colors.white,
        //                                   //       fontSize: 11),
        //                                   // ),
        //                                 ],
        //                               ),
        //                             ),
        //                           ),
        //                         ),
        //                       ),
        //                     );
        //                   },
        //                 );
        //         }
        //       }
        //     },
        //     future: getClasses(),
        //   ),
        // ),
      ],
    );
  }

  Widget AssignmentPage() {
    return Center(
        child: Container(
      child: Text("Assignemnt"),
      padding: EdgeInsets.all(8),
    ));
  }

  Widget StudentsPage() {
    return Center(
        child: Container(
      child: Text("Students"),
      padding: EdgeInsets.all(8),
    ));
  }

  Future<String> addStudentEmailRequest() async {
    var token = await getValue("token");
    print(studentEmailController.text);
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.get(
      url +
          '/addstudent?email=' +
          studentEmailController.text +
          "&class_id=" +
          classData["class_id"].toString(),
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
    emailError = obj['error'];
    return Future.value("error");
  }
}
