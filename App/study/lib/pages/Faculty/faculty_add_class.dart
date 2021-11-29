import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/components/rounded_button.dart';
import 'package:study/components/rounded_input_field.dart';
import 'package:study/constants/constants.dart';
import 'package:study/controllers/token.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';

import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;

class AddClass extends StatefulWidget {
  const AddClass({Key? key}) : super(key: key);

  @override
  _AddClassState createState() => _AddClassState();
}

class _AddClassState extends State<AddClass> {
  String addClassError = "";
  var detailsSubmitted = false;
  var classDetailsError = "";
  var branchController = TextEditingController();
  var subjectController = TextEditingController();
  var classLinkController = TextEditingController();
  var imageLinkController = TextEditingController();
  var yearController = TextEditingController();
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
          child: detailsSubmitted
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
                            ? const Text("")
                            : Text(
                                classDetailsError,
                                style: const TextStyle(color: Colors.red),
                              ),
                        const Padding(
                            padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
                            child: Text(
                              "Enter class details",
                              style:
                                  TextStyle(color: kPrimaryColor, fontSize: 10),
                            )),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                _showPicker(context);
                              },
                              child: CircleAvatar(
                                radius: 51,
                                backgroundColor: kPrimaryColor,
                                child: _image != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.file(
                                          File(_image.path),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.fitHeight,
                                        ),
                                      )
                                    : Container(
                                        decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        width: 100,
                                        height: 100,
                                        child: Icon(
                                          Icons.camera_alt,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        addClassError != ""
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    top: 8, left: 8, right: 8),
                                child: Text(
                                  "*" + addClassError,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 11),
                                ),
                              )
                            : const SizedBox.shrink(),
                        RoundedInputField(
                          hintText: 'Branch',
                          textController: branchController,
                          onChanged: (str) {},
                          icon: Icons.auto_stories_rounded,
                        ),
                        RoundedInputField(
                            hintText: 'Subject',
                            textController: subjectController,
                            onChanged: (str) {},
                            icon: Icons.subject),
                        RoundedInputField(
                          hintText: 'Class Link',
                          textController: classLinkController,
                          onChanged: (str) {},
                          icon: Icons.link,
                        ),
                        RoundedInputField(
                          hintText: 'year',
                          textController: yearController,
                          onChanged: (str) {},
                          icon: Icons.calendar_today_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatter: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                          ],
                        ),
                        RoundedButton(
                          text: 'Submit',
                          press: () async {
                            var ctx = showAlertDialog(context, "submitting");
                            var response = await addClassRequest();
                            if (response == "error") {
                              setState(() {
                                detailsSubmitted = false;
                              });
                              // addClassError = "";
                              Navigator.pop(ctx);
                            } else {
                              _image = null;
                              setState(() {
                                detailsSubmitted = false;
                                addClassError = "";
                                imageLinkController.clear();
                                branchController.clear();
                                classLinkController.clear();
                                subjectController.clear();
                                yearController.clear();
                              });
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                            }
                          },
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

  Future<String> addClassRequest() async {
    if (branchController.text == "") {
      addClassError = "branch cannot be empty";
      return Future.value("error");
    } else if (subjectController.text == "") {
      addClassError = "subject cannot be empty";
      return Future.value("error");
    } else if (classLinkController.text == "") {
      addClassError = "class link cannot be empty";
      return Future.value("error");
    } else if (yearController.text == "") {
      addClassError = "year cannot be empty";
      return Future.value("error");
    }
    var imageLink = await uploadImage();
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
        'image_link': imageLink,
      }),
    );

    var res = response1.body;
    // print(res);

    if (response1.statusCode == 200) {
      var obj = json.decode(res);

      return obj.toString();
    }
    var obj = json.decode(res);
    addClassError = obj['error'];
    return Future.value("error");
  }

  Future uploadImage() async {
    var uri =
        Uri.parse(imageUploadUrl + "?key=7c2ac71fd6246e5730c7c0cb22c0a654");
    var request = http.MultipartRequest('POST', uri);

    request.files.add(await http.MultipartFile.fromPath('image', _image.path));
    final response = (await request.send());
    final respStr = await response.stream.bytesToString();

    var obj = json.decode(respStr);
    if (response.statusCode == 200) {
      return obj["data"]["image"]["url"];
    }
    return "no image";
  }

  _imgFromCamera() async {
    PickedFile image = await ImagePicker()
        .getImage(source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  _imgFromGallery() async {
    PickedFile image = await ImagePicker()
        .getImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  // ignore: prefer_typing_uninitialized_variables
  var _image;
  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Photo Library'),
                    onTap: () {
                      _imgFromGallery();
                      Navigator.of(context).pop();
                    }),
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Camera'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          );
        });
  }
}
