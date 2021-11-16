import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = new FlutterSecureStorage();

void store(String key, String value) async {
  print("token stored");
  print("value");
  await storage.write(key: key, value: value);
}

Future<String> getValue(String key) async {
  print("returning token");
  return await storage.read(key: key);
}

void delete(String key) async {
  await storage.delete(key: key);
}
