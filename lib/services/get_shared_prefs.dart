import 'package:shared_preferences/shared_preferences.dart';

class GetSharedPrefs {
  String loggedInKey = 'isLoggedIn';
  String usernameKey = 'username';
  String emailKey = 'email';
  String passwordKey = 'password';
  Future setIsLogIn(bool x) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(loggedInKey, x);
  }

  Future setUsername(String x) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(usernameKey, x);
  }

  Future setEmail(String x) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(emailKey, x);
  }

  Future getIsLogIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loggedInKey);
  }

  Future getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(usernameKey);
  }

  Future getEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(emailKey);
  }
}
