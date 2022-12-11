import 'dart:io';

import 'package:chatapp/screens/detail_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

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
      allowedExtensions: ['mp4','mkv','mov'],
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

  Future saveImage(String url) async {
    //print('save gallery called');
    // final appStorage = await getTemporaryDirectory();
    // final file = File('${appStorage.path}/123');
    // final response = await Dio().get(
    //   url,
    //   options: Options(
    //       responseType: ResponseType.bytes,
    //       followRedirects: false,
    //       receiveTimeout: 0),
    // );
    //print(response.data.toString());
    // final raf = file.openSync(mode: FileMode.write);
    // raf.writeFromSync(response.data);
    // await raf.close();
    //print('all ok');
  }
}
