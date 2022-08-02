import 'package:chatapp/model/user_provider.dart';
import 'package:chatapp/screens/detail_image.dart';
import 'package:chatapp/services/add_image.dart';
import 'package:chatapp/services/database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
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
  AddImage storage = AddImage();

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
                style: const TextStyle(
                  color: Colors.black,
                ),
              )
            : Text(
                chatUsers[0],
                style: const TextStyle(
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
                        onPressed: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                            allowMultiple: false,
                            type: FileType.custom,
                            allowedExtensions: ['png', 'jpg'],
                          );

                          if (result != null) {
                            final path = result.files.single.path ?? "";
                            final fileName = result.files.single.name;
                            await storage.addImageToChatRoom(
                                fileName, path, username);
                            String x = await storage.getChatImage(
                                    username, fileName) ??
                                "";
                            await db.sendTextToChatRoom(x, id, context);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('File Picker Closed')));
                          }
                        },
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
        ),
      ),
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
        child: !Uri.parse(data['text']).isAbsolute
            ? Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  data['text'].toString(),
                ),
              )
            : GestureDetector(
                onLongPress: ()async{
                  print('save gallery called');
                  final tempDir=await getTemporaryDirectory();
                  final path ='${tempDir.path}/image';
                  await Dio().download(data['text'],path);

                  await GallerySaver.saveImage(path,toDcim: true);
                  print('saved');
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailImageScreen(url: data['text']),
                    ),
                  );
                },
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Image.network(
                    data['text'],
                    fit: BoxFit.cover,
                  ),
                ),
              ),
      ),
    );
  }
}
