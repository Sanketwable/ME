import 'dart:developer';
import 'dart:ui';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
import 'package:getwidget/getwidget.dart';
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
              if (_selectedPage == 0) {
                print("here with selectedpage = 0");
              } else if (_selectedPage == 1) {
                print("here with selectedpage = 1");
                var dialogContext = addAssignment(context);
              } else {
                print("here with selectedpage = 2");
                var dialogContext = addStudentEmail(context);
              }
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
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            "Assignments",
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
                              child: Text('You are no assignments')),
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
                                      color: Colors.blue[50],
                                      borderRadius: BorderRadius.circular(10)),
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child: Text(
                                              datas["name"]
                                                  .toString()
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "Due : " + datas["due"],
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 11),
                                              ),
                                              Spacer(),
                                              Container(
                                                child: CircleAvatar(
                                                    radius: 20,
                                                    onBackgroundImageError:
                                                        (Object, StackTrace) =>
                                                            {},
                                                    backgroundImage: datas[
                                                                "assignment_type"] ==
                                                            0
                                                        ? NetworkImage(
                                                            "https://i.ibb.co/6bnkDz6/file-png.jpg")
                                                        : NetworkImage(
                                                            "https://i.ibb.co/64MbTYL/assignment-file-folder-500x500.png")),
                                              ),
                                            ],
                                          ),
                                          datas["assignment_type"] == 0
                                              ? const Text(
                                                  "file assignment",
                                                  style: TextStyle(
                                                      color: Colors.blueAccent,
                                                      fontSize: 12),
                                                )
                                              : const Text(
                                                  "form assignment",
                                                  style: TextStyle(
                                                      color: Colors.blueAccent,
                                                      fontSize: 12),
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
            future: getAssignments(),
          ),
        ),
      ],
    );
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

  Future<List<dynamic>> getAssignments() async {
    var token = await getValue("token");
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.get(
      url + '/getassignment?class_id=' + classData["class_id"].toString(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
    );
    var res = response1.body;

    if (response1.statusCode == 200) {
      var obj = json.decode(res);
      print(obj);
      return obj;
    }
    var obj = json.decode(res);
    print(obj);
    return Future.value(obj["error"]);
  }

  Refresh() {
    setState(() {
      _selectedPage = _selectedPage;
    });
  }

  BuildContext addAssignment(BuildContext context) {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return MyDialog(Refresh);
        });
    return context;
  }
}

class MyVector {
  var question = TextEditingController();
  var option1 = TextEditingController();
  var option2 = TextEditingController();
  var option3 = TextEditingController();
  var option4 = TextEditingController();
  var Answer = TextEditingController();
}

class MyQuestion {
  String question = "";
  String option1 = "";
  String option2 = "";
  String option3 = "";
  String option4 = "";
  int answer = 0;
  Map toJson() => {
        'question': question,
        'option1': option1,
        'option2': option2,
        'option3': option3,
        'option4': option4,
        'answer': answer,
      };
}

class MyDialog extends StatefulWidget {
  Function callback;
  MyDialog(this.callback);
  @override
  _MyDialogState createState() => new _MyDialogState(callback);
}

// List of questionAnswer
List<MyVector> questionOptions = [];

class _MyDialogState extends State<MyDialog> {
  Function callback;
  _MyDialogState(this.callback);
  var assignmentDetailsSubmitted = false;
  var assignmentType;
  var assignmentNameController = TextEditingController();
  var descriptionController = TextEditingController();
  var attachmentLinkController = TextEditingController();
  var pointsController = TextEditingController();
  var dueController;
  var assignmentDetailsError = "";
  var totalQuestions = 0;

  increaseQuestion() {
    setState(() {
      totalQuestions++;
      MyVector mv = new MyVector();
      questionOptions.add(mv);
      print("total questions = $totalQuestions");
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 2.0,
      content: assignmentDetailsSubmitted
          ? SizedBox(
              width: MediaQuery.of(context).size.width * 0.2,
              height: MediaQuery.of(context).size.width * 0.2,
              child: const Center(child: CircularProgressIndicator()),
            )
          : SizedBox(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    assignmentDetailsError == ""
                        ? Text("")
                        : Text(
                            assignmentDetailsError,
                            style: TextStyle(color: Colors.red),
                          ),
                    const Padding(
                        padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
                        child: Text(
                          "Enter assignment details",
                          style: TextStyle(color: Colors.blue, fontSize: 10),
                        )),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: TextField(
                        controller: assignmentNameController,
                        obscureText: false,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Assignment Name',
                            hintText: 'Assignment Name'),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                      child: TextField(
                        controller: descriptionController,
                        obscureText: false,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Description',
                            hintText: 'Description'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      child: TextField(
                        controller: pointsController,
                        obscureText: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Points',
                            hintText: 'Points'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: Container(
                        // height: 50,
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.all(20),
                        child: DropdownButtonHideUnderline(
                          child: GFDropdown(
                            padding: const EdgeInsets.all(10),
                            borderRadius: BorderRadius.circular(10),
                            border: const BorderSide(
                                color: Colors.black12, width: 1),
                            dropdownButtonColor: Colors.grey[300],
                            value: assignmentType,
                            hint: Text("Assignment Type"),
                            onChanged: (newValue) {
                              setState(() {
                                assignmentType = newValue;
                              });
                            },
                            items: ['Form', 'File']
                                .map((value) => DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                    assignmentType.toString() == "Form"
                        ? Column(
                            children: [
                              SizedBox(
                                child: TextButton(
                                    onPressed: () => {increaseQuestion()},
                                    child: Text("add")),
                              ),
                              SizedBox(
                                height: 300,
                                width: double.maxFinite,
                                child: ListView.builder(
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemCount: totalQuestions,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              "Q" + (index + 1).toString(),
                                              style: TextStyle(fontSize: 11),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5,
                                                            vertical: 1),
                                                    child: TextField(
                                                      selectionHeightStyle:
                                                          BoxHeightStyle.tight,
                                                      style: TextStyle(
                                                          fontSize: 11),
                                                      controller:
                                                          questionOptions[index]
                                                              .question,
                                                      obscureText: false,
                                                      decoration:
                                                          const InputDecoration(
                                                              // border: OutlineInputBorder(),
                                                              constraints:
                                                                  BoxConstraints(
                                                                maxHeight: 50,
                                                                minHeight: 40,
                                                              ),
                                                              labelText:
                                                                  'Question',
                                                              hintText:
                                                                  'Add question'),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "a.",
                                              style: TextStyle(fontSize: 11),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5,
                                                            vertical: 1),
                                                    child: TextField(
                                                      selectionHeightStyle:
                                                          BoxHeightStyle.tight,
                                                      style: TextStyle(
                                                          fontSize: 11),
                                                      controller:
                                                          questionOptions[index]
                                                              .option1,
                                                      obscureText: false,
                                                      decoration:
                                                          const InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(),
                                                              constraints:
                                                                  BoxConstraints(
                                                                maxHeight: 40,
                                                                minHeight: 30,
                                                              ),
                                                              hintText:
                                                                  'option'),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "b.",
                                              style: TextStyle(fontSize: 11),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5,
                                                            vertical: 1),
                                                    child: TextField(
                                                      selectionHeightStyle:
                                                          BoxHeightStyle.tight,
                                                      style: TextStyle(
                                                          fontSize: 11),
                                                      controller:
                                                          questionOptions[index]
                                                              .option2,
                                                      obscureText: false,
                                                      decoration:
                                                          const InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(),
                                                              constraints:
                                                                  BoxConstraints(
                                                                maxHeight: 40,
                                                                minHeight: 30,
                                                              ),
                                                              hintText:
                                                                  'option'),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "c.",
                                              style: TextStyle(fontSize: 11),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5,
                                                            vertical: 1),
                                                    child: TextField(
                                                      selectionHeightStyle:
                                                          BoxHeightStyle.tight,
                                                      style: TextStyle(
                                                          fontSize: 11),
                                                      controller:
                                                          questionOptions[index]
                                                              .option3,
                                                      obscureText: false,
                                                      decoration:
                                                          const InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(),
                                                              constraints:
                                                                  BoxConstraints(
                                                                maxHeight: 40,
                                                                minHeight: 30,
                                                              ),
                                                              hintText:
                                                                  'option'),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "d.",
                                              style: TextStyle(fontSize: 11),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2),
                                                child: Center(
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5,
                                                            vertical: 1),
                                                    child: TextField(
                                                      selectionHeightStyle:
                                                          BoxHeightStyle.tight,
                                                      style: TextStyle(
                                                          fontSize: 11),
                                                      controller:
                                                          questionOptions[index]
                                                              .option4,
                                                      obscureText: false,
                                                      decoration:
                                                          const InputDecoration(
                                                              border:
                                                                  OutlineInputBorder(),
                                                              constraints:
                                                                  BoxConstraints(
                                                                maxHeight: 40,
                                                                minHeight: 30,
                                                              ),
                                                              hintText:
                                                                  'option'),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                        : (assignmentType.toString() == "File"
                            ? Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    child: TextField(
                                      controller: descriptionController,
                                      obscureText: false,
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Description',
                                          hintText: 'Description'),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    child: TextField(
                                      controller: attachmentLinkController,
                                      obscureText: false,
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Attachment Link',
                                          hintText: 'Attachment Link'),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    child: TextField(
                                      controller: pointsController,
                                      obscureText: false,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly
                                      ],
                                      decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Points',
                                          hintText: 'Points'),
                                    ),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Container(
                                  child: Text(
                                    "please select the assignment type",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.red,
                                    ),
                                  ),
                                ))),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Center(
                          child: Container(
                        child: Text("Due Date"),
                      )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            // border:
                            //     Border.all(color: Colors.blueAccent)
                            ),
                        height: 36,
                        width: double.maxFinite,
                        child: CupertinoTheme(
                          data: CupertinoThemeData(
                            textTheme: CupertinoTextThemeData(
                              dateTimePickerTextStyle: TextStyle(fontSize: 15),
                            ),
                            // barBackgroundColor: Colors.red,
                            // primaryColor: Colors.red,
                            // brightness: Brightness.light,
                            // scaffoldBackgroundColor: Colors.red,
                            // primaryContrastingColor: Colors.red,
                          ),
                          child: CupertinoDatePicker(
                            backgroundColor: Colors.white,
                            mode: CupertinoDatePickerMode.date,
                            initialDateTime:
                                DateTime(now.year, now.month, now.day),
                            onDateTimeChanged: (DateTime newDateTime) {
                              dueController = newDateTime;
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 38.0, bottom: 8.0),
                      child: Container(
                        height: 50,
                        width: 250,
                        decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(20)),
                        child: TextButton(
                          onPressed: () async {
                            setState(() {
                              assignmentDetailsSubmitted = true;
                            });
                            var response = await addAssignmentRequest();
                            if (response == "error") {
                              setState(() {
                                assignmentDetailsSubmitted = false;
                                assignmentDetailsError = "";
                                print("failed to add class");
                              });
                            } else {
                              setState(() {
                                callback();

                                print("setstate classed");
                                assignmentDetailsSubmitted = false;
                                assignmentNameController.clear();
                                descriptionController.clear();
                                attachmentLinkController.clear();
                                pointsController.clear();
                                Navigator.pop(context);
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
                    ),
                    const SizedBox(
                      height: 90,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  DateTime now = DateTime.now();

  Future<String> addAssignmentRequest() async {
    var token = await getValue("token");
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    if (assignmentType.toString() == "Form") {
      var asType = 1;
      // ignore: non_constant_identifier_names
      List<MyQuestion> Questions = [];
      List<String> qsns = [];
      for (var i = 0; i < questionOptions.length; i++) {
        MyQuestion q = new MyQuestion();
        q.option1 = questionOptions[i].option1.text;
        q.option2 = questionOptions[i].option2.text;
        q.option3 = questionOptions[i].option3.text;
        q.option4 = questionOptions[i].option4.text;
        q.question = questionOptions[i].question.text;
        // q.answer = int.parse(questionOptions[i].Answer.toString());
        Questions.add(q);
        var qencodejson = jsonEncode(q);
        qsns.add(qencodejson);
      }
      var encodedjson = jsonEncode(Questions);
      print(qsns);
      final http.Response response1 = await http1.post(
        url + '/createassignment',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': "Bearer " + token,
        },
        body: jsonEncode(<String, dynamic>{
          "class_id": int.parse(classData["class_id"].toString()),
          "name": assignmentNameController.text,
          "assignment_type": asType,
          "due": dueController.toString(),
          "form_assignment": {
            "description": descriptionController.text,
            "questions": Questions,
            "points": int.parse(pointsController.text),
          },
        }),
      );
      print(response1.statusCode);
      var res = response1.body;
      var obj = json.decode(res);
      print(obj["error"]);
      if (response1.statusCode == 200) {
        var obj = json.decode(res);
        print(obj);
        return obj.toString();
      }
      // classDetailsError = obj['error'];
      return Future.value("error");
    } else if (assignmentType.toString() == "File") {
      var asType = 0;
      final http.Response response1 = await http1.post(
        url + '/createassignment',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': "Bearer " + token,
        },
        body: jsonEncode(<String, dynamic>{
          "class_id": int.parse(classData["class_id"].toString()),
          "name": assignmentNameController.text,
          "assignment_type": asType,
          "due": dueController.toString(),
          "file_assignment": {
            "description": descriptionController.text,
            "attachment_link": attachmentLinkController.text,
            "points": int.parse(pointsController.text),
          },
        }),
      );
      print(response1.statusCode);
      var res = response1.body;
      if (response1.statusCode == 200) {
        var obj = json.decode(res);
        print(obj);
        return obj.toString();
      }
      // classDetailsError = obj['error'];
      return Future.value("error");
    }
    return Future.value("error");
  }
}
