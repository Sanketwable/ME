import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/components/rounded_button.dart';
import 'package:study/components/rounded_input_field.dart';
import 'package:study/constants/constants.dart';
import 'package:study/controllers/token.dart';
import 'package:study/models/class_model.dart';
import 'package:study/pages/Faculty/faculty_add_class.dart';
import 'package:study/pages/Faculty/faculty_class.dart';

import 'package:study/pages/redirect_page.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';

import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;

var facultyUsername = "";
List<MyClasses> facultyClasses = [];

class FacultyHomePage extends StatefulWidget {
  FacultyHomePage(String username, {Key? key}) : super(key: key) {
    facultyUsername = username;
  }
  @override
  _FacultyHomePageState createState() => _FacultyHomePageState();
}

class _FacultyHomePageState extends State<FacultyHomePage> {
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
        ),
        floatingActionButton: _selectedPage != 0
            ? const SizedBox.shrink()
            : Container(
                padding: const EdgeInsets.all(20),
                child: FittedBox(
                  child: FloatingActionButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const AddClass()));
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
          title: const Text('Faculty'),
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
                      future: getProfilePhoto(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(facultyUsername,
                          style: const TextStyle(color: Colors.white)),
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
        body: _selectedPage == 0 ? classesPage() : mePage(),
      ),
    );
  }

  Future getProfilePhoto() async {
    // ignore: unused_local_variable
    var a = await getInfo();
    return await getProfilePhotoURL();
  }

  var edit = false;
  var updateError = "";
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  var phoneNoController = TextEditingController();
  var experienceController = TextEditingController();
  var degreeController = TextEditingController();
  var passoutYearController = TextEditingController();
  var profilePhoto = "";
  Widget mePage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: FutureBuilder(
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
                experienceController.text = "";
                degreeController.text = "";
                passoutYearController.text = "";
              } else {
                firstNameController.text = data["first_name"];
                lastNameController.text = data["last_name"];
                phoneNoController.text = data["phone_no"];
                profilePhoto = data["profile_photo"];
                experienceController.text = data["experience"].toString();
                degreeController.text = data["qualification"]["degree"];
                passoutYearController.text =
                    data["qualification"]["passout_year"].toString();
                // yearController..text = data["year"].toString();
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
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Image.file(
                                            File(_image.path),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Image.network(
                                            profilePhoto,
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, obj, st) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.grey[200],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50)),
                                                width: 100,
                                                height: 100,
                                                color: kPrimaryLightColor,
                                                child: const Icon(
                                                  Icons.person,
                                                  color: kPrimaryColor,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                )
                              : CircleAvatar(
                                  radius: 51,
                                  backgroundColor: kPrimaryLightColor,
                                  child: (profilePhoto != ""
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Image.network(
                                            profilePhoto,
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, obj, st) {
                                              return Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.grey[200],
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
                                          ))
                                      : Container(
                                          decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(50)),
                                          width: 100,
                                          height: 100,
                                          color: kPrimaryLightColor,
                                          child: const Icon(
                                            Icons.person,
                                            color: kPrimaryColor,
                                          ),
                                        )),
                                ),
                        ),
                      ),
                    ),
                    updateError == ""
                        ? const SizedBox.shrink()
                        : Text(updateError,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 11)),
                    RoundedInputField(
                      hintText: 'First Name',
                      onChanged: (str) {},
                      textController: firstNameController,
                      readOnly: !edit,
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 15, vertical: 8),
                    //   child: TextField(
                    //     controller: firstNameController,
                    //     obscureText: false,
                    //     readOnly: !edit,
                    //     decoration: const InputDecoration(
                    //         border: OutlineInputBorder(),
                    //         labelText: 'First Name',
                    //         hintText: 'Enter your First Name'),
                    //   ),
                    // ),
                    RoundedInputField(
                      hintText: 'Last Name',
                      onChanged: (str) {},
                      textController: lastNameController,
                      readOnly: !edit,
                    ),

                    RoundedInputField(
                      hintText: 'Phone No',
                      onChanged: (str) {},
                      textController: phoneNoController,
                      readOnly: !edit,
                      keyboardType: TextInputType.number,
                      inputFormatter: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      icon: Icons.phone,
                    ),

                    RoundedInputField(
                        hintText: 'Experience',
                        onChanged: (str) {},
                        textController: experienceController,
                        readOnly: !edit,
                        keyboardType: TextInputType.number,
                        inputFormatter: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        icon: Icons.date_range),

                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: Text("Qualification")),
                    ),
                    RoundedInputField(
                        hintText: 'Degree',
                        onChanged: (str) {},
                        textController: degreeController,
                        readOnly: !edit,
                        icon: Icons.book),

                    RoundedInputField(
                      hintText: 'Passout Year',
                      onChanged: (str) {},
                      textController: passoutYearController,
                      readOnly: !edit,
                      keyboardType: TextInputType.number,
                      inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                      icon: Icons.calendar_today,
                    ),

                    RoundedButton(
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
                            experienceController.clear();
                            _image = null;
                            degreeController.clear();
                            passoutYearController.clear();
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
                      text: edit ? 'Submit' : 'Edit',
                    ),

                    // Container(
                    //   // height: 50,
                    //   // width: 250,
                    //   padding: const EdgeInsets.all(8),
                    //   decoration: BoxDecoration(
                    //       color: Colors.blue,
                    //       borderRadius: BorderRadius.circular(20)),
                    //   child: TextButton(
                    //       onPressed: () async {
                    //         if (edit == false) {
                    //           setState(() {
                    //             edit = !edit;
                    //           });
                    //         } else {
                    //           showAlertDialog(context, "Submitting");
                    //           // var message = await updateBacisInfo();
                    //           if (await updateBasicInfo() == "Submitted") {
                    //             firstNameController.clear();
                    //             lastNameController.clear();
                    //             phoneNoController.clear();
                    //             experienceController.clear();
                    //             _image = null;
                    //             degreeController.clear();
                    //             passoutYearController.clear();
                    //             updateError = "";
                    //             Navigator.pop(context);
                    //             setState(() {
                    //               edit = !edit;
                    //             });
                    //           } else {
                    //             Navigator.pop(context);
                    //             setState(() {
                    //               updateError = "error updating data";
                    //             });
                    //           }
                    //         }
                    //       },
                    //       child: edit
                    //           ? const Text(
                    //               'Submit',
                    //               style: TextStyle(
                    //                   color: Colors.white, fontSize: 18),
                    //             )
                    //           : const Text(
                    //               'Edit',
                    //               style: TextStyle(
                    //                   color: Colors.white, fontSize: 18),
                    //             )),
                    // ),
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
      ),
    );
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

  Future<String> updateBasicInfo() async {
    var imageLink = "";
    if (_image != null) {
      imageLink = await uploadImage();
      storeProfileURL(imageLink);
    } else {
      imageLink = await getProfilePhotoURL();
    }
    var token = await getValue("token");
    storeProfileURL(imageLink);

    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    final http.Response response1 = await http1.put(
      url + '/facultyinfo',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
      body: jsonEncode(<String, dynamic>{
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'phone_no': phoneNoController.text,
        'qualification': {
          'degree': degreeController.text,
          'passout_year': passoutYearController.text
        },
        'profile_photo': imageLink.toString(),
      }),
    );

    if (response1.statusCode == 201) {
      return Future.value("Submitted");
    }
    return Future.value("Error");
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

  Future<dynamic> getInfo() async {
    var token = await getValue("token");
    final ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http1 = IOClient(ioc);
    // ignore: prefer_typing_uninitialized_variables
    var res;
    int statusCode = 0;

    final http.Response response1 = await http1.get(
      url + '/facultyinfo',
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': "Bearer " + token,
      },
    );
    res = response1.body;
    statusCode = response1.statusCode;

    var obj = json.decode(res);
    if (statusCode == 200) {
      // ignore: unused_local_variable
      var a = storeProfileURL(obj["profile_photo"]);
      return obj;
    }
    List<int> l = [];
    return l;
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
                  if (facultyClasses.isEmpty &&
                      snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: MediaQuery.of(context).size.width * 0.40),
                      child: const Center(
                          child: Text('Please wait its loading...')),
                    );
                  }
                  return facultyClasses.isEmpty
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
                          itemCount: facultyClasses.length,
                          itemBuilder: (context, index) {
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
                                            builder: (_) => FacultyClass(
                                                facultyClasses[index])));
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
                                                    facultyClasses[index]
                                                        .imageLink)),
                                          ),
                                          const Spacer(),
                                          Column(
                                            children: [
                                              Container(
                                                alignment: Alignment.topLeft,
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Text(
                                                  facultyClasses[index]
                                                      .subject
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
                                                  facultyClasses[index].branch +
                                                      " " +
                                                      facultyClasses[index]
                                                          .year
                                                          .toString(),
                                                  style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  "Class code : " +
                                                      facultyClasses[index]
                                                          .classCode,
                                                  style: const TextStyle(
                                                      color: Colors.blueAccent,
                                                      fontSize: 12),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Text(
                                                  facultyClasses[index]
                                                          .classLink +
                                                      "\n",
                                                  style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 11),
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
            future: getfacultyClasses(),
          ),
        ),
      ],
    );
  }

  Future<List<dynamic>> getfacultyClasses() async {
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
      facultyClasses = classesObjsJson
          .map((tagJson) => MyClasses.fromJson(tagJson))
          .toList();

      return facultyClasses;
    }
    return Future.value(obj["error"]);
  }

  // ignore: prefer_typing_uninitialized_variables

  Widget messagesPage() {
    return Center(
        child: Container(
      child: const Text("Messages"),
      padding: const EdgeInsets.all(8),
    ));
  }
}

