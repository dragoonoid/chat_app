import 'package:chatapp/model/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Database {
  Future publishUser(
      String uid, String email, String password, String username) async {
    Map<String, String> mp = {
      'id': uid,
      'email': email,
      'password': password,
      'username': username
    };
    await FirebaseFirestore.instance.collection('users').doc(uid).set(mp);
  }

  Future getUserByEmail(String email) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
  }

  Future getuserList(String? username) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
  }

  createChatRoom(String chatId, Map<String, dynamic> mp) async {
    await FirebaseFirestore.instance
        .collection('chat_room')
        .doc(chatId)
        .set(mp);
  }

  deleteChatRoom(String id) async {
    await FirebaseFirestore.instance
        .collection('chat_room')
        .doc(id)
        .delete()
        .then((value) => print('deleted'));
  }

  sendTextToChatRoom(String text, String chatId, BuildContext context) async {
    Map<String, dynamic> mp = {
      'sender': Provider.of<UserProvider>(context, listen: false).email ?? "",
      'text': text,
      'time': DateFormat.yMd().format(DateTime.now()),
      'orderBy': DateTime.now().millisecondsSinceEpoch
    };
    print('sendText called');
    await FirebaseFirestore.instance
        .collection('chat_room')
        .doc(chatId)
        .collection('chats')
        .add(mp);
  }

  Stream getTextFromChatRoom(String chatId) {
    print('getText called');
    return FirebaseFirestore.instance
        .collection('chat_room')
        .doc(chatId)
        .collection('chats')
        .orderBy('orderBy')
        .snapshots();
  }

  getChatRooms(String username) {
    return FirebaseFirestore.instance
        .collection('chat_room')
        .where('users', arrayContains: username)
        .snapshots();
  }
}
