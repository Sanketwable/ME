import 'dart:io';

import 'package:flutter/material.dart';
import 'package:study/components/rounded_input_field.dart';
import 'package:study/constants/constants.dart';
import 'package:study/controllers/token.dart';
import 'package:study/pages/faculty_class.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';
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
                    "Due : " + assignmentData["due"].toString(),
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
                padding: const EdgeInsets.all(10.0),
                child: Container(
                    decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(40)),
                    child: const TextButton(
                        onPressed: null,
                        child: Text(
                          "Submit",
                          style: TextStyle(color: Colors.white),
                        ))),
              )),
            ],
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
                          textController: TextEditingController(),
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

  List<int> answers = [];
  List<MyQuestion> questions = [];
  bool questionsLoaded = false;

  String description = "";
  int points = 0;
  int score = 0;
  bool submitted = false;

  String attachmentLink = "";

  Future<List<dynamic>> getFormAssignment() async {
    for (int i = 0; i < answers.length; i++) {
      print(answers[i]);
    }
    if (questionsLoaded == true) {
      print("questions already loaded");
      return questions;
    }
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
        print("questions loaded");
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

  Future<List> getFileAssignment() async {
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
