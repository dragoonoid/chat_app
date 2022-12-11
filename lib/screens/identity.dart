import 'dart:io';
import 'package:chatapp/model/user_provider.dart';
import 'package:chatapp/services/add_image.dart';
import 'package:chatapp/services/auth.dart';
import 'package:chatapp/services/get_shared_prefs.dart';
import 'package:chatapp/services/saveAndPickImage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../services/database.dart';

class Identity extends StatefulWidget {
  const Identity({Key? key}) : super(key: key);

  @override
  State<Identity> createState() => _IdentityState();
}

class _IdentityState extends State<Identity> {
  bool sheet = false;
  AuthFirebase auth = AuthFirebase();
  GetSharedPrefs prefs = GetSharedPrefs();
  Database db=Database();
  final AddImage storage = AddImage();
  SaveAndPickImage saveAndPickImage=SaveAndPickImage();
  late String username;
  late String email;
  String? url = null;
  @override
  void initState() {
    username = Provider.of<UserProvider>(context, listen: false).username ?? "";
    email = Provider.of<UserProvider>(context, listen: false).email ?? "";
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    String? x = await prefs.getImageUrl();
    //String? x = await storage.getProfileImage(username);
    if (x != null) {
      setState(() {
        url = x;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context)
                              .pushNamed('/all_chat_screen');
          },
        ),
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await auth.signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil('/wel', (route) => false);
            },
            icon: const Icon(
              Icons.account_box_sharp,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(children: [
          image(),
          const SizedBox(
            height: 5,
          ),
          textWidget(
            'Username',
            username,
            true,
            Icon(
              Icons.person,
              color: Colors.blue[600],
              size: 40,
            ),
            () {},
          ),
          const SizedBox(
            height: 5,
          ),
          textWidget(
            'Email',
            email,
            true,
            Icon(
              Icons.email,
              color: Colors.blue[600],
              size: 40,
            ),
            () {},
          ),
          // const SizedBox(height: 5,),
          // textWidget('',true)
        ]),
      ),
    );
  }

  image() {
    return GestureDetector(
      onTap: (){
        saveAndPickImage.openImage(url??'', context);
      },
      onDoubleTap: () async {
        FilePickerResult? result = await saveAndPickImage.pickImage();
        if (result != null) {
          final path = result.files.single.path ?? "";
          final fileName = result.files.single.name;
          // setState(() {
          //   url = null;
          // });
          await storage.addProfileImage(fileName, path, username);
          String x = await storage.getProfileImage(username);
          await db.addImageUrlToUser(username, x);
          await prefs.setImageUrl(x);
          await db.changeProfileImagesInChatRooms(username,x);
          await Provider.of<UserProvider>(context, listen: false)
              .getDetailsFromDevice();
          setState(() {
            url = x;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('File Picker Closed')));
        }
      },
      onLongPress: url ==
              "https://firebasestorage.googleapis.com/v0/b/chatapp-29812.appspot.com/o/user_image%2Fguest-user.jpg?alt=media&token=89b9d97f-c7d9-41db-a946-b9e1fa38e105"
          ? () {}
          : () => showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: const Text(
                      'You surely want to delete this profile picture?'),
                  content: const Text('Once deleted it cannot be recovered!'),
                  actions: [
                    TextButton(
                        onPressed: () async {
                          String x = await storage.deleteProflieImage(username);
                          setState(() {
                            url = x;
                          });
                          await prefs.setImageUrl(x);
                          await Provider.of<UserProvider>(context,
                                  listen: false)
                              .getDetailsFromDevice();
                          Navigator.pop(context);
                        },
                        child: const Text('Yes')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('No'),
                    )
                  ],
                );
              }),
      child: url == null
          ? const Center(
              child: CircleAvatar(
                radius: 80,
                child: Center(
                  child: SpinKitWave(
                    color: Colors.white,
                    size: 50.0,
                  ),
                ),
              ),
            )
          : Center(
              child: CircleAvatar(
                radius: 80,
                backgroundImage: const AssetImage('images/loading.jpg'),
                foregroundImage: NetworkImage(url ?? ""),
              ),
            ),
    );
  }

  textWidget(String text, String value, bool change, Icon icon, dynamic func) {
    return GestureDetector(
      onTap: change
          ? () {
              setState(() {});
            }
          : () {},
      child: ListTile(
        leading: icon,
        trailing: IconButton(
          icon: Icon(
            Icons.edit,
            color: Colors.grey[400],
          ),
          onPressed: func,
        ),
        title: Text(
          text,
          style: const TextStyle(color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
