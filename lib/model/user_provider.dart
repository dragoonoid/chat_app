import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class UserProvider with ChangeNotifier{
  String? username="";
  String? email="";
  String? password="";
  bool? isLoggedIn=false;
  String? imageUrl="";

  getDetailsFromDevice()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    username=prefs.getString('username');
    email=prefs.getString('email');
    isLoggedIn=prefs.getBool('isLoggedIn');
    imageUrl=prefs.getString('imageUrl');
    notifyListeners();
  }
}