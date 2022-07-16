import 'package:chatapp/model/user.dart';
import 'package:chatapp/model/user_provider.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/services/get_shared_prefs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchUser extends StatefulWidget {
  const SearchUser({Key? key}) : super(key: key);

  @override
  State<SearchUser> createState() => _SearchUserState();
}

class _SearchUserState extends State<SearchUser> {
  TextEditingController username = TextEditingController();
  Database db = Database();
  late QuerySnapshot snapshot;
  GetSharedPrefs prefs = GetSharedPrefs();

  var data = null;
  search(String s) async {
    if (username.text == null || username.text.isEmpty ) {
      return;
    }
    else if(username.text==Provider.of<UserProvider>(context,listen: false).username){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You are trying to search yourself.All usernames are unique')));
    }
     else {
      await db.getuserList(username.text).then((value) => snapshot = value);
      setState(() {
        data = snapshot.docs.map((doc) => doc.data()).toList();
      });
    }
  }

  Widget listOfUsernames() {
    return data != null
        ? ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemBuilder: (_, i) {
              return customListTile(
                  data[i]!['username'], data[i]!['email'], data[i]!['id']);
            },
            itemCount: snapshot.docs.length,
          )
        : Container(
            child: const Text('No such username found'),
          );
  }

  createChatRoon(String searchedUsername, String searchEmail) async {
    String myName = await prefs.getUsername();
    String myEmail = await prefs.getEmail();
    String chatId = createChatId(searchedUsername, myName);
    Map<String, dynamic> mp = {
      'id': chatId,
      'users': [searchedUsername, myName],
      'emails': [searchEmail, myEmail],
    };
    await db.createChatRoom(chatId, mp);
    Navigator.of(context)
        .pushNamed('/conversation', arguments: {'chatId': chatId});
  }

  createChatId(String a, String b) {
    int r = a.compareTo(b);
    if (r < 0) {
      return "$a\_$b";
    } else if (r > 0) {
      return "$b\_$a";
    }
  }

  customListTile(String username, String email, String id) {
    return Container(
      //width: MediaQuery.of(context).size.width * 0.7,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: Row(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(email),
          ],
        ),
        Spacer(),
        GestureDetector(
          onTap: () => createChatRoon(username, email),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Send Text',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white),
                child: Center(
                  child: Row(
                    children: [
                      const Icon(Icons.search),
                      const SizedBox(
                        width: 5,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: TextField(
                          onChanged: search,
                          onSubmitted: search,
                          controller: username,
                          decoration: const InputDecoration(
                            hintText: 'Search Username',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              listOfUsernames(),
            ],
          ),
        ),
      ),
    );
  }
}
