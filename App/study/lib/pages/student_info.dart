import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';
import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:study/constants/constants.dart';
import 'package:study/controllers/token.dart';
import 'package:study/pages/student_home_page.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:image_picker/image_picker.dart';

final firstNameController = TextEditingController();
final lastNameController = TextEditingController();
final phoneNoController = TextEditingController();

// ignore: prefer_typing_uninitialized_variables
var year;
var userName = "";
var token = "";

class StudentInfo extends StatefulWidget {
  StudentInfo(String username, String token, {Key? key}) : super(key: key) {
    userName = username;
    token = token;
  }

  @override
  _StudentInfoState createState() => _StudentInfoState();
}

class _StudentInfoState extends State<StudentInfo> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Student"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.only(top: 30.0, bottom: 10.0),
                  child: Text(
                    "congrats " + userName + " your accout is created ",
                    style: const TextStyle(color: Colors.blue, fontSize: 10),
                  )),
              Padding(
                padding: const EdgeInsets.only(top: 40.0, bottom: 40.0),
                child: Center(
                    child: Text(
                  "    Hi " + userName + "\nEnter your basic Info ",
                  style: const TextStyle(color: Colors.grey, fontSize: 20),
                )),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    _showPicker(context);
                  },
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: const Color(0xffFDCF09),
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
                                borderRadius: BorderRadius.circular(50)),
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
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: TextField(
                  controller: firstNameController,
                  obscureText: false,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'First Name',
                      hintText: 'Enter your First Name'),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: TextField(
                  controller: lastNameController,
                  obscureText: false,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Last Name',
                      hintText: 'Enter your Last Name'),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: TextField(
                  controller: phoneNoController,
                  obscureText: false,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Phone No',
                      hintText: 'Enter your Phone'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                child: Center(
                    child: Text(
                  "Year",
                  style: TextStyle(fontSize: 24),
                )),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 5, bottom: 0),
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  margin: const EdgeInsets.all(20),
                  child: DropdownButtonHideUnderline(
                    child: GFDropdown(
                      padding: const EdgeInsets.all(15),
                      borderRadius: BorderRadius.circular(10),
                      border: const BorderSide(color: Colors.black12, width: 1),
                      dropdownButtonColor: Colors.grey[300],
                      value: year,
                      hint: const Text("Year"),
                      onChanged: (newValue) {
                        setState(() {
                          year = newValue;
                        });
                      },
                      items: ['1', '2', '3', '4', '5']
                          .map((value) => DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              ))
                          .toList(),
                    ),
                  ),
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
                    showAlertDialog(context, "Submitting");
                    if (await submitBasicInfo() == "Submitted") {
                      setState(() {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => StudentHomePage(userName)),
                            ModalRoute.withName("/Home"));
                      });
                    } else {
                      setState(() {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => StudentInfo(userName, token)),
                            ModalRoute.withName("/Home"));
                      });
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

  showAlertDialog(BuildContext context, String lodingText) {
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

  Future<String> submitBasicInfo() async {
    var imageLink = await uploadImage();
    var token = await getValue("token");
    storeProfileURL(imageLink);

    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.post(
      url + '/studentinfo',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
      body: jsonEncode(<String, dynamic>{
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'phone_no': phoneNoController.text,
        'year': int.parse(year.toString()),
        'profile_photo': imageLink.toString(),
      }),
    );

    if (response1.statusCode == 201) {
      return Future.value("Submitted");
    }

    return Future.value("Error");
  }
}
