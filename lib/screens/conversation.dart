import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:chatapp/model/user_provider.dart';
import 'package:chatapp/screens/detail_image.dart';
import 'package:chatapp/screens/friendsProfile.dart';
import 'package:chatapp/services/add_image.dart';
import 'package:chatapp/services/audio_player.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/services/saveAndPickImage.dart';
import 'package:chatapp/services/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
// import 'package:gallery_saver/gallery_saver.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class Conversation extends StatefulWidget {
  final chatId;
  final profileImageUrl;
  const Conversation(
      {Key? key, required this.chatId, required this.profileImageUrl})
      : super(key: key);

  @override
  State<Conversation> createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  TextEditingController text = TextEditingController();
  Database db = Database();
  late Stream chatMessageStream;
  AddImage storage = AddImage();
  SaveAndPickImage savePickImage = SaveAndPickImage();
  bool showContainer = false;
  @override
  void initState() {
    chatMessageStream = db.getTextFromChatRoom(widget.chatId);
    initRecorder(); // initialize recorder

    super.initState();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  messagesList() {
    return StreamBuilder(
      stream: chatMessageStream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        var data = snapshot.data!.docs.map((doc) => doc.data()).toList();
        return ListView.builder(
          shrinkWrap: true,
          itemBuilder: (context, i) {
            if (i == data.length) {
              return Container(
                height: MediaQuery.of(context).size.height * 0.1,
              );
            }
            return messageTile(data[i]);
          },
          itemCount: data.length + 1,
        );
      },
    );
  }

  appBar(String otherUser) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FriendsProfile(
              friendsUsername: otherUser,
            ),
          ),
        );
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              width: 1.0,
              color: Colors.white38,
            ),
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(widget.profileImageUrl),
          ),
          title: Text(otherUser),
          subtitle: Row(
            children: [
              const Icon(Icons.bubble_chart, color: Colors.green),
              Text(
                'Online now',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
          trailing: IconButton(
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/all_chat_screen', (route) => false);
            },
            icon: const Icon(Icons.backspace_outlined),
          ),
        ),
      ),
    );
  }

//---------------------recording audio-----------------
  final recorder = FlutterSoundRecorder();
  bool readyFlag = false;
  Future stop(String mode, BuildContext context) async {
    if (readyFlag == false) {
      return;
    }
    if (mode == 'cancel') {
      await recorder.stopRecorder();
      return;
    }
    final path = await recorder.stopRecorder();
    final fileName = const Uuid().v4();
    String username =
        Provider.of<UserProvider>(context, listen: false).username ?? " ";
    await storage.sendVoiceNotesToDb(fileName, path!, username);
    final url = await storage.getVoiceNoteUrl(username, fileName);
    print(path);
    print(url);
    return url;
  }

  Future record() async {
    if (readyFlag == false) {
      return;
    }
    await recorder.startRecorder(toFile: 'audio');
  }

  Future initRecorder() async {
    print('check permission');
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Mic not granted';
    }
    await recorder.openRecorder();
    readyFlag = true;
    recorder.setSubscriptionDuration(
      const Duration(milliseconds: 500),
    );
  }

//-------------------------------------------------------

  Future pickFileFromLocal(String type, String username, String chatId) async {
    late FilePickerResult? result;
    if (type == 'img') {
      result = await savePickImage.pickImage();
    } else if (type == 'audio') {
      result = await savePickImage.pickAudio();
    } else {
      result = await savePickImage.pickVideo();
    }
    if (result != null) {
      final path = result.files.single.path ?? "";
      final fileName = result.files.single.name;
      String x;
      if (type == 'img') {
        await storage.addImageToChatRoom(fileName, path, username);
        x = await storage.getChatImage(username, fileName) ?? "";
      } else if (type == 'audio') {
        await storage.sendVoiceNotesToDb(fileName, path, username);
        x = await storage.getVoiceNoteUrl(username, fileName) ?? "";
      } else {
        await storage.sendVideoFile(fileName, path, username);
        x = await storage.getVideoFileUrl(username, fileName) ?? "";
      }
      // ignore: use_build_context_synchronously
      await db.sendTextToChatRoom(x, chatId, context, type);
      setState(() {
        showContainer = false;
      });
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('File Picker Closed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    var chatUsers = widget.chatId.split('_');
    String username =
        Provider.of<UserProvider>(context, listen: false).username ?? " ";
    String id = widget.chatId;
    String otherUser = chatUsers[0].toString().compareTo(username) == 0
        ? chatUsers[1]
        : chatUsers[0];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  appBar(otherUser),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: messagesList(),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 5, 12, 12),
                height: MediaQuery.of(context).size.height * 0.2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    (showContainer
                        ? Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.1,
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
                            child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      IconButton(
                                        //photo
                                        onPressed: () async {
                                          await pickFileFromLocal(
                                              'img', username, id);
                                        },
                                        icon: CircleAvatar(
                                            minRadius: 25,
                                            backgroundColor: Colors.red[400],
                                            child: const Icon(
                                              Icons.photo,
                                              color: Colors.white,
                                            )),
                                      ),
                                      Text(
                                        'Image',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        // video
                                        onPressed: () async {
                                          await pickFileFromLocal(
                                              'video', username, id);
                                        },
                                        icon: CircleAvatar(
                                          minRadius: 25,
                                          backgroundColor: Colors.purple[400],
                                          child: const Icon(
                                            Icons.video_call,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Video',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        // audio
                                        onPressed: () async {
                                          await pickFileFromLocal(
                                              'audio', username, id);
                                        },
                                        icon: CircleAvatar(
                                          minRadius: 25,
                                          backgroundColor: Colors.orange[400],
                                          child: const Icon(
                                            Icons.audio_file,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'Audio',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ]),
                          )
                        : Container(
                            height: 0,
                          )),
                    Row(
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
                              if (a != null && a.length > 0) {
                                await db.sendTextToChatRoom(
                                    a, id, context, 'text');
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
                                offset: Offset(0.0, 1.0),
                                blurRadius: 4.0,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            backgroundColor: Colors.blue[500],
                            child: IconButton(
                              icon: const Icon(
                                Icons.pin_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () async {
                                setState(() {
                                  showContainer = !showContainer;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.1,
                          child: Column(
                            children: [
                              StreamBuilder<RecordingDisposition>(
                                builder: (context, snapshot) {
                                  final duration = snapshot.hasData
                                      ? snapshot.data!.duration
                                      : Duration.zero;
                                  return Text('${duration.inSeconds} s');
                                },
                                stream: recorder.onProgress,
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
                                  backgroundColor: Colors.blue[500],
                                  child: IconButton(
                                    icon: Icon(
                                      recorder.isRecording
                                          ? Icons.stop
                                          : Icons.mic,
                                      color: Colors.white,
                                    ),
                                    onPressed: () async {
                                      if (recorder.isRecording) {
                                        String url = await stop('', context);
                                        await db.sendTextToChatRoom(
                                            url, id, context, 'audio');
                                      } else {
                                        await record();
                                      }
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  messageTile(var data) {
    String type;
    if (data['type'] == null) {
      type = 'text';
    } else {
      type = data['type'];
    }
    String email =
        Provider.of<UserProvider>(context, listen: false).email ?? "";
    bool x = data['sender'].toString().compareTo(email) == 0;
    return Container(
      alignment: x ? Alignment.centerRight : Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: type == 'text'
          ? Container(
              decoration: BoxDecoration(
                color: x ? Colors.grey[200] : Colors.blue[600],
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8),
              padding: const EdgeInsets.all(12.0),
              child: Text(
                data['text'].toString(),
                style: TextStyle(
                  color: x ? Colors.black : Colors.white,
                ),
              ),
            )
          : (type == 'img'
              ? GestureDetector(
                  onLongPress: () async {
                    await savePickImage.saveImage(data['text']);
                  },
                  onTap: () {
                    savePickImage.openImage(data['text'], context);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    height: MediaQuery.of(context).size.height * 0.3,
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        data['text'],
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                )
              : (type == 'audio'
                  ? Container(
                      decoration: BoxDecoration(
                        color: x ? Colors.grey[200] : Colors.blue[600],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      height: MediaQuery.of(context).size.height * 0.1,
                      width: MediaQuery.of(context).size.width * 0.7,
                      child: AudioPlayerWidget(url: data['text'], curUser: x),
                    )
                  : GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoPlayerWidget(
                                url: data['text'], currUser: x),
                          ),
                        );
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.2,
                        width: MediaQuery.of(context).size.width * 0.2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.black,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        // child: VideoPlayerWidget(
                        //   url: data['text'],
                        //   currUser: x,
                        // ),
                      ),
                    ))),
    );
  }
}
