import 'package:chatapp/services/database.dart';
import 'package:flutter/material.dart';

class Conversation extends StatefulWidget {
  const Conversation({Key? key}) : super(key: key);

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  TextEditingController text = TextEditingController();
  Database db=Database();
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String,String>;
    String? chatId=args['chatId'];
    String id=chatId==null?"":chatId;
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
      ),
      body: SafeArea(
          child: Stack(
        children: [
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
                    onSubmitted: (a)async{
                      print('called');
                      print(a);
                      if(a!=null && a.length>0 ){
                        await db.sendTextToChatRoom(a,id,context);
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
}
