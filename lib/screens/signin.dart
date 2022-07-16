import 'package:chatapp/model/user_provider.dart';
import 'package:chatapp/services/auth.dart';
import 'package:chatapp/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/get_shared_prefs.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  final key = GlobalKey<FormState>();

  AuthFirebase auth = AuthFirebase();
  GetSharedPrefs prefs=GetSharedPrefs();
  Database db=Database();
  bool isLoading = false;
  late QuerySnapshot snapshot;
  var data=null;

  signIn() async{
    if (key.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      dynamic x=await auth.signInEmail(email.text, password.text);
      if(x==null){
        setState(() {
          isLoading=false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid User')));
      }
      else{
        await db.getUserByEmail(email.text).then((value) => snapshot=value);
        //print(data[0]['email']);
        data = snapshot.docs.map((doc) => doc.data()).toList();
        print(data);
        await prefs.setEmail(data[0]['email']);
        await prefs.setUsername(data[0]['username']);
        await prefs.setIsLogIn(true);
        await Provider.of<UserProvider>(context,listen: false).getDetailsFromDevice();
        Navigator.of(context).pushNamedAndRemoveUntil('/all_chat_screen', (route) => false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const SizedBox(
              child: Center(child: CircularProgressIndicator()),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      const Text(
                        'Login',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Form(
                        key: key,
                        child: Column(
                          children: [
                            textEdittingField(
                              ' Email',
                              email,
                              (a) {
                                return RegExp(
                                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                        .hasMatch(a.toString())
                                    ? null
                                    : 'Please enter valid email';
                              },
                              false,
                            ),
                            textEdittingField(
                              ' Password',
                              password,
                              (a) {
                                String s = a.toString();
                                if (s.isEmpty || s.length < 8) {
                                  return 'Please enter a valid password of atleast 8 characters';
                                }
                                return null;
                              },
                              true,
                            ),
                          ],
                        ),
                      ),
                      button(
                          c: Colors.amber[300],
                          context: context,
                          t: 'Login ',
                          route: ()=>signIn(),
                          weight: FontWeight.bold,
                          textColor: Colors.black),
                      button(
                          c: Colors.white10,
                          context: context,
                          t: 'Dont have an account? Create One',
                          route: () => Navigator.of(context)
                              .pushReplacementNamed('/signup'),
                          weight: FontWeight.bold,
                          textColor: Colors.grey),
                      const SizedBox(
                        height: 18,
                      ),
                      const Divider(
                        color: Colors.grey,
                        thickness: 0.5,
                      ),
                      const Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      button(
                          c: Colors.white,
                          context: context,
                          t: 'Login with Google    ',
                          route: () =>
                              Navigator.of(context).pushReplacementNamed('/'),
                          weight: FontWeight.bold,
                          textColor: Colors.black),
                      button(
                          c: Colors.white,
                          context: context,
                          t: 'Login with Facebook',
                          route: () =>
                              Navigator.of(context).pushReplacementNamed('/'),
                          weight: FontWeight.bold,
                          textColor: Colors.black),
                      button(
                          c: Colors.white,
                          context: context,
                          t: 'Login with Apple     ',
                          route: () =>
                              Navigator.of(context).pushReplacementNamed('/'),
                          weight: FontWeight.bold,
                          textColor: Colors.black),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

textEdittingField(
    String hint, dynamic controller, dynamic validate, bool obscureText) {
  return Container(
    margin: const EdgeInsets.fromLTRB(0, 15, 0, 0),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12)),
    child: TextFormField(
      obscureText: obscureText,
      validator: validate,
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        border: InputBorder.none,
        hintStyle: const TextStyle(color: Colors.black54),
      ),
    ),
  );
}

button(
    {required Color? c,
    required BuildContext context,
    required String t,
    required Function route,
    required FontWeight weight,
    required Color? textColor}) {
  return Center(
    child: GestureDetector(
      onTap: () => route(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: c,
        ),
        height: 40,
        margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
        child: Center(
          child: Text(
            t,
            style: TextStyle(color: textColor, fontWeight: weight),
          ),
        ),
      ),
    ),
  );
}
