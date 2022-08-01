import 'package:chatapp/model/user_provider.dart';
import 'package:chatapp/screens/conversation.dart';
import 'package:chatapp/screens/identity.dart';
import 'package:chatapp/services/add_image.dart';
import 'package:chatapp/services/auth.dart';
import 'package:chatapp/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllChatScreen extends StatefulWidget {
  const AllChatScreen({Key? key}) : super(key: key);

  @override
  State<AllChatScreen> createState() => _AllChatScreenState();
}

class _AllChatScreenState extends State<AllChatScreen> {
  AuthFirebase auth = AuthFirebase();
  Database db = Database();
  late Stream chatRoomStream;
  AddImage storage = AddImage();
  String username = "";
  @override
  void initState() {
    // TODO: implement initState
    // String username =
    //     Provider.of<UserProvider>(context, listen: false).username!;
    username = Provider.of<UserProvider>(context, listen: false).username ?? "";
    chatRoomStream = db.getChatRooms(username);
    super.initState();
  }

  chatRoomList() {
    return StreamBuilder(
      stream: chatRoomStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        var data = snapshot.data!.docs.map((doc) => doc.data()).toList();
        return ListView.builder(
          itemBuilder: (context, i) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Conversation(
                      chatId: data[i]['id'],
                    ),
                  ),
                );
              },
              onLongPress: () {},
              child: chatRoomTile(data[i]),
            );
          },
          itemCount: data.length,
        );
      },
    );
  }

  chatRoomTile(var data) {
    var chatUsers = data['id'].split('_');
    String username =
        Provider.of<UserProvider>(context, listen: false).username ?? " ";
    String otherUser = chatUsers[0].toString().compareTo(username) == 0
        ? chatUsers[1]
        : chatUsers[0];
    //String url = await storage.getProfileImage(otherUser);
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: Colors.grey,
          ),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.amber,
          child: Text(
            otherUser[0].toUpperCase(),
            style: const TextStyle(color: Colors.black),
          ),
        ),
        title: Text(otherUser),
        trailing: PopupMenuButton<int>(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 1,
              child: Text('delete'),
            ),
          ],
          onSelected: (value) {
            if (value == 1) {
              showDialog(
                context: context,
                builder: (_) {
                  return AlertDialog(
                    title: const Text('Delete Chats'),
                    content: const Text(
                        'Are you sure you eant to delete this chat room?'),
                    actions: [
                      ElevatedButton(
                        onPressed: () async {
                          await db.deleteChatRoom(data['id']);
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context);
                        },
                        child: const Text('Yes'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('No'),
                      ),
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 3,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/search_user');
            },
            icon: const Icon(
              Icons.search,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          IconButton(
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const Identity(),
                ),
              );
            },
            icon: const Icon(
              Icons.account_box_sharp,
              color: Colors.black,
            ),
          ),
          const SizedBox(
            width: 5,
          )
        ],
        backgroundColor: Colors.white,
        title: const Text(
          'Chat Room',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(child: chatRoomList()),
    );
  }
}
