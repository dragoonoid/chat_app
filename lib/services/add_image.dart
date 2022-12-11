import 'dart:io';

import 'package:chatapp/services/database.dart';
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

  Future addImageToChatRoom(
      String fileName, String filePath, String username) async {
    File file = File(filePath);
    try {
      await storage.ref('chat_image/$username/$fileName').putFile(file);
    } on Exception catch (_, e) {
      print(e);
    }
  }

  Future getChatImage(String username, String fileName) async {
    try {
      String url = await storage
          .ref()
          .child('chat_image/$username/$fileName')
          .getDownloadURL();
      return url;
    } on firebase_storage.FirebaseException catch (e) {
      print(e);
    }
  }

  Future getProfileImage(String username) async {
    try {
      String url =
          await storage.ref().child('user_image/$username').getDownloadURL();
      return url;
    } on FirebaseException catch (e) {
      // Caught an exception from Firebase.
      print("Failed with error '${e.code}': ${e.message}");
      // await db.addImageUrlToUser(username,
      //     "https://firebasestorage.googleapis.com/v0/b/chatapp-29812.appspot.com/o/user_image%2Fguest-user.jpg?alt=media&token=89b9d97f-c7d9-41db-a946-b9e1fa38e105");
      return "https://firebasestorage.googleapis.com/v0/b/chatapp-29812.appspot.com/o/user_image%2Fguest-user.jpg?alt=media&token=89b9d97f-c7d9-41db-a946-b9e1fa38e105";
    }
  }

  Future deleteProflieImage(String username) async {
    Database db = Database();
    try {
      await storage.ref().child('user_image/$username').delete();
      await db.addImageUrlToUser(username,
          "https://firebasestorage.googleapis.com/v0/b/chatapp-29812.appspot.com/o/user_image%2Fguest-user.jpg?alt=media&token=89b9d97f-c7d9-41db-a946-b9e1fa38e105");
      return "https://firebasestorage.googleapis.com/v0/b/chatapp-29812.appspot.com/o/user_image%2Fguest-user.jpg?alt=media&token=89b9d97f-c7d9-41db-a946-b9e1fa38e105";
    } on FirebaseException catch (e) {
      // Caught an exception from Firebase.
      print("Failed with error '${e.code}': ${e.message}");
      return "https://firebasestorage.googleapis.com/v0/b/chatapp-29812.appspot.com/o/user_image%2Fguest-user.jpg?alt=media&token=89b9d97f-c7d9-41db-a946-b9e1fa38e105";
    }
  }

  //--------------------------------Sending chat voice notes-----------
  Future sendVoiceNotesToDb(
      String fileName, String filePath, String username) async {
    File file = File(filePath);
    try {
      await storage.ref('voice_note/$username/$fileName').putFile(file);
    } on Exception catch (_, e) {
      print(e);
    }
  }

  Future getVoiceNoteUrl(String username, String fileName) async {
    try {
      String url = await storage
          .ref()
          .child('voice_note/$username/$fileName')
          .getDownloadURL();
      return url;
    } on firebase_storage.FirebaseException catch (e) {
      print(e);
    }
  }
  //----------------------send and get video file------------------------------
  Future sendVideoFile(
      String fileName, String filePath, String username) async {
    File file = File(filePath);
    try {
      await storage.ref('video/$username/$fileName').putFile(file);
    } on Exception catch (_, e) {
      print(e);
    }
  }

  Future getVideoFileUrl(String username, String fileName) async {
    try {
      String url = await storage
          .ref()
          .child('video/$username/$fileName')
          .getDownloadURL();
      return url;
    } on firebase_storage.FirebaseException catch (e) {
      print(e);
    }
  }
}
