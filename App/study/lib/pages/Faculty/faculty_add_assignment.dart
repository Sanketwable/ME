import 'dart:ui';
import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:study/components/rounded_button.dart';
import 'package:study/components/rounded_input_field.dart';
import 'package:study/constants/constants.dart';
import 'package:study/controllers/token.dart';
import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;

import 'package:getwidget/getwidget.dart';
import 'package:study/models/class_model.dart';
import 'package:study/models/my_vector_model.dart';
import 'package:study/models/question_model.dart';

// ignore: must_be_immutable
class MyDialog extends StatefulWidget {
  Function callback;
  // ignore: prefer_typing_uninitialized_variables
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
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
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
                              style:
                                  TextStyle(color: kPrimaryColor, fontSize: 10),
                            )),
                        RoundedInputField(
                          hintText: 'Assignment Name',
                          onChanged: (str) {},
                          textController: assignmentNameController,
                          icon: Icons.assignment,
                        ),
                        RoundedInputField(
                          hintText: 'Description',
                          onChanged: (str) {},
                          textController: descriptionController,
                          icon: Icons.description,
                        ),
                        RoundedInputField(
                          hintText: 'Points',
                          onChanged: (str) {},
                          textController: pointsController,
                          icon: Icons.poll_rounded,
                          keyboardType: TextInputType.number,
                          inputFormatter: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Container(
                            height: 50,
                            // width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.all(20),
                            // color:kPrimaryLightColor,
                            child: DropdownButtonHideUnderline(
                              child: GFDropdown(
                                padding: const EdgeInsets.all(10),
                                borderRadius: BorderRadius.circular(40),
                                border: const BorderSide(
                                    color: Colors.black12, width: 1),
                                dropdownButtonColor: kPrimaryLightColor,
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
                                          child: Container(
                                              padding: const EdgeInsets.all(5),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    value == 'Form'
                                                        ? Icons
                                                            .format_align_justify_outlined
                                                        : Icons
                                                            .file_present_sharp,
                                                    color: kPrimaryColor,
                                                  ),
                                                  Text(" " + value),
                                                ],
                                              )),
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
                                          child: const Text(
                                            "add",
                                            style:
                                                TextStyle(color: kPrimaryColor),
                                          )),
                                    ),
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.41,
                                    width: MediaQuery.of(context).size.width *
                                        0.70,
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
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 5,
                                                                vertical: 1),
                                                        child: TextField(
                                                          selectionHeightStyle:
                                                              BoxHeightStyle
                                                                  .tight,
                                                          style:
                                                              const TextStyle(
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
                                                                    maxHeight:
                                                                        50,
                                                                    minHeight:
                                                                        40,
                                                                  ),
                                                                  // labelText:
                                                                  //     'Question',
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
                                                  style:
                                                      TextStyle(fontSize: 11),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 2),
                                                    child: Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 5,
                                                                vertical: 1),
                                                        child: TextField(
                                                          selectionHeightStyle:
                                                              BoxHeightStyle
                                                                  .tight,
                                                          style:
                                                              const TextStyle(
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
                                                                    maxHeight:
                                                                        40,
                                                                    minHeight:
                                                                        30,
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
                                                  style:
                                                      TextStyle(fontSize: 11),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 2),
                                                    child: Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 5,
                                                                vertical: 1),
                                                        child: TextField(
                                                          selectionHeightStyle:
                                                              BoxHeightStyle
                                                                  .tight,
                                                          style:
                                                              const TextStyle(
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
                                                                    maxHeight:
                                                                        40,
                                                                    minHeight:
                                                                        30,
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
                                                  style:
                                                      TextStyle(fontSize: 11),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 2),
                                                    child: Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 5,
                                                                vertical: 1),
                                                        child: TextField(
                                                          selectionHeightStyle:
                                                              BoxHeightStyle
                                                                  .tight,
                                                          style:
                                                              const TextStyle(
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
                                                                    maxHeight:
                                                                        40,
                                                                    minHeight:
                                                                        30,
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
                                                  style:
                                                      TextStyle(fontSize: 11),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 2),
                                                    child: Center(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 5,
                                                                vertical: 1),
                                                        child: TextField(
                                                          selectionHeightStyle:
                                                              BoxHeightStyle
                                                                  .tight,
                                                          style:
                                                              const TextStyle(
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
                                                                    maxHeight:
                                                                        40,
                                                                    minHeight:
                                                                        30,
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
                                                        padding:
                                                            const EdgeInsets
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
                                                          style:
                                                              const TextStyle(
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
                                                                    maxHeight:
                                                                        40,
                                                                    minHeight:
                                                                        30,
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
                                ? RoundedInputField(
                                    hintText: 'Attachment Link',
                                    onChanged: (str) {},
                                    textController: attachmentLinkController,
                                    icon: Icons.link,
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
                          child: SizedBox(
                            height: 55,
                            width: double.maxFinite,
                            child: CupertinoTheme(
                              data: const CupertinoThemeData(
                                textTheme: CupertinoTextThemeData(
                                  primaryColor: kPrimaryLightColor,
                                  dateTimePickerTextStyle: TextStyle(
                                      fontSize: 15, color: kPrimaryColor),
                                ),
                                brightness: Brightness.light,
                              ),
                              child: CupertinoDatePicker(
                                // backgroundColor: kPrimaryLightColor,
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
                          padding: const EdgeInsets.all(8.0),
                          child: RoundedButton(
                            text: "Submit",
                            press: () async {
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
          int.parse(questionOptions[i].answer.text),
        );

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
