import 'package:flutter/material.dart';
import 'package:study/components/rounded_button.dart';
import 'package:study/components/rounded_input_field.dart';
import 'package:study/constants/constants.dart';
import 'package:study/controllers/token.dart';
import 'package:study/models/class_model.dart';
import 'package:study/pages/Student/student_class.dart';
import 'package:study/pages/redirect_page.dart';
import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';
import 'dart:convert';

// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;

// ignore: import_of_legacy_library_into_null_safe
import 'package:image_picker/image_picker.dart';

import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

var studentUserName = "";
List<MyClasses> classes = [];
var classCodeController = TextEditingController();
var codeSubmitted = false;
var codeError = "";

var firstNameController = TextEditingController();
var lastNameController = TextEditingController();
var phoneNoController = TextEditingController();
var yearController = TextEditingController();
var profilePhoto = "";
var updateError = "";
// ignore: prefer_typing_uninitialized_variables
var year;
var edit = false;
// ignore: prefer_typing_uninitialized_variables
var _image;

class StudentHomePage extends StatefulWidget {
  StudentHomePage(String username, {Key? key}) : super(key: key) {
    studentUserName = username;
  }
  @override
  _StudentHomePageState createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
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
    getInfo();
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          selectedFontSize: 15,
          selectedIconTheme: const IconThemeData(color: kPrimaryColor),
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Classes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_box),
              label: 'Me',
            ),
          ],
          currentIndex: _selectedPage,
          selectedItemColor: kPrimaryColor,
          onTap: (index) {
            _onItemTapped(index);
          },
        ), // This trailing comma makes auto-formatting nicer for build methods.
        floatingActionButton: _selectedPage != 0
            ? const SizedBox.shrink()
            : Container(
                padding: const EdgeInsets.all(20),
                child: FittedBox(
                  child: FloatingActionButton(
                    onPressed: () {
                      addClassCode(context);
                    },
                    backgroundColor: kPrimaryColor,
                    child: const Icon(Icons.add),
                    isExtended: true,
                    autofocus: true,
                  ),
                ),
              ),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        appBar: AppBar(
          backgroundColor: kPrimaryColor,
          title: const Text('Student'),
          actions: [
            TextButton(
              onPressed: () {
                _onItemTapped(1);
              },
              child: Container(
                padding: const EdgeInsets.only(
                    top: 1, bottom: 1, right: 12, left: 8),
                child: FutureBuilder(
                  builder: (context, data) {
                    return CircleAvatar(
                        backgroundColor: kPrimaryColor,
                        radius: 20,
                        onBackgroundImageError: (object, stackTrace) => {},
                        backgroundImage: NetworkImage(data.data.toString()));
                  },
                  future: getProfilePhoto(),
                ),
              ),
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: kPrimaryColor,
                ),
                child: Column(
                  children: [
                    FutureBuilder(
                      builder: (context, data) {
                        return CircleAvatar(
                            radius: 35,
                            backgroundColor: kPrimaryColor,
                            onBackgroundImageError: (object, stackTrace) => {},
                            backgroundImage:
                                NetworkImage(data.data.toString()));
                      },
                      future: getProfilePhotoURL(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        studentUserName,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Expanded(
                      flex: 1,
                      child: IconButton(
                          onPressed: null, icon: Icon(Icons.logout))),
                  Expanded(
                    flex: 9,
                    child: ListTile(
                      title: const Text('Sign Out'),
                      subtitle: const Text("Logout from Study App"),
                      onTap: () {
                        delete();
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const Redirect()),
                            ModalRoute.withName("/Home"));
                      },
                    ),
                  ),
                  const Expanded(flex: 1, child: SizedBox.shrink()),
                ],
              ),
            ],
          ),
        ),
        body: Container(child: _buildChild(_selectedPage)),
      ),
    );
  }

  Widget _buildChild(int index) {
    switch (index) {
      case 0:
        return classesPage();
      case 1:
        return me();
      default:
        return const Center(
          child: Text("default"),
        );
    }
  }

  Widget me() {
    return FutureBuilder(
      builder: (context, AsyncSnapshot<dynamic> snapshot) {
        var data = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Padding(
            padding: EdgeInsets.symmetric(
                vertical: MediaQuery.of(context).size.width * 0.40),
            child: const Center(child: Text('Please wait its loading...')),
          );
        } else {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            if (snapshot.data!.isEmpty) {
              firstNameController.text = "";
              lastNameController.text = "";
              phoneNoController.text = "";
              yearController.text = "";
            } else {
              firstNameController.text = data["first_name"];
              lastNameController.text = data["last_name"];
              phoneNoController.text = data["phone_no"];
              yearController.text = data["year"].toString();
              profilePhoto = data["profile_photo"];
            }

            return SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        if (edit) {
                          _showPicker(context);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: edit
                            ? CircleAvatar(
                                radius: 51,
                                // backgroundColor: kPrimaryLightColor,
                                child: _image != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.file(
                                          File(_image.path),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.network(
                                          profilePhoto,
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, obj, st) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                  color: kPrimaryLightColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              width: 100,
                                              height: 100,
                                              child: Icon(
                                                Icons.person,
                                                color: Colors.grey[800],
                                              ),
                                            );
                                          },
                                        )))
                            : CircleAvatar(
                                radius: 51,
                                backgroundColor: kPrimaryLightColor,
                                child: (profilePhoto != ""
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.network(
                                          profilePhoto,
                                          height: 100,
                                          width: 100,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, obj, st) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                  color: kPrimaryLightColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          50)),
                                              width: 100,
                                              height: 100,
                                              child: const Icon(
                                                Icons.person,
                                                color: kPrimaryLightColor,
                                              ),
                                            );
                                          },
                                        ))
                                    : Container(
                                        decoration: BoxDecoration(
                                            color: kPrimaryLightColor,
                                            borderRadius:
                                                BorderRadius.circular(50)),
                                        width: 100,
                                        height: 100,
                                        child: const Icon(
                                          Icons.person,
                                          color: kPrimaryLightColor,
                                        ),
                                      )),
                              ),
                      ),
                    ),
                  ),
                  updateError == ""
                      ? const SizedBox.shrink()
                      : Text(updateError,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 11)),
                  RoundedInputField(
                    hintText: "First Name",
                    onChanged: (str) {},
                    textController: firstNameController,
                    readOnly: !edit,
                  ),
                  RoundedInputField(
                    hintText: "Last Name",
                    onChanged: (str) {},
                    textController: lastNameController,
                    readOnly: !edit,
                  ),
                  RoundedInputField(
                    hintText: "Phone No",
                    onChanged: (str) {},
                    textController: phoneNoController,
                    keyboardType: TextInputType.number,
                    inputFormatter: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    readOnly: !edit,
                    icon: Icons.phone,
                  ),
                  RoundedInputField(
                    hintText: "Year",
                    onChanged: (str) {},
                    keyboardType: TextInputType.number,
                    inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                    textController: yearController,
                    readOnly: !edit,
                    icon: Icons.calendar_today,
                  ),
                  RoundedButton(
                    text: edit ? 'Submit' : 'Edit',
                    press: () async {
                      if (edit == false) {
                        setState(() {
                          edit = !edit;
                        });
                      } else {
                        showAlertDialog(context, "Submitting");
                        // var message = await updateBacisInfo();
                        if (await updateBasicInfo() == "Submitted") {
                          firstNameController.clear();
                          lastNameController.clear();
                          phoneNoController.clear();
                          yearController.clear();
                          _image = null;

                          updateError = "";
                          Navigator.pop(context);
                          setState(() {
                            edit = !edit;
                          });
                        } else {
                          Navigator.pop(context);
                          setState(() {
                            updateError = "error updating data";
                          });
                        }
                      }
                    },
                  ),
                  const SizedBox(
                    height: 90,
                  ),
                ],
              ),
            );
          }
        }
      },
      future: getInfo(),
    );
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
            color: kPrimaryLightColor,
            child: SafeArea(
              child: Wrap(
                children: <Widget>[
                  ListTile(
                      leading:
                          const Icon(Icons.photo_library, color: kPrimaryColor),
                      title: const Text(
                        'Photo Library',
                      ),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  ListTile(
                    leading:
                        const Icon(Icons.photo_camera, color: kPrimaryColor),
                    title: const Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  BuildContext addClassCode(BuildContext context) {
    AlertDialog alert = AlertDialog(
      elevation: 5.0,
      content: SizedBox(
        height: MediaQuery.of(context).size.width * 0.40,
        width: MediaQuery.of(context).size.width * 0.80,
        child: codeSubmitted
            ? Center(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                    height: MediaQuery.of(context).size.width * 0.1,
                    child: const CircularProgressIndicator()))
            : Column(
                children: [
                  codeError == ""
                      ? const Text("")
                      : Text(
                          codeError,
                          style: const TextStyle(color: Colors.red),
                        ),
                  SizedBox(
                    child: RoundedInputField(
                      textController: classCodeController,
                      hintText: 'Enter class code',
                      onChanged: (str) {},
                      icon: Icons.code,
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: TextButton(
                          onPressed: () async {
                            codeSubmitted = true;
                            var ctx = addClassCode(context);
                            var response = await addClassRequest();
                            if (response == "error") {
                              codeSubmitted = false;
                              Navigator.pop(ctx);
                              Navigator.pop(context);

                              addClassCode(context);
                              codeError = "";
                            } else {
                              setState(() {
                                codeSubmitted = false;
                              });
                              Navigator.pop(ctx);
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            'Submit',
                            style:
                                TextStyle(color: kPrimaryColor, fontSize: 18),
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
                            style:
                                TextStyle(color: kPrimaryColor, fontSize: 18),
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

  Widget classesPage() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            "Classes",
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
                  if (classes.isEmpty &&
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.width * 0.40),
                      child: const Center(
                          child: Text('Please wait its loading...')),
                    );
                  }
                  return classes.isEmpty
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.width * 0.40),
                          child: const Center(
                              child:
                                  Text('You are not enrolled to any classes')),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: classes.length,
                          itemBuilder: (context, index) {
                            var datas = classes[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: 10, left: 10, right: 10),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.95,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      colorFilter: ColorFilter.mode(
                                          Colors.black.withOpacity(0.9),
                                          BlendMode.dstATop),
                                      image: const AssetImage(
                                          "assets/images/class.jpg"),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: kPrimaryLightColor,
                                        offset: Offset(
                                          5.0,
                                          5.0,
                                        ),
                                        blurRadius: 10.0,
                                        spreadRadius: 2.0,
                                      ), //BoxShadow
                                    ],
                                    border: Border.all(
                                        color: kPrimaryColor,
                                        width: 0.5,
                                        style: BorderStyle.none),
                                    color: kPrimaryColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                StudentClass(datas)));
                                  },
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            child: CircleAvatar(
                                                backgroundColor:
                                                    kPrimaryLightColor,
                                                radius: 45,
                                                backgroundImage: NetworkImage(
                                                    datas.imageLink)),
                                          ),
                                          const Spacer(),
                                          Column(
                                            children: [
                                              Container(
                                                alignment: Alignment.topLeft,
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Text(
                                                  datas.subject
                                                      .toString()
                                                      .toUpperCase(),
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 24,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  datas.branch +
                                                      " " +
                                                      datas.year.toString(),
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Class code : " +
                                                      datas.classCode,
                                                  style: const TextStyle(
                                                      color: Colors.blueAccent,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  datas.classLink + "\n",
                                                  style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                }
              }
            },
            future: getClasses(),
          ),
        ),
      ],
    );
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

  Future<String> updateBasicInfo() async {
    var imageLink = "";
    if (_image != null) {
      imageLink = await uploadImage();
      storeProfileURL(imageLink);
    } else {
      imageLink = await getProfilePhotoURL();
    }

    var token = await getValue("token");

    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.put(
      url + '/studentinfo',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
      body: jsonEncode(<String, dynamic>{
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'phone_no': phoneNoController.text,
        'profile_photo': imageLink.toString(),
        'year': int.parse(yearController.text),
      }),
    );

    if (response1.statusCode == 201) {
      return Future.value("Submitted");
    }

    return Future.value("Error");
  }

  Future<dynamic> getInfo() async {
    var token = await getValue("token");

    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);

    final http.Response response1 = await http1.get(
      url + '/studentinfo',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
    );
    var res = response1.body;
    var statusCode = response1.statusCode;

    var obj = json.decode(res);
    if (statusCode == 200) {
      // ignore: unused_local_variable
      var a = storeProfileURL(obj["profile_photo"]);
      return obj;
    }
    List<int> l = [];
    return l;
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
      var classesObjsJson = jsonDecode(res) as List;
      classes = classesObjsJson
          .map((tagJson) => MyClasses.fromJson(tagJson))
          .toList();

      return classes;
    }
    return Future.value(obj["error"]);
  }

  Future<String> addClassRequest() async {
    var token = await getValue("token");

    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.get(
      url + '/addclass?code=' + classCodeController.text,
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
    codeError = obj['error'];
    return Future.value("error");
  }

  Future getProfilePhoto() async {
    await getInfo();
    return await getProfilePhotoURL();
  }
}
