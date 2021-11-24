import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:study/controllers/token.dart';
import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'package:study/pages/student_home_page.dart';
import '../pages/student_assignment_page.dart';
import '../constants/constants.dart';

import '../controllers/token.dart';

// ignore: prefer_typing_uninitialized_variables
var userID;

class Message {
  int message_ID = 0;
  int classID = 0;
  int userID = 0;
  String message = "";
  String firstName = "";
  String lastName = "";
  String time = "";

  Map toJson() => {
        'message_id': message_ID,
        'class_id': classID,
        'user_id': userID,
        'message': message,
        'first_name': firstName,
        'last_name': lastName,
        'time': time,
      };
  Message(this.message_ID, this.classID, this.userID, this.message,
      this.firstName, this.lastName, this.time);

  factory Message.fromJson(dynamic json) {
    return Message(
        json['message_id'] as int,
        json['class_id'] as int,
        json['user_id'] as int,
        json['message'] as String,
        json['first_name'] as String,
        json['last_name'] as String,
        json['time'] as String);
  }
}

class StudentClass extends StatefulWidget {
  var classData;
  StudentClass(data, {Key? key}) : super(key: key) {
    classData = data;
  }
  @override
  _StudentClassState createState() => _StudentClassState(classData);
}

class _StudentClassState extends State<StudentClass> {
  List<Message> messages = [];
  MyClasses classData;
  ScrollController _scrollController = ScrollController();
  _StudentClassState(this.classData);
  int _selectedPage = 0;
  void _onItemTapped(int index) {
    if (_selectedPage != index) {
      setState(() {
        _selectedPage = index;
      });
    }
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
              icon: Icon(Icons.post_add),
              label: 'Posts',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message_sharp),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
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
          title: const Text('Student'),
        ),
        body: Container(child: _buildChild(_selectedPage)),
      ),
    );
  }

  Widget _buildChild(int index) {
    switch (index) {
      case 0:
        return postPage();
      case 1:
        return messagePage();
      case 2:
        return assignmentPage();
      default:
        return const Center(
          child: Text("default"),
        );
    }
  }

  var messageController = TextEditingController();
  Widget messagePage() {
    return Column(
      children: [
        Flexible(
          flex: 1,
          fit: FlexFit.tight,
          child: Scaffold(
            appBar: AppBar(
              elevation: 3,
              automaticallyImplyLeading: false,
              backgroundColor: Colors.white,
              flexibleSpace: SafeArea(
                child: Container(
                  padding: EdgeInsets.only(right: 16, left: 10),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 2,
                      ),
                      CircleAvatar(
                        backgroundImage: NetworkImage(classData.imageLink),
                        maxRadius: 20,
                      ),
                      SizedBox(
                        width: 12,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              classData.subject,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(
                              height: 6,
                            ),
                            Text(
                              classData.branch +
                                  " " +
                                  classData.year.toString(),
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 9,
          child: Column(
            children: [
              Expanded(
                flex: 9,
                child: StreamBuilder(
                  stream: getMessages(),
                  builder:
                      (BuildContext context, AsyncSnapshot<List> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.30),
                        child: const Center(
                            child: Text('Please wait its loading...')),
                      );
                    } else {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                itemCount: messages.length,
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                controller: _scrollController,
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: EdgeInsets.only(
                                        left: 14,
                                        right: 14,
                                        top: 10,
                                        bottom: 0),
                                    child: Align(
                                      alignment:
                                          (messages[index].userID.toString() !=
                                                  userID
                                              ? Alignment.topLeft
                                              : Alignment.topRight),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: (messages[index]
                                                      .userID
                                                      .toString() !=
                                                  userID
                                              ? Colors.grey.shade200
                                              : Colors.blue[200]),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.only(
                                                    top: 3, left: 2),
                                                child: messages[index]
                                                            .userID
                                                            .toString() !=
                                                        userID
                                                    ? Text(
                                                        messages[index]
                                                                .firstName +
                                                            " " +
                                                            messages[index]
                                                                .lastName,
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.blue),
                                                        textAlign:
                                                            TextAlign.left)
                                                    : SizedBox.shrink()),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 8.0,
                                                  left: 15,
                                                  right: 15,
                                                  top: 8),
                                              child: Text(
                                                messages[index].message,
                                                style: TextStyle(fontSize: 15),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 3.0,
                                                  left: 15,
                                                  right: 15),
                                              child: Text(
                                                messages[index].time,
                                                style: TextStyle(fontSize: 9),
                                              ),
                                            ),
                                            // controllScrollView(_scrollController),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    }
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 10, bottom: 10, top: 10),
                  height: 60,
                  width: double.infinity,
                  color: Colors.white,
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: Colors.lightBlue,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                              hintText: "Write message...",
                              hintStyle: TextStyle(color: Colors.black54),
                              border: InputBorder.none),
                          onSubmitted: (String str) async {
                            await sendMessage();
                            messageController.clear();
                            _scrollController.jumpTo(
                              _scrollController.position.maxScrollExtent,
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      FloatingActionButton(
                        onPressed: () async {
                          await sendMessage();
                          messageController.clear();
                          _scrollController.jumpTo(
                            _scrollController.position.maxScrollExtent,
                          );
                        },
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 18,
                        ),
                        backgroundColor: Colors.blue,
                        elevation: 0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget controllScrollView(ScrollController scc) {
    scc.jumpTo(
      scc.position.maxScrollExtent,
    );
    return SizedBox.shrink();
  }

  Stream<List<dynamic>> getMessages() async* {
    while (true) {
      await Future.delayed(const Duration(milliseconds: 500));
      var someProduct = await getMessagesAPI();
      yield someProduct;
    }
  }

  Future<List> getMessagesAPI() async {
    userID = await getUserID();
    var token = await getValue("token");
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);

    final http.Response response1 = await http1.get(
      url + '/message?class_id=' + classData.classID.toString(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
    );
    var res = response1.body;

    if (response1.statusCode == 200) {
      var classesObjsJson = jsonDecode(res) as List;
      messages =
          classesObjsJson.map((tagJson) => Message.fromJson(tagJson)).toList();
      return classes;
    }
    var obj = json.decode(res);

    return Future.value(obj["error"]);
  }

  Future<String> sendMessage() async {
    var token = await getValue("token");

    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.post(
      url + '/message',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
      body: jsonEncode(<String, dynamic>{
        "class_id": classData.classID,
        "message": messageController.text,
      }),
    );

    if (response1.statusCode == 200) {
      return Future.value("sucessfull");
    }

    return Future.value("error");
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
                      vertical: MediaQuery.of(context).size.width * 0.30),
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
                                                  StudentAssignment(datas)));
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
                                                    (object, sackTrace) => {},
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

  Future<List<dynamic>> getAssignments() async {
    var token = await getValue("token");
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.get(
      url + '/getassignment?class_id=' + classData.classID.toString(),
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

  var postController = TextEditingController();
  Widget postPage() {
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
                      classData.branch + " ",
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    Text(
                      classData.year.toString(),
                      style: const TextStyle(color: Colors.black, fontSize: 18),
                    ),
                    const Spacer(),
                    CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(classData.imageLink)),
                  ],
                ),
                Text(
                  "Class code : " + classData.classCode,
                  style:
                      const TextStyle(color: Colors.blueAccent, fontSize: 12),
                ),
                Text(
                  classData.classLink + "\n",
                  style: const TextStyle(color: Colors.blue, fontSize: 11),
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 15, bottom: 10),
                  child: Text(
                    classData.subject.toString().toUpperCase(),
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
        Expanded(
          flex: 9,
          child: FutureBuilder(
            builder: (context, AsyncSnapshot<List> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.width * 0.30),
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
                                                        "\n" +
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
                      vertical: MediaQuery.of(context).size.width * 0.30),
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
                                                              " " +
                                                              datas[
                                                                  "last_name"],
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
      url + '/getposts?class_id=' + classData.classID.toString(),
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

    if (response1.statusCode == 200) {
      return Future.value("sucessfull");
    }

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
