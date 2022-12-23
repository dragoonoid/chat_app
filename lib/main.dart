import 'package:chatapp/model/user_provider.dart';
import 'package:chatapp/screens/all_chat_screen.dart';
import 'package:chatapp/screens/conversation.dart';
import 'package:chatapp/screens/search_user.dart';
import 'package:chatapp/screens/signin.dart';
import 'package:chatapp/screens/signup.dart';
import 'package:chatapp/screens/welcome.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/themes/app_theme.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
//import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChangeNotifierProvider(
    create: (context) => UserProvider(),
    child: ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? login = false;
  helper() async {
    await Provider.of<UserProvider>(context, listen: false)
        .getDetailsFromDevice();
    await Provider.of<ThemeProvider>(context, listen: false)
        .getThemeFromDevice();

    var x = Provider.of<UserProvider>(context, listen: false).isLoggedIn;
    if (x != null) {
      setState(() {
        login = x;
      });
    }
  }

  @override
  void didChangeDependencies() async {
    await helper();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //TODO use future builder
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/signin': (context) => const SignIn(),
        '/signup': (context) => const SignUp(),
        '/all_chat_screen': (context) => const AllChatScreen(),
        '/wel': (context) => Welcome(),
        '/search_user': (context) => const SearchUser(),
        //'/conversation': (context) => const Conversation()
      },
      home: login == true ? const AllChatScreen() : Welcome(),
    );
  }
}
