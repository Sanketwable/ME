import 'dart:io';

import 'package:flutter/material.dart';
import 'package:study/components/rounded_input_field.dart';
import 'package:study/constants/constants.dart';
import 'package:study/controllers/token.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';
import 'package:study/models/question_model.dart';
import 'dart:convert';

// ignore: prefer_typing_uninitialized_variables
var assignmentData;

class StudentAssignment extends StatefulWidget {
  StudentAssignment(data, {Key? key}) : super(key: key) {
    assignmentData = data;
  }
  // const StudentAssignment({Key? key}) : super(key: key);

  @override
  _StudentAssignmentState createState() => _StudentAssignmentState();
}

class _StudentAssignmentState extends State<StudentAssignment> {
  bool submit = true;
  int totalQuestions = 0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text("Student"),
        ),
        body: assignmentBody(),
      ),
    );
  }

  Widget assignmentBody() {
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
                    "Due : " +
                        assignmentData["due"].toString().substring(0, 10),
                    style: const TextStyle(color: Colors.black, fontSize: 18),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(left: 15, bottom: 10),
                  child: Text(
                    assignmentData["name"].toString().toUpperCase(),
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
          padding: const EdgeInsets.all(12),
          child: Container(
            alignment: Alignment.centerLeft,
            child: Text("Description : " + description),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text("Points : " + points.toString()),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: assignmentData["assignment_type"] != 0
                      ? (submitted
                          ? Text("score : " + score.toString())
                          : const SizedBox.shrink())
                      : (submitted
                          ? Text("Submission Link : " + score.toString())
                          : const SizedBox.shrink()),
                ),
              ),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                    decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(40)),
                    child: TextButton(
                        onPressed: () async {
                          if (submitted) {
                          } else {
                            if (assignmentData["assignment_type"] == 0) {
                              var alert =
                                  showAlertDialog(context, "Submitting");
                              if (await submitFileAssignment(
                                      assignmentData["assignment_id"]) ==
                                  "submitted") {
                                Navigator.pop(alert);

                                setState(() {
                                  submitted = true;
                                });
                              }
                            } else {
                              var alert =
                                  showAlertDialog(context, "Submitting");
                              if (await submitFormAssignment(
                                      assignmentData["assignment_id"]) ==
                                  "submitted") {
                                Navigator.pop(alert);

                                setState(() {
                                  submitted = true;
                                });
                              }
                            }
                          }
                        },
                        child: Text(
                          submitted ? "Submitted" : "Submit",
                          style: const TextStyle(color: Colors.white),
                        ))),
              )),
            ],
          ),
        ),
        assignmentData["assignment_type"] == 0
            ? FutureBuilder(
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.width * 0.40),
                      child: Center(
                        child: Column(
                          children: const [
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: CircularProgressIndicator(),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            alignment: Alignment.centerLeft,
                            child: Text("Attachment Link : " + attachmentLink),
                          ),
                        ),
                        RoundedInputField(
                          icon: Icons.link,
                          textController: submissionLinkControlller,
                          onChanged: (str) {},
                          hintText: "Submission Link",
                        )
                      ],
                    );
                  }
                },
                future: getFileAssignment(),
              )
            : Expanded(
                flex: 9,
                child: FutureBuilder(
                  builder: (context, AsyncSnapshot<List> snapshot) {
                    if (questions.isEmpty &&
                        snapshot.connectionState == ConnectionState.waiting) {
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
                        return questions.isEmpty
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
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: SizedBox(
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
                                                    questions[index]
                                                        .question
                                                        .toString()
                                                        .toUpperCase(),
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 18),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.only(
                                                left: 40,
                                                right: 20,
                                                top: 1,
                                                bottom: 1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                    value: answers[index],
                                                    groupValue: 1,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        value = 1;
                                                        answers[index] = 1;
                                                      });
                                                    }),
                                                Text(
                                                  "a. " +
                                                      questions[index].option1,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.only(
                                                left: 40,
                                                right: 20,
                                                top: 1,
                                                bottom: 1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                    value: answers[index],
                                                    groupValue: 2,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        answers[index] = 2;
                                                      });
                                                    }),
                                                Text(
                                                  "b. " +
                                                      questions[index]
                                                          .option2
                                                          .toString(),
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.only(
                                                left: 40,
                                                right: 20,
                                                top: 1,
                                                bottom: 1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                    value: answers[index],
                                                    groupValue: 3,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        answers[index] = 3;
                                                      });
                                                    }),
                                                Text(
                                                  "c. " +
                                                      questions[index].option3,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            alignment: Alignment.centerLeft,
                                            padding: const EdgeInsets.only(
                                                left: 40,
                                                right: 20,
                                                top: 1,
                                                bottom: 1),
                                            child: Row(
                                              children: [
                                                Radio(
                                                    value: answers[index],
                                                    groupValue: 4,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        answers[index] = 4;
                                                      });
                                                    }),
                                                Text(
                                                  "d. " +
                                                      questions[index].option4,
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15),
                                                ),
                                              ],
                                            ),
                                          ),
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

  BuildContext showAlertDialog(BuildContext context, String lodingText) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          const CircularProgressIndicator(),
          Container(
              margin: const EdgeInsets.only(left: 5), child: Text(lodingText)),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return context;
  }

  List<int> answers = [];
  List<MyQuestion> questions = [];
  bool questionsLoaded = false;

  String description = "";
  int points = 0;
  TextEditingController submissionLinkControlller = TextEditingController();
  String score = "";
  bool submitted = false;

  String attachmentLink = "";
  Future<dynamic> submitFileAssignment(int assignmentId) async {
    var token = await getValue("token");
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.post(
      url + '/submitassignment',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
      body: jsonEncode(<String, dynamic>{
        'assignment_id': int.parse(assignmentId.toString()),
        'points': submissionLinkControlller.text.toString(),
      }),
    );

    if (response1.statusCode == 200) {
      submitted = true;
      return Future.value("submitted");
    }

    return Future.value("Error");
  }

  Future<dynamic> submitFormAssignment(int assignmentId) async {
    int pts = 0;
    for (int i = 0; i < questions.length; i++) {
      if (answers[i] == questions[i].answer) {
        pts++;
      }
    }
    var token = await getValue("token");
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.post(
      url + '/submitassignment',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
      body: jsonEncode(<String, dynamic>{
        'assignment_id': int.parse(assignmentId.toString()),
        'points': pts.toString(),
      }),
    );

    if (response1.statusCode == 200) {
      submitted = true;
      return Future.value("submitted");
    }

    return Future.value("Error");
  }

  Future getAssignmentStatus() async {
    var token = await getValue("token");
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.get(
      url +
          '/getassignmentstatus?assignment_id=' +
          assignmentData["assignment_id"].toString(),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
    );
    var res = response1.body;
    if (response1.statusCode == 200) {
      
      var obj = json.decode(res);
      setState(() {
        submitted = true;
        score = obj["points"].toString();
        
      });
    }
  }

  Future<List<dynamic>> getFormAssignment() async {
    if (questionsLoaded == true) {
      
      return questions;
    }
    getAssignmentStatus();
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

      // print(tagObjsJson);
      questions =
          tagObjsJson.map((tagJson) => MyQuestion.fromJson(tagJson)).toList();
      
      // print(tagObjs[0].question);
      totalQuestions = questions.length;
      if (questionsLoaded == false) {
        
        answers.clear();
        for (int i = 0; i < totalQuestions; i++) {
          answers.add(-1);
        }
        questionsLoaded = true;
      }

      return questions;
    }
    var obj = json.decode(res);
    return Future.value(obj["error"]);
  }

  Future getFileAssignment() async {
    if (attachmentLink != "") {
      return attachmentLink;
    }
    getAssignmentStatus();
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
