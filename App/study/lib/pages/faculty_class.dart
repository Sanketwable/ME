import 'dart:ui';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:study/controllers/token.dart';
import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'package:study/pages/student_home_page.dart';
import '../constants/constants.dart';

import 'package:getwidget/getwidget.dart';
import '../controllers/token.dart';
import 'faculty_assignment_page.dart';

// ignore: prefer_typing_uninitialized_variables

class FacultyClass extends StatefulWidget {
  var classData;
  FacultyClass(data, {Key? key}) : super(key: key) {
    classData = data;
  }

  @override
  _FacultyClassState createState() => _FacultyClassState(classData);
}

class _FacultyClassState extends State<FacultyClass> {
  int _selectedPage = 0;
  MyClasses facultyClass;
  _FacultyClassState(this.facultyClass);
  void _onItemTapped(int index) {
    setState(() {
      _selectedPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
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
          title: const Text('Faculty'),
        ),
        floatingActionButton: _selectedPage == 0
            ? const SizedBox.shrink()
            : Container(
                padding: const EdgeInsets.all(20),
                child: FittedBox(
                  child: FloatingActionButton(
                    onPressed: () {
                      if (_selectedPage == 1) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    MyDialog(refresh, facultyClass)));
                      } else {
                        addStudentEmail(context);
                      }
                    },
                    child: const Icon(Icons.add),
                    tooltip: "Add Student to Class",
                    isExtended: true,
                    autofocus: true,
                  ),
                ),
              ),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        body: _selectedPage == 0
            ? timeLinePage()
            : (_selectedPage == 1 ? assignmentPage() : studentsPage()),
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
                    child: const CircularProgressIndicator()))
            : Column(
                children: [
                  emailError == ""
                      ? const Text("")
                      : Text(
                          emailError,
                          style: const TextStyle(color: Colors.red),
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

                              addStudentEmail(context);
                              emailError = "";
                            } else {
                              setState(() {
                                emailSubmitted = false;
                              });
                              Navigator.pop(ctx);
                              Navigator.pop(context);
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
    var postController = TextEditingController();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              // border: Border.all(
              //     color: Colors.white, width: 0.5, style: BorderStyle.solid),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(
                    2.0,
                    2.0,
                  ),
                  blurRadius: 2.0,
                  spreadRadius: 2.0,
                ), //BoxShadow
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "   " + facultyClass.branch + " ",
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    Text(
                      facultyClass.year.toString(),
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    const Spacer(),
                    CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(facultyClass.imageLink)),
                  ],
                ),
                Text(
                  "Class code : " + facultyClass.classCode,
                  style:
                      const TextStyle(color: Colors.blueAccent, fontSize: 12),
                ),
                Text(
                  facultyClass.classLink + "\n",
                  style: const TextStyle(color: Colors.blue, fontSize: 11),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 15, bottom: 10),
                  child: Text(
                    facultyClass.subject.toString().toUpperCase(),
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 28,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              // border: Border.all(
              //     color: Colors.white, width: 0.5, style: BorderStyle.solid),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black,
                  offset: Offset(
                    0.0,
                    3.0,
                  ),
                  blurRadius: 3.0,
                  spreadRadius: 1.0,
                ), //BoxShadow
              ],
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 25,
                    backgroundImage: NetworkImage(
                        "https://i.ibb.co/xSk0BBy/mindset-converted-vector-hand-drawn-illustration-lettering-phrases-new-post-idea-poster-postcard-189.jpg"),
                  ),
                ),
                Expanded(
                  flex: 8,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: TextField(
                      controller: postController,
                      obscureText: false,
                      onSubmitted: (str) async {
                        String response = await addPost(str);
                        if (response == "sucessfull") {
                          postController.clear();
                          setState(() {});
                        }
                      },
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Add Post',
                          hintText: 'Write here to add post'),
                    ),
                  ),
                ),
              ],
            ),
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
                  child: Column(
                    children: const [
                      Center(child: Text('Please wait its loading...')),
                      Padding(
                        padding: EdgeInsets.all(15.0),
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  ),
                );
              } else {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return snapshot.data!.isEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.width * 0.40),
                          child:
                              const Center(child: Text('Their are no posts')),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var datas = snapshot.data![index];
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: const Color(0x332980b9)),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: Colors.white,
                                          radius: 25,
                                          backgroundImage: NetworkImage(
                                              "https://i.ibb.co/4Jf3Qk6/Screenshot-2021-11-21-at-5-18-27-PM.jpg"),
                                        ),
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Column(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    datas["description"],
                                                    maxLines: 5,
                                                    overflow:
                                                        TextOverflow.visible,
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    datas["first_name"] +
                                                        " " +
                                                        datas["last_name"] +
                                                        "\n"
                                                            "Date : " +
                                                        datas["time"]
                                                            .substring(0, 10) +
                                                        "\nTime : " +
                                                        datas["time"]
                                                            .substring(10),
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 15),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        // Text(
                                        //   "sanket\n\n\n",
                                        //   style: TextStyle(
                                        //       color: Colors.white,
                                        //       fontSize: 11),
                                        // ),
                                      ],
                                    ),
                                    const Divider(
                                      color: Color(0x332980b9),
                                    ),
                                    Center(
                                      child: TextButton(
                                          onPressed: () {
                                            comments(context, datas["post_id"]);
                                          },
                                          child: const Text("Comments")),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                }
              }
            },
            future: getPosts(),
          ),
        ),
      ],
    );
  }

  BuildContext comments(BuildContext context, int postID) {
    AlertDialog alert = AlertDialog(
      elevation: 5.0,
      content: SizedBox(
          height: MediaQuery.of(context).size.height * 0.80,
          width: MediaQuery.of(context).size.width * 0.80,
          child: FutureBuilder(
            builder: (context, AsyncSnapshot<List> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.width * 0.40),
                  child: Column(
                    children: const [
                      Center(child: Text('Please wait its loading...')),
                      Padding(
                        padding: EdgeInsets.all(15.0),
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  ),
                );
              } else {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  var commentController = TextEditingController();
                  return Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: const Text("Comments"),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(10),
                              // border: Border.all(
                              //     color: Colors.white, width: 0.5, style: BorderStyle.solid),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(
                                    0.0,
                                    3.0,
                                  ),
                                  blurRadius: 3.0,
                                  spreadRadius: 1.0,
                                ), //BoxShadow
                              ],
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  flex: 2,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.white,
                                    radius: 25,
                                    backgroundImage: NetworkImage(
                                        "https://i.ibb.co/5nmxwtY/2186059.png"),
                                  ),
                                ),
                                Expanded(
                                  flex: 8,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 5),
                                    child: TextField(
                                      controller: commentController,
                                      obscureText: false,
                                      onSubmitted: (str) async {
                                        Navigator.pop(context);
                                        String response =
                                            await addComment(str, postID);
                                        if (response == "sucessfull") {
                                          commentController.clear();

                                          setState(() {});
                                        }
                                      },
                                      decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          labelText: 'Add Comment',
                                          hintText:
                                              'Write here to add comment'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: snapshot.data!.isEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            0.40),
                                child: const Center(child: Text('No Comments')),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  var datas = snapshot.data![index];
                                  return Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color(0x332980b9)),
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              const CircleAvatar(
                                                backgroundColor: Colors.white,
                                                radius: 15,
                                                backgroundImage: NetworkImage(
                                                    "https://i.ibb.co/4Jf3Qk6/Screenshot-2021-11-21-at-5-18-27-PM.jpg"),
                                              ),
                                              Flexible(
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          datas["first_name"] +
                                                              datas[
                                                                  "last_name"] +
                                                              "\n".toString(),
                                                          overflow: TextOverflow
                                                              .visible,
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          datas["comment"],
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 15),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          datas["time"]
                                                              .substring(0, 10),
                                                          style:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 10),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              // Text(
                                              //   "sanket\n\n\n",
                                              //   style: TextStyle(
                                              //       color: Colors.white,
                                              //       fontSize: 11),
                                              // ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("close")),
                      )
                    ],
                  );
                }
              }
            },
            future: getComments(postID),
          )),
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

  Widget assignmentPage() {
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
                  child: Column(
                    children: const [
                      Center(child: Text('Please wait its loading...')),
                      Padding(
                        padding: EdgeInsets.all(15.0),
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  ),
                );
              } else {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
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
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  FacultyAssignment(datas)));
                                    },
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Text(
                                            datas["name"]
                                                .toString()
                                                .toUpperCase(),
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 15),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Due : " + datas["due"],
                                              style: const TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 11),
                                            ),
                                            const Spacer(),
                                            CircleAvatar(
                                                radius: 20,
                                                onBackgroundImageError:
                                                    (object, stackTrace) => {},
                                                backgroundImage: datas[
                                                            "assignment_type"] ==
                                                        0
                                                    ? const NetworkImage(
                                                        "https://i.ibb.co/6bnkDz6/file-png.jpg")
                                                    : const NetworkImage(
                                                        "https://i.ibb.co/64MbTYL/assignment-file-folder-500x500.png")),
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

  List<Student> studentlist = [];
  Widget studentsPage() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            "Students",
            style: TextStyle(
                color: Colors.grey, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: 9,
          child: FutureBuilder(
            builder: (context, AsyncSnapshot<List> snapshot) {
              // snapshot.connectionState == ConnectionState.waiting
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  if (studentlist.isEmpty &&
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.width * 0.40),
                      child: const Center(
                          child: Text('Please wait its loading...')),
                    );
                  }
                  return studentlist.isEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.width * 0.40),
                          child: const Center(
                              child:
                                  Text('No Student enrolled to this classes')),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: studentlist.length,
                          itemBuilder: (context, index) {
                            var datas = studentlist[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 4, bottom: 4),
                              child: Center(
                                child: Container(
                                  // width:
                                  //     MediaQuery.of(context).size.width * 0.95,
                                  // decoration: BoxDecoration(
                                  //     boxShadow: const [
                                  //       BoxShadow(
                                  //         color: Colors.grey,
                                  //         offset: Offset(
                                  //           5.0,
                                  //           5.0,
                                  //         ),
                                  //         blurRadius: 10.0,
                                  //         spreadRadius: 2.0,
                                  //       ), //BoxShadow
                                  //     ],
                                  //     border: Border.all(
                                  //         color: Colors.black,
                                  //         width: 0.5,
                                  //         style: BorderStyle.none),
                                  //     color: Colors.white,
                                  //     borderRadius: BorderRadius.circular(10)),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, top: 4, bottom: 4),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                            radius: 20,
                                            backgroundImage: NetworkImage(
                                                studentlist[index].profileUrl)),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 8.0),
                                          child: Text(
                                            studentlist[index].firstName +
                                                " " +
                                                studentlist[index].lastName,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
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
            future: getStudentList(),
          ),
        ),
      ],
    );
  }

  Future<List<dynamic>> getStudentList() async {
    var token = await getValue("token");
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.get(
      url + '/studentlist?class_id=' + facultyClass.classID.toString(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
    );
    var res = response1.body;

    if (response1.statusCode == 200) {
      var tagObjsJson = jsonDecode(res) as List;
      studentlist =
          tagObjsJson.map((tagJson) => Student.fromJson(tagJson)).toList();

      return studentlist;
    }
    var obj = json.decode(res);

    return Future.value(obj["error"]);
  }

  Future<String> addStudentEmailRequest() async {
    var token = await getValue("token");

    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.get(
      url +
          '/addstudent?email=' +
          studentEmailController.text +
          "&class_id=" +
          facultyClass.classID.toString(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
    );
    var res = response1.body;
    var obj = json.decode(res);

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
      url + '/getassignment?class_id=' + facultyClass.classID.toString(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
    );
    var res = response1.body;

    if (response1.statusCode == 200) {
      var obj = json.decode(res);

      return obj;
    }
    var obj = json.decode(res);

    return Future.value(obj["error"]);
  }

  refresh() {
    setState(() {
      _selectedPage = _selectedPage;
    });
  }

  Future<List<dynamic>> getComments(int postID) async {
    var token = await getValue("token");
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.get(
      url + '/getcomments?post_id=' + postID.toString(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
    );
    var res = response1.body;

    if (response1.statusCode == 200) {
      var obj = json.decode(res);

      return obj;
    }
    var obj = json.decode(res);

    return Future.value(obj["error"]);
  }

  Future<List<dynamic>> getPosts() async {
    var token = await getValue("token");
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.get(
      url + '/getposts?class_id=' + facultyClass.classID.toString(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
    );
    var res = response1.body;

    if (response1.statusCode == 200) {
      var obj = json.decode(res);

      return obj;
    }
    var obj = json.decode(res);

    return Future.value(obj["error"]);
  }

  Future<String> addComment(String comment, int classID) async {
    var token = await getValue("token");

    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.post(
      url + '/createcomment',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
      body: jsonEncode(<String, dynamic>{
        "post_id": int.parse(classID.toString()),
        "comment": comment,
      }),
    );
    var res = response1.body;
    var obj = json.decode(res);

    if (response1.statusCode == 200) {
      return Future.value("sucessfull");
    }
    emailError = obj['error'];
    return Future.value("error");
  }

  Future<String> addPost(String post) async {
    var token = await getValue("token");

    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.post(
      url + '/createpost',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
      body: jsonEncode(<String, dynamic>{
        "class_id": int.parse(facultyClass.classID.toString()),
        "description": post,
      }),
    );
    var res = response1.body;
    var obj = json.decode(res);

    if (response1.statusCode == 200) {
      return Future.value("sucessfull");
    }
    emailError = obj['error'];
    return Future.value("error");
  }
}

class MyVector {
  var question = TextEditingController();
  var option1 = TextEditingController();
  var option2 = TextEditingController();
  var option3 = TextEditingController();
  var option4 = TextEditingController();
  var answer = TextEditingController();
}

class Student {
  String firstName = "";
  String lastName = "";
  String profileUrl = "";

  Map toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'profile_url': profileUrl,
      };
  Student(this.firstName, this.lastName, this.profileUrl);
  factory Student.fromJson(dynamic json) {
    return Student(
      json['first_name'] as String,
      json['last_name'] as String,
      json['profile_url'] as String,
    );
  }
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
  MyQuestion(this.question, this.option1, this.option2, this.option3,
      this.option4, this.answer);
  factory MyQuestion.fromJson(dynamic json) {
    return MyQuestion(
        json['question'] as String,
        json['option1'] as String,
        json['option2'] as String,
        json['option3'] as String,
        json['option4'] as String,
        json['answer'] as int);
  }
}

// ignore: must_be_immutable
class MyDialog extends StatefulWidget {
  Function callback;
  var data;
  MyDialog(this.callback, this.data, {Key? key}) : super(key: key);
  @override
  // ignore: no_logic_in_create_state
  _MyDialogState createState() => _MyDialogState(callback, data);
}

// List of questionAnswer
List<MyVector> questionOptions = [];

class _MyDialogState extends State<MyDialog> {
  Function callback;
  MyClasses facultyClass;
  _MyDialogState(this.callback, this.facultyClass);
  var assignmentDetailsSubmitted = false;
  // ignore: prefer_typing_uninitialized_variables
  var assignmentType;
  var assignmentNameController = TextEditingController();
  var descriptionController = TextEditingController();
  var attachmentLinkController = TextEditingController();
  var pointsController = TextEditingController();
  // ignore: prefer_typing_uninitialized_variables
  var dueController;
  var assignmentDetailsError = "";
  var totalQuestions = 0;

  increaseQuestion() {
    setState(() {
      totalQuestions++;
      MyVector mv = MyVector();
      questionOptions.add(mv);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty'),
      ),
      body: Container(
        child: assignmentDetailsSubmitted
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
                          ? const Text("")
                          : Text(
                              assignmentDetailsError,
                              style: const TextStyle(color: Colors.red),
                            ),
                      const Padding(
                          padding: EdgeInsets.only(top: 5.0, bottom: 10.0),
                          child: Text(
                            "Enter assignment details",
                            style: TextStyle(color: Colors.blue, fontSize: 10),
                          )),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
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
                        padding: const EdgeInsets.symmetric(
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
                          margin: const EdgeInsets.all(20),
                          child: DropdownButtonHideUnderline(
                            child: GFDropdown(
                              padding: const EdgeInsets.all(10),
                              borderRadius: BorderRadius.circular(10),
                              border: const BorderSide(
                                  color: Colors.black12, width: 1),
                              dropdownButtonColor: Colors.grey[300],
                              value: assignmentType,
                              hint: const Text("Assignment Type"),
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
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextButton(
                                        onPressed: () => {increaseQuestion()},
                                        child: const Text("add")),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.41,
                                  width:
                                      MediaQuery.of(context).size.width * 0.70,
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
                                                style: const TextStyle(
                                                    fontSize: 11),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2),
                                                  child: Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5,
                                                          vertical: 1),
                                                      child: TextField(
                                                        selectionHeightStyle:
                                                            BoxHeightStyle
                                                                .tight,
                                                        style: const TextStyle(
                                                            fontSize: 11),
                                                        controller:
                                                            questionOptions[
                                                                    index]
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
                                              const Text(
                                                "a.",
                                                style: TextStyle(fontSize: 11),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2),
                                                  child: Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5,
                                                          vertical: 1),
                                                      child: TextField(
                                                        selectionHeightStyle:
                                                            BoxHeightStyle
                                                                .tight,
                                                        style: const TextStyle(
                                                            fontSize: 11),
                                                        controller:
                                                            questionOptions[
                                                                    index]
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
                                              const Text(
                                                "b.",
                                                style: TextStyle(fontSize: 11),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2),
                                                  child: Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5,
                                                          vertical: 1),
                                                      child: TextField(
                                                        selectionHeightStyle:
                                                            BoxHeightStyle
                                                                .tight,
                                                        style: const TextStyle(
                                                            fontSize: 11),
                                                        controller:
                                                            questionOptions[
                                                                    index]
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
                                              const Text(
                                                "c.",
                                                style: TextStyle(fontSize: 11),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2),
                                                  child: Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5,
                                                          vertical: 1),
                                                      child: TextField(
                                                        selectionHeightStyle:
                                                            BoxHeightStyle
                                                                .tight,
                                                        style: const TextStyle(
                                                            fontSize: 11),
                                                        controller:
                                                            questionOptions[
                                                                    index]
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
                                              const Text(
                                                "d.",
                                                style: TextStyle(fontSize: 11),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2),
                                                  child: Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5,
                                                          vertical: 1),
                                                      child: TextField(
                                                        selectionHeightStyle:
                                                            BoxHeightStyle
                                                                .tight,
                                                        style: const TextStyle(
                                                            fontSize: 11),
                                                        controller:
                                                            questionOptions[
                                                                    index]
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
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2),
                                                  child: Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          horizontal: 5,
                                                          vertical: 1),
                                                      child: TextField(
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter
                                                              .digitsOnly
                                                        ],
                                                        selectionHeightStyle:
                                                            BoxHeightStyle
                                                                .tight,
                                                        style: const TextStyle(
                                                            fontSize: 11),
                                                        controller:
                                                            questionOptions[
                                                                    index]
                                                                .answer,
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
                                                                    'answer'),
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
                              ? Padding(
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
                              )
                              : const Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    "please select the assignment type",
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.red,
                                    ),
                                  ))),
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Center(child: Text("Due Date")),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          decoration: const BoxDecoration(
                              // border:
                              //     Border.all(color: Colors.blueAccent)
                              ),
                          height: 55,
                          width: double.maxFinite,
                          child: CupertinoTheme(
                            data: const CupertinoThemeData(
                              textTheme: CupertinoTextThemeData(
                                dateTimePickerTextStyle:
                                    TextStyle(fontSize: 15),
                              ),
                              brightness: Brightness.light,
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
                                });
                              } else {
                                setState(() {
                                  callback();

                                  assignmentDetailsSubmitted = false;
                                  assignmentNameController.clear();
                                  descriptionController.clear();
                                  attachmentLinkController.clear();
                                  pointsController.clear();
                                  questionOptions.clear();
                                  Navigator.pop(context);
                                });
                              }
                            },
                            child: const Text(
                              'Submit',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25),
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
      for (var i = 0; i < questionOptions.length; i++) {
        MyQuestion q = MyQuestion(
            questionOptions[i].question.text,
            questionOptions[i].option1.text,
            questionOptions[i].option2.text,
            questionOptions[i].option3.text,
            questionOptions[i].option4.text,
            0);

        // q.answer = int.parse(questionOptions[i].Answer.toString());
        Questions.add(q);
      }
      final http.Response response1 = await http1.post(
        url + '/createassignment',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': "Bearer " + token,
        },
        body: jsonEncode(<String, dynamic>{
          "class_id": int.parse(facultyClass.classID.toString()),
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

      var res = response1.body;

      if (response1.statusCode == 200) {
        var obj = json.decode(res);

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
          "class_id": int.parse(facultyClass.classID.toString()),
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

      var res = response1.body;
      if (response1.statusCode == 200) {
        var obj = json.decode(res);

        return obj.toString();
      }
      // classDetailsError = obj['error'];
      return Future.value("error");
    }
    return Future.value("error");
  }
}
