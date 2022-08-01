import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';

class AddImage {
  final firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  Future addProfileImage(
      String fileName, String filePath, String username) async {
    File file = File(filePath);

    try {
      await storage.ref('user_image/$username').putFile(file);
    } on Exception catch (_, e) {
      print(e);
    }
  }

  Future getProfileImage(String username) async {
    try {
      String url =
          await storage.ref().child('user_image/$username').getDownloadURL();
      print(url);
      return url;
    } on FirebaseException catch (e) {
      // Caught an exception from Firebase.
      print("Failed with error '${e.code}': ${e.message}");
      return "https://firebasestorage.googleapis.com/v0/b/chatapp-29812.appspot.com/o/user_image%2Fguest-user.jpg?alt=media&token=89b9d97f-c7d9-41db-a946-b9e1fa38e105";
    }
  }
  Future deleteProflieImage(String username) async {
    try {
      await storage.ref().child('user_image/$username').delete();
      return "https://firebasestorage.googleapis.com/v0/b/chatapp-29812.appspot.com/o/user_image%2Fguest-user.jpg?alt=media&token=89b9d97f-c7d9-41db-a946-b9e1fa38e105";
    } on FirebaseException catch (e) {
      // Caught an exception from Firebase.
      print("Failed with error '${e.code}': ${e.message}");
      return "https://firebasestorage.googleapis.com/v0/b/chatapp-29812.appspot.com/o/user_image%2Fguest-user.jpg?alt=media&token=89b9d97f-c7d9-41db-a946-b9e1fa38e105";
    }
  }
}
