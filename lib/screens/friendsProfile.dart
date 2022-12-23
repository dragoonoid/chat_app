import 'dart:io';
import 'package:chatapp/services/saveAndPickImage.dart';
import 'package:chatapp/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  SaveAndPickImage saveAndPickImage = SaveAndPickImage();
  String imageUrl = '';
  String email = '';
  var theme;
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
    theme = Provider.of<ThemeProvider>(context);
    String username = widget.friendsUsername;
    return Scaffold(
      backgroundColor: theme.appBackColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.appBackColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: theme.titleColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Switch(
              value: theme.isDark(),
              onChanged: (_) {
                theme.changeTheme();
              }),
        ],
        title: Text(
          widget.friendsUsername,
          style: TextStyle(color: theme.titleColor),
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
                      onTap: () {
                        saveAndPickImage.openImage(imageUrl, context);
                      },
                      onLongPress: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Downloading...'),
                          ),
                        );
                        await saveAndPickImage.saveImage(imageUrl);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile downloaded'),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 82,
                        backgroundColor: Colors.grey[300],
                        child: CircleAvatar(
                          radius: 80,
                          backgroundImage:
                              const AssetImage('images/loading.jpg'),
                          foregroundImage: NetworkImage(imageUrl),
                        ),
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
        style: TextStyle(color: theme.titleColor),
      ),
    );
  }
}
