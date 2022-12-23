import 'dart:io';
import 'package:chatapp/screens/detail_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class SaveAndPickImage {
  Future pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg'],
    );
    return result;
  }

  Future pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );
    return result;
  }

  Future pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mkv', 'mov'],
    );
    return result;
  }

  openImage(String url, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DetailImageScreen(url: url),
      ),
    );
  }
  // Future<bool> _requestPermission(Permission permission) async {
  //   if (await permission.isGranted) {
  //     return true;
  //   } else {
  //     var result = await permission.request();
  //     if (result == PermissionStatus.granted) {
  //       return true;
  //     }
  //   }
  //   return false;
  // }


  Future saveImage(String url) async {
    debugPrint('save gallery called');
    final appStorage = await getTemporaryDirectory();
    final file = File('${appStorage.path}/123');
    //final newPath = 'chat app/images';

    final response = await Dio().get(url,
        options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            receiveTimeout: 0),
        );
    debugPrint(response.data.toString());
    debugPrint(file.path);
    final raf = file.openSync(mode: FileMode.write);
    raf.writeFromSync(response.data);
    await raf.close();
    debugPrint('all ok');
  }

  Future saveVideo(String url) async {
    await GallerySaver.saveVideo(url, albumName: 'Chat App/video');
  }
}
