import 'package:chatapp/model/user_provider.dart';
import 'package:chatapp/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllChatScreen extends StatefulWidget {
  const AllChatScreen({Key? key}) : super(key: key);

  @override
  State<AllChatScreen> createState() => _AllChatScreenState();
}

class _AllChatScreenState extends State<AllChatScreen> {
  AuthFirebase auth = AuthFirebase();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed('/search_user');
          },
          icon: const Icon(Icons.search),
        ),
        const SizedBox(
          width: 5,
        ),
        IconButton(
          onPressed: () async {
            await auth.signOut();
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/wel', (route) => false);
          },
          icon: const Icon(Icons.account_box_sharp),
        ),
        const SizedBox(
          width: 5,
        )
      ]),
      body: Container(
        child: Column(children: [
          Text(Provider.of<UserProvider>(context).username!),
          Text(Provider.of<UserProvider>(context).email!),
          Text(Provider.of<UserProvider>(context).username!),
        ]),
      ),
    );
  }
}
