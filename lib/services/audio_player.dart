import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/foundation/key.dart';

// ignore: must_be_immutable
class AudioPlayerWidget extends StatefulWidget {
  final String url;
  final bool curUser;
  const AudioPlayerWidget({Key? key, required this.url, required this.curUser})
      : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final audioPlayer = AudioPlayer();
  bool isAudioPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

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
    return Row(
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
            color: widget.curUser ? Colors.black : Colors.white,
          ),
        ),
        Expanded(
          child: Slider(
            min: 0,
            max: duration.inSeconds.toDouble(),
            value: position.inSeconds.toDouble(),
            thumbColor: widget.curUser ? Colors.black : Colors.white,
            activeColor: widget.curUser ? Colors.black : Colors.white,
            inactiveColor: widget.curUser ? Colors.white : Colors.black,
            onChanged: (val) async {
              final position = Duration(seconds: val.toInt());
              await audioPlayer.seek(position);
            },
          ),
        )
      ],
    );
  }
}
