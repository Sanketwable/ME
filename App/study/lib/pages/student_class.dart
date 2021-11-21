import 'package:flutter/material.dart';
import 'package:study/controllers/token.dart';
import 'package:study/pages/redirect_page.dart';
import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import '../pages/student_assignment_page.dart';
import '../constants/constants.dart';
import './signup_page.dart';
import '../controllers/token.dart';

var classData;

class StudentClass extends StatefulWidget {
  StudentClass(data) {
    classData = data;
  }
  @override
  _StudentClassState createState() => _StudentClassState();
}

class _StudentClassState extends State<StudentClass> {
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
            icon: Icon(Icons.post_add),
            label: 'Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_sharp),
            label: 'Assignments',
          ),
        ],
        currentIndex: _selectedPage,
        selectedItemColor: Colors.blue[800],
        onTap: (index) {
          _onItemTapped(index);
        },
      ),
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
      body: new Container(child: _buildChild(_selectedPage)),
    );
  }

  Widget _buildChild(int index) {
    switch (index) {
      case 0:
        return PostPage();
      case 1:
        return AssignmentPage();
      default:
        return Center(
          child: Container(
            child: Text("default"),
          ),
        );
    }
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
                  child: Column(
                    children: [
                      const Center(child: Text('Please wait its loading...')),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  ),
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
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) =>
                                                  StudentAssignment(datas)));
                                    },
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

  var postController = TextEditingController();
  Widget PostPage() {
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
                  print(snapshot);
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
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Color(0x332980b9)),
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
                                                  padding: EdgeInsets.all(5),
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
                                                  padding: EdgeInsets.all(5),
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Text(
                                                    "Date : " +
                                                        datas["time"]
                                                            .substring(0, 10) +
                                                        "\nTime : " +
                                                        datas["time"]
                                                            .substring(10),
                                                    style: TextStyle(
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
                                    Divider(
                                      color: Color(0x332980b9),
                                    ),
                                    Container(
                                      // padding: EdgeInsets.all(0),
                                      child: Center(
                                        child: TextButton(
                                            onPressed: () {
                                              var cntx = Comments(
                                                  context, datas["post_id"]);
                                            },
                                            child: Text("Comments")),
                                      ),
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

  BuildContext Comments(BuildContext context, int postID) {
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
                  print(snapshot);
                  var commentController = TextEditingController();
                  return Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          child: Text("Comments"),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Container(
                              padding: EdgeInsets.all(5),
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
                                  Expanded(
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
                                      padding: EdgeInsets.symmetric(
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
                                      padding: EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Color(0x332980b9)),
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
                                                            EdgeInsets.all(2),
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          datas["user_id"]
                                                              .toString(),
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
                                                            EdgeInsets.all(2),
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          datas["comment"],
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 15),
                                                        ),
                                                      ),
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(2),
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                          datas["time"]
                                                              .substring(0, 10),
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
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
                            child: Text("close")),
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
      print(obj);
      return obj;
    }
    var obj = json.decode(res);
    print(obj);
    return Future.value(obj["error"]);
  }

  Future<List<dynamic>> getPosts() async {
    var token = await getValue("token");
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.get(
      url + '/getposts?class_id=' + classData["class_id"].toString(),
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
    print(obj);
    if (response1.statusCode == 200) {
      return Future.value("sucessfull");
    }
    var emailError = obj['error'];
    return Future.value("error");
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
