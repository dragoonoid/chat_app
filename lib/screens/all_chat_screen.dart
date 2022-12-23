import 'package:chatapp/model/user_provider.dart';
import 'package:chatapp/screens/conversation.dart';
import 'package:chatapp/screens/identity.dart';
import 'package:chatapp/services/add_image.dart';
import 'package:chatapp/services/auth.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/services/get_shared_prefs.dart';
import 'package:chatapp/themes/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AllChatScreen extends StatefulWidget {
  const AllChatScreen({Key? key}) : super(key: key);

  @override
  State<AllChatScreen> createState() => _AllChatScreenState();
}

class _AllChatScreenState extends State<AllChatScreen>
    with WidgetsBindingObserver {
  String profileImageUrl =
      'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80';
  AuthFirebase auth = AuthFirebase();
  Database db = Database();
  late Stream chatRoomStream;
  AddImage storage = AddImage();
  GetSharedPrefs prefs = GetSharedPrefs();
  String username = "";
  int currentSelectedBottomBar = 0;
  var theme;
  @override
  void initState() {
    username = Provider.of<UserProvider>(context, listen: false).username ?? "";
    chatRoomStream = db.getChatRooms(username);
    db.getUserImageUrl(username);
    profileImageUrl =
        Provider.of<UserProvider>(context, listen: false).imageUrl ?? "";
    WidgetsBinding.instance.addObserver(this);
    db.setOnlineStatusLastSeen('', true, context);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String time=DateFormat.yMEd().add_jms().format(DateTime.now());
    print('state = $state');
    if (state != AppLifecycleState.resumed) {
      db.setOnlineStatusLastSeen(time, false, context);
    } 
    else {
      db.setOnlineStatusLastSeen(time, true, context);
    }
  }

  chatRoomList() {
    return StreamBuilder(
      stream: chatRoomStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        var data = snapshot.data!.docs.map((doc) => doc.data()).toList();
        return ListView.builder(
          itemBuilder: (context, i) {
            return chatRoomTile(data[i]);
          },
          itemCount: data.length,
        );
      },
    );
  }

  chatRoomTile(var data) {
    var chatUsers = data['users'];
    String username =
        Provider.of<UserProvider>(context, listen: false).username ?? " ";
    String otherUser = chatUsers[0].toString().compareTo(username) == 0
        ? chatUsers[1]
        : chatUsers[0];
    String imageurl = data['imageUrl_$otherUser'];
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Conversation(
              chatId: data['id'],
              profileImageUrl: imageurl,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          color: theme.tileColor,
        ),
        child: ListTile(
          //dense: true,
          contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
          leading: CircleAvatar(
            foregroundImage: NetworkImage(imageurl),
            backgroundImage: const AssetImage('images/loading.jpg'),
            radius: 30,
          ),
          title: Text(
            otherUser,
            style:
                TextStyle(fontWeight: FontWeight.bold, color: theme.titleColor),
          ),
          subtitle: Text(
            'Last Test',
            style: TextStyle(color: theme.subtitleColor),
          ),
          trailing: PopupMenuButton<int>(
            icon: Icon(
              Icons.menu,
              color: theme.deleteColor,
            ),
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
      ),
    );
  }

  searchBar() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.08,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.searchBack,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed('/search_user');
        },
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: theme.searchIcon,
            ),
            Text(
              '   Search',
              style: TextStyle(color: theme.searchIcon),
            ),
          ],
        ),
      ),
    );
  }

  appBar() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.08,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Messages',
            style: TextStyle(
              color: theme.titleColor,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          Switch(
              value: theme.isDark(),
              onChanged: (_) {
                theme.changeTheme();
              }),
          const SizedBox(
            width: 10,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const Identity(),
                ),
              );
            },
            child: CircleAvatar(
              foregroundImage: NetworkImage(profileImageUrl),
              backgroundImage: const AssetImage('images/loading.jpg'),
              radius: 20,
            ),
          ),
        ],
      ),
    );
  }

  bottomNavigationBar() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: theme.bottomBarBack,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: () {
              toggleButton(0);
            },
            icon: Icon(
              Icons.message,
              color: currentSelectedBottomBar == 0
                  ? theme.selectedIcon
                  : theme.unSelectedIcon,
            ),
          ),
          IconButton(
            onPressed: () {
              toggleButton(1);
            },
            icon: Icon(
              Icons.call,
              color: currentSelectedBottomBar == 1
                  ? theme.selectedIcon
                  : theme.unSelectedIcon,
            ),
          ),
          IconButton(
            onPressed: () {
              toggleButton(2);
            },
            icon: Icon(
              Icons.people,
              color: currentSelectedBottomBar == 2
                  ? theme.selectedIcon
                  : theme.unSelectedIcon,
            ),
          ),
          IconButton(
            onPressed: () {
              toggleButton(3);
            },
            icon: Icon(
              Icons.settings,
              color: currentSelectedBottomBar == 3
                  ? theme.selectedIcon
                  : theme.unSelectedIcon,
            ),
          ),
        ],
      ),
    );
  }

  toggleButton(int x) {
    if (currentSelectedBottomBar != x) {
      setState(() {
        currentSelectedBottomBar = x;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    theme = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: theme.appBackColor,
      body: Padding(
        padding: const EdgeInsets.only(left: 15, top: 0, right: 15, bottom: 15),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  appBar(),
                  const SizedBox(
                    height: 10,
                  ),
                  searchBar(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.70,
                    child: chatRoomList(),
                  ),
                ],
              ),
              Align(
                alignment: AlignmentDirectional.bottomCenter,
                child: bottomNavigationBar(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
