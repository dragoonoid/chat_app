import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  final bool currUser;
  const VideoPlayerWidget({Key? key, required this.url, required this.currUser})
      : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  late Future _initializeFunc;
  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.url);
    _initializeFunc = _controller.initialize();
    _controller.setLooping(true);
    _controller.setVolume(1);
    // ..addListener(() => setState(() {}))
    // ..setLooping(true)
    // ..initialize();
    // .then((_) {
    //   _controller.play();
    // });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _initializeFunc,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              //aspectRatio: _controller.value.aspectRatio,
              return GestureDetector(
                onTap: (){
                  if(_controller.value.isPlaying){
                    setState(() {
                      _controller.pause();
                    });
                  }
                  else{
                    _controller.play();
                  }
                },
                child: VideoPlayer(_controller),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          }),
    );
  }
}
