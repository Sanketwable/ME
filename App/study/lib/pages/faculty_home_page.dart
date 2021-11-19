import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/constants/constants.dart';
import 'package:study/controllers/token.dart';
import 'package:study/pages/faculty_class.dart';
import 'package:study/pages/redirect_page.dart';
import 'package:getwidget/getwidget.dart';
import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';

import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;

var facultyUsername = "";

class FacultyHomePage extends StatefulWidget {
  FacultyHomePage(String username) {
    facultyUsername = username;
  }
  @override
  _FacultyHomePageState createState() => _FacultyHomePageState();
}

class _FacultyHomePageState extends State<FacultyHomePage> {
  int _selectedPage = 0;
  void _onItemTapped(int index) {
    if (_selectedPage != index) {
      print("page changed");
      setState(() {
        _selectedPage = index;
      });
    }
  }

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
            icon: Icon(Icons.message_sharp),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_box),
            label: 'Me',
          ),
        ],
        currentIndex: _selectedPage,
        selectedItemColor: Colors.blue[800],
        onTap: (index) {
          _onItemTapped(index);
        },
      ),
      floatingActionButton: _selectedPage != 0
          ? SizedBox.shrink()
          : Container(
              padding: EdgeInsets.all(20),
              child: FittedBox(
                child: FloatingActionButton(
                  onPressed: () {
                    var dialogContext = addClass(context);
                  },
                  child: Icon(Icons.add),
                  isExtended: true,
                  autofocus: true,
                ),
              ),
            ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
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
      body: _selectedPage == 0
          ? classesPage()
          : (_selectedPage == 1 ? messagesPage() : mePage()),
    );
  }

  Widget classesPage() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            "Classes",
            style: TextStyle(
                color: Colors.grey, fontSize: 20, fontWeight: FontWeight.bold),
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
                              child:
                                  Text('You are not enrolled to any classes')),
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
                                  width:
                                      MediaQuery.of(context).size.width * 0.95,
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
                                      borderRadius: BorderRadius.circular(10)),
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  FacultyClass(datas)));
                                    },
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
                                                " " + datas["year"].toString(),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                              ),
                                              Spacer(),
                                              Container(
                                                child: CircleAvatar(
                                                    radius: 35,
                                                    onBackgroundImageError:
                                                        (Object, StackTrace) =>
                                                            {},
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

  var detailsSubmitted = false;
  var classDetailsError = "";
  var branchController = TextEditingController();
  var subjectController = TextEditingController();
  var classLinkController = TextEditingController();
  var imageLinkController = TextEditingController();
  var yearController = TextEditingController();

  BuildContext addClass(BuildContext context) {
    AlertDialog alert = AlertDialog(
      elevation: 2.0,
      content: detailsSubmitted
          ? SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.width * 0.2,
              child: const Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    classDetailsError == ""
                        ? Text("")
                        : Text(
                            classDetailsError,
                            style: TextStyle(color: Colors.red),
                          ),
                    const Padding(
                        padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
                        child: Text(
                          "Enter class details",
                          style: TextStyle(color: Colors.blue, fontSize: 10),
                        )),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      child: TextField(
                        controller: branchController,
                        obscureText: false,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Branch',
                            hintText: 'Eg. CSE, ECE...'),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      child: TextField(
                        controller: subjectController,
                        obscureText: false,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Subject',
                            hintText: 'Eg. Computer Networks, DBMS'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: TextField(
                        controller: classLinkController,
                        obscureText: false,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Class Link',
                            hintText: 'Eg. meet.google.com/ffs24f2'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: TextField(
                        controller: imageLinkController,
                        obscureText: false,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Image Link',
                            hintText: 'https://wwww.image.com/ece.png'),
                      ),
                    ),
                    // TextFormField(
                    //   controller: yearController,
                    //   keyboardType: TextInputType.number,
                    //   inputFormatters: [
                    //     FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    //   ],
                    //   decoration: InputDecoration(
                    //       labelText: "Year", hintText: '1,2,3,4'),
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: TextFormField(
                        controller: yearController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                        ],
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Year',
                            hintText: '1,2,3,4'),
                      ),
                    ),
                    Container(
                      height: 50,
                      width: 250,
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20)),
                      child: TextButton(
                        onPressed: () async {
                          detailsSubmitted = true;
                          var ctx = addClass(context);
                          var response = await addClassRequest();
                          if (response == "error") {
                            detailsSubmitted = false;
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                            print("failed to add class");
                            addClass(context);
                            classDetailsError = "";
                          } else {
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                            setState(() {
                              print("setstate classed");
                              detailsSubmitted = false;
                              imageLinkController.clear();
                              branchController.clear();
                              classLinkController.clear();
                              subjectController.clear();
                              yearController.clear();
                            });
                            print("class added sucessfully");
                          }
                        },
                        child: const Text(
                          'Submit',
                          style: TextStyle(color: Colors.white, fontSize: 25),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 90,
                    ),
                  ],
                ),
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

  Widget messagesPage() {
    return Center(
        child: Container(
      child: Text("Messages"),
      padding: EdgeInsets.all(8),
    ));
  }

  Widget mePage() {
    return Center(
        child: Container(
      child: Text("Me"),
      padding: EdgeInsets.all(8),
    ));
  }

  Future<String> addClassRequest() async {
    var token = await getValue("token");
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.post(
      url + '/createclass',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
      body: jsonEncode(<String, dynamic>{
        'link': classLinkController.text,
        'year': int.parse(yearController.text),
        'branch': branchController.text,
        'subject': subjectController.text,
        'image_link': imageLinkController.text,
      }),
    );
    print(response1.statusCode);
    var res = response1.body;
    // print(res);

    if (response1.statusCode == 200) {
      var obj = json.decode(res);
      print(obj);
      return obj.toString();
    }
    // classDetailsError = obj['error'];
    return Future.value("error");
  }
}
