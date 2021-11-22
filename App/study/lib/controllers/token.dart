// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

void store(String key, String value, String loginType, String userName, String userID) async {
  print("token stored");
  print("value");
  await storage.write(key: key, value: value);
  await storage.write(key: "loginType", value: loginType);
  await storage.write(key:"username", value: userName);
  await storage.write(key: "user_id", value: userID);
}

void storeProfileURL(String url) async {
  await storage.write(key: "profile_photo", value: url); 
}

Future<String> getValue(String key) async {
  print("returning token");
  return await storage.read(key: key);
}
Future<String> getLoginType() async {
  print("returning logintype");
  return await storage.read(key: "loginType");
}
Future<String> getUserName() async {
  print("returning username");
  return await storage.read(key: "username");
}
Future<String> getProfilePhotoURL() async {
  print("returning url");
  return await storage.read(key: "profile_photo");
}

void delete() async {
  await storage.delete(key: "token");
  await storage.delete(key: "loginType");
  await storage.delete(key: "username");
  await storage.delete(key: "profile_photo");
}
