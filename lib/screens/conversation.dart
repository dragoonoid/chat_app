import 'package:chatapp/model/user_provider.dart';
import 'package:chatapp/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grouped_list/grouped_list.dart';

class Conversation extends StatefulWidget {
  String chatId;
  Conversation({Key? key, required this.chatId}) : super(key: key);

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  TextEditingController text = TextEditingController();
  Database db = Database();
  late Stream chatMessageStream;
  @override
  void initState() {
    chatMessageStream = db.getTextFromChatRoom(widget.chatId);
    super.initState();
  }

  messagesList() {
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        var data = snapshot.data!.docs.map((doc) => doc.data()).toList();
        return ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, i) {
            //return Text(data[i]['text']);
            if (i == data.length) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.15,
              );
            }
            return messageTile(data[i]);
          },
          itemCount: data.length + 1,
        );
        // return GroupedListView(
        //   padding: const EdgeInsets.all(8),
        //   elements: data,
        //   groupBy: (x) => true,
        //   groupHeaderBuilder: (x) => const SizedBox(),
        //   itemBuilder: (_, dynamic x) {
        //     print(x['text']);
        //     print(x['sender']);
        //     String email =
        //         Provider.of<UserProvider>(context, listen: false).email ?? "";
        //     return Card(
        //       elevation: 8,
        //       child: Padding(
        //         padding: const EdgeInsets.all(12),
        //         child: Align(
        //           alignment: x['sender'].toString().compareTo(email) == 0
        //               ? Alignment.centerRight
        //               : Alignment.centerLeft,
        //           child: Text(
        //             x['text'].toString(),
        //           ),
        //         ),
        //       ),
        //     );
        //   },
        // );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var chatUsers = widget.chatId.split('_');
    print(chatUsers[0]);
    print(chatUsers[1]);
    String username =
        Provider.of<UserProvider>(context, listen: false).username ?? " ";
    String id = widget.chatId;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/all_chat_screen', (route) => false);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: chatUsers[0].toString().compareTo(username) == 0
            ? Text(
                chatUsers[1],
                style: TextStyle(
                  color: Colors.black,
                ),
              )
            : Text(
                chatUsers[0],
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
      ),
      body: SafeArea(
          child: Stack(
        children: [
          messagesList(),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 5, 12, 12),
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                  width: MediaQuery.of(context).size.width * 0.65,
                  child: TextField(
                    onSubmitted: (a) async {
                      print('called');
                      print(a);
                      if (a != null && a.length > 0) {
                        await db.sendTextToChatRoom(a, id, context);
                        text.clear();
                      }
                    },
                    controller: text,
                    decoration: const InputDecoration(
                      hintText: 'Type here...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.amber[200],
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.amber[200],
                    child: IconButton(
                      icon: const Icon(
                        Icons.mic,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      )),
    );
  }

  messageTile(var data) {
    String email =
        Provider.of<UserProvider>(context, listen: false).email ?? "";
    bool x = data['sender'].toString().compareTo(email) == 0;
    return Container(
      alignment: x ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Card(
        // shape: const RoundedRectangleBorder(
        //   borderRadius: x? BorderRadius.only():BorderRadius.only(),
        // ),
        color: x ? Colors.amber[200] : Colors.white,
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            data['text'].toString(),
          ),
        ),
      ),
    );
  }

  // messageTile(var data) {
  //   String email =
  //       Provider.of<UserProvider>(context, listen: false).email ?? "";
  //   print(email);
  //   print(data['sender']);
  //   if (data['sender'].toString().compareTo(email) == 0) {
  //     return right(data);
  //   } else {
  //     return left(data);
  //   }
  // }

  // left(var data) {
  //   return Container(
  //     padding: const EdgeInsets.only(left: 15),
  //     alignment: Alignment.centerLeft,
  //     margin: const EdgeInsets.symmetric(vertical:8),
  //     child: Container(
  //       padding: const EdgeInsets.all(10),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(20),
  //         color: Colors.blue,
  //       ),
  //       child: Text(data['text']),
  //     ),
  //   );
  // }

  // right(var data) {
  //   return Container(
  //     padding: const EdgeInsets.only(right: 15),
  //     alignment: Alignment.centerRight,
  //     margin: const EdgeInsets.symmetric(vertical:8),
  //     child: Container(
  //       padding: const EdgeInsets.all(10),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(20),
  //         color: Colors.amber[100],
  //       ),
  //       child: Text(data['text']),
  //     ),
  //   );
  // }
}
