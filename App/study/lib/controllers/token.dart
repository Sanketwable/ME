// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

void store(String key, String value, String loginType, String userName,
    String userID) async {
  await storage.write(key: key, value: value);
  await storage.write(key: "loginType", value: loginType);
  await storage.write(key: "username", value: userName);
  await storage.write(key: "user_id", value: userID);
}

Future storeProfileURL(String url) async {
  // var a = await storage.delete(key: "profile_photo");
  var a = await storage.write(key: "profile_photo", value: url);
  return a;
}

Future<String> getValue(String key) async {
  return await storage.read(key: key);
}

Future<String> getLoginType() async {
  return await storage.read(key: "loginType");
}

Future<String> getUserName() async {
  return await storage.read(key: "username");
}

Future<String> getProfilePhotoURL() async {
  return await storage.read(key: "profile_photo");
}

Future<String> getUserID() async {
  return await storage.read(key: "user_id");
}

void delete() async {
  await storage.delete(key: "token");
  await storage.delete(key: "loginType");
  await storage.delete(key: "username");
  await storage.delete(key: "profile_photo");
  await storage.delete(key: "user_id");
}
