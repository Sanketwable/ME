import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:study/constants/constants.dart';
import 'package:study/controllers/token.dart';
import 'package:study/pages/faculty_class.dart';
import 'package:study/pages/redirect_page.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:image_picker/image_picker.dart';
import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:http/io_client.dart';

import 'dart:convert';
// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;
import 'package:study/pages/student_home_page.dart';

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
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Classes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message_sharp),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_box),
              label: 'Me',
            ),
          ],
          currentIndex: _selectedPage,
          selectedItemColor: Colors.blue[800],
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
                      addClass(context);
                    },
                    child: const Icon(Icons.add),
                    isExtended: true,
                    autofocus: true,
                  ),
                ),
              ),
        floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
        appBar: AppBar(
          title: const Text('Faculty'),
          actions: [
            Container(
              padding: EdgeInsets.only(top: 8, bottom: 8, right: 12, left: 8),
              child: FutureBuilder(
                builder: (context, data) {
                  return CircleAvatar(
                      radius: 20,
                      onBackgroundImageError: (object, stackTrace) => {},
                      backgroundImage: NetworkImage(data.data.toString()));
                },
                future: getProfilePhotoURL(),
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
                  color: Colors.blue,
                ),
                child: Column(
                  children: [
                    FutureBuilder(
                      builder: (context, data) {
                        return CircleAvatar(
                            radius: 35,
                            onBackgroundImageError: (object, stackTrace) => {},
                            backgroundImage:
                                NetworkImage(data.data.toString()));
                      },
                      future: getProfilePhotoURL(),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(facultyUsername),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: IconButton(
                          onPressed: null, icon: Icon(Icons.logout))),
                  Expanded(
                    flex: 9,
                    child: ListTile(
                      title: const Text('Sign Out'),
                      subtitle: Text("Logout from Study App"),
                      onTap: () {
                        delete();
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const Redirect()),
                            ModalRoute.withName("/Home"));
                      },
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Container(
                        child: SizedBox.shrink(),
                      )),
                ],
              ),
            ],
          ),
        ),
        body: _selectedPage == 0
            ? classesPage()
            : (_selectedPage == 1 ? messagesPage() : mePage()),
      ),
    );
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

          // var yearController = TextEditingController();

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
                                  backgroundColor: Colors.red,
                                  child: _image != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Image.file(
                                            File(_image.path),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.fitHeight,
                                          ),
                                        )
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Image.network(
                                            profilePhoto,
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.fitHeight,
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
                                          ),
                                        ),
                                )
                              : CircleAvatar(
                                  radius: 51,
                                  backgroundColor: Colors.blue,
                                  child: (profilePhoto != ""
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          child: Image.network(
                                            profilePhoto,
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.fitHeight,
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
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.grey[800],
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
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: TextField(
                        controller: firstNameController,
                        obscureText: false,
                        readOnly: !edit,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'First Name',
                            hintText: 'Enter your First Name'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: TextField(
                        controller: lastNameController,
                        obscureText: false,
                        readOnly: !edit,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Last Name',
                            hintText: 'Enter your Last Name'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: TextField(
                        controller: phoneNoController,
                        obscureText: false,
                        readOnly: !edit,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Phone No',
                            hintText: '+919372615111'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: TextField(
                        controller: experienceController,
                        obscureText: false,
                        readOnly: !edit,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Experience',
                            hintText: 'eg. 1, 2.5'),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: Center(child: Text("Qualification")),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: TextField(
                        controller: degreeController,
                        obscureText: false,
                        readOnly: !edit,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Degree',
                            hintText: 'eg. B.Tech'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: TextField(
                        controller: passoutYearController,
                        obscureText: false,
                        readOnly: !edit,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Passout Year',
                            hintText: 'eg. 2022'),
                      ),
                    ),
                    Container(
                      // height: 50,
                      // width: 250,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(20)),
                      child: TextButton(
                          onPressed: () async {
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
                          child: edit
                              ? const Text(
                                  'Submit',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                )
                              : const Text(
                                  'Edit',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                )),
                    ),
                    // const SizedBox(
                    //   height: 90,
                    // ),
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
      storeProfileURL(obj["profile_photo"]);
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
                                      image: NetworkImage(
                                        "https://i.ibb.co/2sqgCND/overhead-view-laptop-with-stationeries-study-text-white-background-23-2147875675-jpg.webp",
                                      ),
                                    ),
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
                                    color: Colors.white,
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
                                            padding: EdgeInsets.all(10),
                                            child: CircleAvatar(
                                                radius: 35,
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

  var detailsSubmitted = false;
  var classDetailsError = "";
  var branchController = TextEditingController();
  var subjectController = TextEditingController();
  var classLinkController = TextEditingController();
  var imageLinkController = TextEditingController();
  var yearController = TextEditingController();

  BuildContext addClass(BuildContext context) {
    AlertDialog alert = AlertDialog(
      elevation: 2.0,
      content: detailsSubmitted
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
                          style: TextStyle(color: Colors.blue, fontSize: 10),
                        )),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: TextField(
                        controller: branchController,
                        obscureText: false,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Branch',
                            hintText: 'Eg. CSE, ECE...'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: TextField(
                        controller: subjectController,
                        obscureText: false,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Subject',
                            hintText: 'Eg. Computer Networks, DBMS'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: TextField(
                        controller: classLinkController,
                        obscureText: false,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Class Link',
                            hintText: 'Eg. meet.google.com/ffs24f2'),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //       horizontal: 15, vertical: 8),
                    //   child: TextField(
                    //     controller: imageLinkController,
                    //     obscureText: false,
                    //     decoration: const InputDecoration(
                    //         border: OutlineInputBorder(),
                    //         labelText: 'Image Link',
                    //         hintText: 'https://wwww.image.com/ece.png'),
                    //   ),
                    // ),
                    // TextFormField(
                    //   controller: yearController,
                    //   keyboardType: TextInputType.number,
                    //   inputFormatters: [
                    //     FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    //   ],
                    //   decoration: InputDecoration(
                    //       labelText: "Year", hintText: '1,2,3,4'),
                    // ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      child: TextFormField(
                        controller: yearController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                        ],
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Year',
                            hintText: '1,2,3,4'),
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
                          detailsSubmitted = true;
                          var ctx = addClass(context);
                          var response = await addClassRequest();
                          if (response == "error") {
                            detailsSubmitted = false;
                            Navigator.pop(ctx);
                            Navigator.pop(context);

                            addClass(context);
                            classDetailsError = "";
                          } else {
                            _image = null;
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                            setState(() {
                              detailsSubmitted = false;
                              imageLinkController.clear();
                              branchController.clear();
                              classLinkController.clear();
                              subjectController.clear();
                              yearController.clear();
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
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
    return context;
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

  Widget messagesPage() {
    return Center(
        child: Container(
      child: const Text("Messages"),
      padding: const EdgeInsets.all(8),
    ));
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

  Future<String> addClassRequest() async {
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
    // classDetailsError = obj['error'];
    return Future.value("error");
  }
}
