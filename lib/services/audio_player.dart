import 'package:audioplayers/audioplayers.dart';
import 'package:chatapp/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class AudioPlayerWidget extends StatefulWidget {
  final String url;
  final bool curUser;
  final String time;
  const AudioPlayerWidget(
      {Key? key, required this.url, required this.curUser, required this.time})
      : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final audioPlayer = AudioPlayer();
  bool isAudioPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  var theme;
  @override
  void initState() {
    audioPlayer.onPlayerStateChanged.listen((event) {
      setState(() {
        isAudioPlaying = event == PlayerState.PLAYING;
      });
    });
    audioPlayer.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });
    });
    audioPlayer.onAudioPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    theme = Provider.of<ThemeProvider>(context);
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () async {
                if (isAudioPlaying) {
                  await audioPlayer.pause();
                } else {
                  await audioPlayer.play(widget.url);
                }
                setState(() {
                  isAudioPlaying = !isAudioPlaying;
                });
              },
              icon: Icon(
                isAudioPlaying ? Icons.pause : Icons.play_arrow,
                color:
                    widget.curUser ? theme.audioSendPlay : theme.audioRecePlay,
              ),
            ),
            Expanded(
              child: Slider(
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                thumbColor:
                    widget.curUser ? theme.audioSendDot : theme.audioReceDot,
                activeColor: widget.curUser
                    ? theme.audioSendActive
                    : theme.audioReceActive,
                inactiveColor: widget.curUser
                    ? theme.audioSendInactive
                    : theme.audioReceInactive,
                onChanged: (val) async {
                  final position = Duration(seconds: val.toInt());
                  await audioPlayer.seek(position);
                },
              ),
            )
          ],
        ),
        Text(
          widget.time,
          textAlign: TextAlign.end,
          style: TextStyle(
            color: widget.curUser ? theme.sendTime : theme.receiveTime,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
