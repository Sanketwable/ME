import 'dart:io';

import 'package:flutter/material.dart';
import 'package:study/constants/constants.dart';
import 'package:study/controllers/token.dart';
import 'package:study/pages/faculty_class.dart';
import 'package:study/pages/redirect_page.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:convert';

var assignmentData;

class FacultyAssignment extends StatefulWidget {
  FacultyAssignment(data) {
    assignmentData = data;
  }
  // const FacultyAssignment({Key? key}) : super(key: key);

  @override
  _FacultyAssignmentState createState() => _FacultyAssignmentState();
}

class _FacultyAssignmentState extends State<FacultyAssignment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Faculty"),
      ),
      body: AssignmentBody(),
    );
  }

  Widget AssignmentBody() {
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
                    1.0,
                    1.0,
                  ),
                  blurRadius: 12.0,
                  spreadRadius: 1.0,
                ), //BoxShadow
              ],
            ),
            child: Column(
              children: [
                Center(
                  child: Text(
                    "Due : " + assignmentData["due"].toString(),
                    style: TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 15, bottom: 10),
                  child: Text(
                    assignmentData["name"].toString().toUpperCase(),
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
        Padding(
          padding: EdgeInsets.all(8),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text("Description : " + description),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text("Points : " + points.toString()),
          ),
        ),
        assignmentData["assignment_type"] == 0
            ? FutureBuilder(
                builder: (context, AsyncSnapshot<List> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.width * 0.40),
                      child: Center(
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: CircularProgressIndicator(),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: EdgeInsets.all(8),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        child: Text("Attachment Link : " + attachmentLink),
                      ),
                    );
                  }
                },
                future: getFileAssignment(),
              )
            : Expanded(
                flex: 9,
                child: FutureBuilder(
                  builder: (context, AsyncSnapshot<List> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.40),
                        child: Center(
                            child: Column(
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                  'Please wait assignment details loading...'),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: CircularProgressIndicator(),
                            ),
                          ],
                        )),
                      );
                    } else {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return snapshot.data!.isEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            0.40),
                                child: const Center(
                                    child:
                                        Text('No Questions/Assignment Empty')),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.vertical,
                                shrinkWrap: true,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  var datas = snapshot.data![index];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.95,
                                      child: Column(
                                        children: [
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20,
                                                  right: 20,
                                                  top: 20,
                                                  bottom: 15),
                                              child: Text(
                                                "Q" +
                                                    (index + 1).toString() +
                                                    ". " +
                                                    datas.question
                                                        .toString()
                                                        .toUpperCase(),
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only(
                                                left: 40,
                                                right: 20,
                                                top: 5,
                                                bottom: 5),
                                            child: Text(
                                              "a. " + datas.option1,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only(
                                                left: 40,
                                                right: 20,
                                                top: 5,
                                                bottom: 5),
                                            child: Text(
                                              "b. " + datas.option2.toString(),
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15),
                                            ),
                                          ),

                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only(
                                                left: 40,
                                                right: 20,
                                                top: 5,
                                                bottom: 5),
                                            child: Text(
                                              "c. " + datas.option3,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: EdgeInsets.only(
                                                left: 40,
                                                right: 20,
                                                top: 5,
                                                bottom: 5),
                                            child: Text(
                                              "d. " + datas.option4,
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 15),
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
                                    ),
                                  );
                                },
                              );
                      }
                    }
                  },
                  future: getFormAssignment(),
                ),
              ),
      ],
    );
  }

  String description = "";
  int points = 0;
  String attachmentLink = "";

  Future<List<dynamic>> getFormAssignment() async {
    print("get form assignment");
    var token = await getValue("token");
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.get(
      url +
          '/getformassignment?assignment_id=' +
          assignmentData["assignment_id"].toString(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
    );
    var res = response1.body;
    if (response1.statusCode == 200) {
      var obj = json.decode(res);

      if (description != obj["description"].toString()) {
        setState(() {
          description = obj["description"].toString();
          points = int.parse(obj["points"].toString());
        });
      }

      var tagObjsJson = jsonDecode(res)['questions'] as List;
      print("list  = \n");
      // print(tagObjsJson);
      List<MyQuestion> tagObjs =
          tagObjsJson.map((tagJson) => MyQuestion.fromJson(tagJson)).toList();
      print("object is \n\n ");
      print(tagObjs.length);

      // print(tagObjs[0].question);
      return tagObjs;
    }
    var obj = json.decode(res);
    return Future.value(obj["error"]);
  }

  Future<List> getFileAssignment() async {
    print("get file assignment");
    var token = await getValue("token");
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.get(
      url +
          '/getfileassignment?assignment_id=' +
          assignmentData["assignment_id"].toString(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
    );
    var res = response1.body;
    var obj = json.decode(res);
    if (response1.statusCode == 200) {
      if (description != obj["description"].toString()) {
        setState(() {
          description = obj["description"].toString();
          points = int.parse(obj["points"].toString());
          attachmentLink = obj["attachment_link"].toString();
        });
      }
    }
    return obj["attachment_link"];
  }
}
