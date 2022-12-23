import 'package:chatapp/model/user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class Database {
  Future publishUser(String email, String password, String username) async {
    Map<String, String> mp = {
      'id': username,
      'email': email,
      'password': password,
      'username': username,
      'imageUrl':
          "https://firebasestorage.googleapis.com/v0/b/chatapp-29812.appspot.com/o/user_image%2Fguest-user.jpg?alt=media&token=89b9d97f-c7d9-41db-a946-b9e1fa38e105"
    };
    await FirebaseFirestore.instance.collection('users').doc(username).set(mp);
    await FirebaseFirestore.instance
        .collection('user_status')
        .doc(username)
        .set({'doc_id': username, 'last_seen': 'time', 'online': true});
  }

  Future<bool> checkUserExists(String username) async {
    bool exists = false;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .get()
        .then((value) {
      if (value.exists) {
        exists = true;
      }
    });
    return exists;
  }
//--------------Image---------------------------

  Future addImageUrlToUser(String username, String url) async {
    //update profile
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(username)
        .update({'imageUrl': url}).then((value) => print('image updated'));
  }

  Future getUserImageUrl(String username) async {
    // and any profile url
    var x = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();
    var t = x.docs.map((e) => e.data()).toList();
    return t[0]['imageUrl'];
  }

  Future changeProfileImagesInChatRooms(String username, String url) async {
    var x = await FirebaseFirestore.instance
        .collection('chat_room')
        .where('users', arrayContains: username)
        .get();
    var t = x.docs.map((e) => e.data()).toList();
    int len = t.length;
    List<String> ids = [];
    for (int i = 0; i < len; i++) {
      ids.add(t[i]['id']);
    }
    for (int i = 0; i < ids.length; i++) {
      await FirebaseFirestore.instance
          .collection('chat_room')
          .doc(ids[i])
          .update({'imageUrl_$username': url}).then(
              (value) => print('image updated'));
    }
  }

//--------------getting users details-------------------

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

//--------------create, delete, get chat rooms details

  createChatRoom(String chatId, Map<String, dynamic> mp) async {
    await FirebaseFirestore.instance
        .collection('chat_room')
        .doc(chatId)
        .set(mp);
    List<String> users = chatId.split('_');
    await FirebaseFirestore.instance
        .collection('user_status')
        .doc(users[0])
        .update({'isTypingIn_${users[1]}': false});
    await FirebaseFirestore.instance
        .collection('user_status')
        .doc(users[1])
        .update({'isTypingIn_${users[0]}': false});
  }

  deleteChatRoom(String id) async {
    await FirebaseFirestore.instance
        .collection('chat_room')
        .doc(id)
        .delete()
        .then((value) => print('deleted'));
  }

  Stream getChatRooms(String username) {
    return FirebaseFirestore.instance
        .collection('chat_room')
        .where('users', arrayContains: username)
        .snapshots();
  }

//--------------send and receive texts----------------------

  sendTextToChatRoom(
      String text, String chatId, BuildContext context, String type) async {
    Map<String, dynamic> mp = {
      'sender': Provider.of<UserProvider>(context, listen: false).email ?? "",
      'text': text,
      'time': DateFormat.yMd().format(DateTime.now()),
      'orderBy': DateTime.now().millisecondsSinceEpoch,
      'type': type
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

  //-----------------------setting online status and last seen --------------
  Stream getOnlineStatus(String username) {
    return FirebaseFirestore.instance
        .collection('user_status')
        .where('doc_id', isEqualTo: username)
        .snapshots();
  }

  setOnlineStatusLastSeen(
      String time, bool online, BuildContext context) async {
    String username =
        Provider.of<UserProvider>(context, listen: false).username ?? "";
    await FirebaseFirestore.instance
        .collection('user_status')
        .doc(username)
        .update({'last_seen': time, 'online': online});
  }

  setTypingStatus(
      BuildContext context, bool isTyping, String friendsUser) async {
    String username =
        Provider.of<UserProvider>(context, listen: false).username ?? "";
    print(friendsUser);
    await FirebaseFirestore.instance
        .collection('user_status')
        .doc(username)
        .update({'isTypingIn_$friendsUser': isTyping});
  }
}
