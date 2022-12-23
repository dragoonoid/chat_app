import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late bool isDarkTheme;

class ThemeProvider extends ChangeNotifier {
  Color? titleColor, subtitleColor,tileColor; //
  Color? searchBack, searchIcon; //
  Color? selectedIcon, unSelectedIcon; //
  Color? appBackColor; //
  Color? deleteColor; //
  Color? sendText, receiveText; //
  Color? sendTextBack, receiveTextBack; //
  Color? videoBack, videoPlay;
  Color? audioSendPlay, audioSendDot; //
  Color? audioSendActive, audioSendInactive; //
  Color? audioRecePlay, audioReceDot; //
  Color? audioReceActive, audioReceInactive; //
  Color? bottomBarBack;
  Color? sendTime,receiveTime;

  _change(bool isDark) {
    titleColor = isDark ? Colors.white : Colors.black;
    subtitleColor = isDark ? Colors.white54 : Colors.grey[500];
    deleteColor = isDark ? Colors.white : Colors.grey[500];
    tileColor=isDark?Colors.black12:Colors.white;

    appBackColor = isDark ? Colors.white12 : Colors.white;

    searchBack = isDark ? Colors.black54 : Colors.grey[100];
    searchIcon = isDark ? Colors.white70 : Colors.grey[500];

    selectedIcon = Colors.blue[500];
    unSelectedIcon = isDark ? Colors.white30 : Colors.grey[600];

    sendText = isDark ? Colors.white : Colors.black;
    receiveText = Colors.white;

    sendTextBack = isDark ? Colors.black12 : Colors.grey[100];
    receiveTextBack = Colors.blue[500];

    audioSendPlay = isDark ? Colors.white : Colors.black;
    audioSendDot = isDark ? Colors.white : Colors.black;
    audioSendActive = isDark ? Colors.white : Colors.black;
    audioSendInactive = isDark ? Colors.black : Colors.white;

    audioRecePlay = Colors.white;
    audioReceDot = Colors.white;
    audioReceActive = Colors.white;
    audioReceInactive = Colors.grey[100];

    videoBack = isDark ? Colors.black45 : Colors.black;
    videoPlay = Colors.white;

    bottomBarBack=isDark?Colors.black54:Colors.grey[50];

    sendTime=isDark?Colors.white54 : Colors.grey[500];
    receiveTime=Colors.white70;
  }
  isDark(){
    return isDarkTheme;
  }
  changeTheme() {
    isDarkTheme = !isDarkTheme;
    _change(isDarkTheme);
    notifyListeners();
    setThemeToDevice(isDarkTheme);
  }

  getThemeFromDevice() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkTheme = prefs.getBool('isDark') ?? false;
    _change(isDarkTheme);
  }

  setThemeToDevice(bool isDark) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDark', isDark);
  }
}
