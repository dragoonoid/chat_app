import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class UserProvider with ChangeNotifier{
  String? username="";
  String? email="";
  String? password="";
  bool? isLoggedIn=false;

  getDetailsFromDevice()async{
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    username=prefs.getString('username');
    email=prefs.getString('email');
    isLoggedIn=prefs.getBool('isLoggedIn');
    print(isLoggedIn);
    print('hi');
    print(username);
    print(email);
    print(password);
    notifyListeners();
  }
}