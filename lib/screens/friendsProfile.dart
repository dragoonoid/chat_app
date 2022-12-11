import 'dart:io';
import 'package:chatapp/services/saveAndPickImage.dart';
import 'package:flutter/material.dart';

import '../services/database.dart';

class FriendsProfile extends StatefulWidget {
  final friendsUsername;
  const FriendsProfile({Key? key, required this.friendsUsername})
      : super(key: key);

  @override
  State<FriendsProfile> createState() => _FriendsProfileState();
}

class _FriendsProfileState extends State<FriendsProfile> {
  bool isLoading = true;
  bool sheet = false;
  Database db = Database();
  SaveAndPickImage saveAndPickImage=SaveAndPickImage();
  String imageUrl = '';
  String email = '';
  var data;
  @override
  void didChangeDependencies() async {
    imageUrl = await db.getUserImageUrl(widget.friendsUsername);
    var x = await db.getuserList(widget.friendsUsername);
    data = x.docs.map((doc) => doc.data()).toList();
    print(data[0]['email']);
    print(data[0]['imageUrl']);
    imageUrl = data[0]['imageUrl'];
    email = data[0]['email'];
    setState(() {
      isLoading = false;
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    String username = widget.friendsUsername;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          widget.friendsUsername,
          style:const TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: (){
                        saveAndPickImage.openImage(imageUrl, context);
                      },
                      onDoubleTap: (){
                        saveAndPickImage.saveImage(imageUrl);
                      },
                      child: CircleAvatar(
                        radius: 80,
                        backgroundImage: const AssetImage('images/loading.jpg'),
                        foregroundImage: NetworkImage(imageUrl),
                      ),
                    ),
                  ),
                  textWidget('Username', widget.friendsUsername, Icons.person),
                  const SizedBox(
                    height: 5,
                  ),
                  textWidget('Email', email, Icons.email)
                ],
              ),
      ),
    );
  }

  textWidget(String title, String subTitle, IconData icon) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.blue[600],
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.grey),
      ),
      subtitle: Text(
        subTitle,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
