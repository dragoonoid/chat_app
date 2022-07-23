import 'package:chatapp/services/auth.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/services/get_shared_prefs.dart';
import 'package:flutter/material.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController name = TextEditingController();
  final key = GlobalKey<FormState>();

  AuthFirebase auth = AuthFirebase();
  Database db = Database();
  GetSharedPrefs prefs = GetSharedPrefs();
  bool isLoading = false;
  signUp() async {
    if (key.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });
      var uid;
      await auth
          .signUpEmail(email.text, password.text)
          .then((value) => uid = value.userId);
      await db.publishUser(uid, email.text, password.text, name.text);
      await prefs.setEmail(email.text);
      await prefs.setIsLogIn(true);
      await prefs.setUsername(name.text);
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/all_chat_screen', (route) => false);
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
                        'Create an Account',
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
                              ' Username',
                              name,
                              (a) {
                                return a.toString().isEmpty ||
                                        a.toString().length < 4
                                    ? 'The username is invalid'
                                    : null;
                              },
                              false,
                            ),
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
                          t: 'Create Account',
                          route: () => signUp(),
                          weight: FontWeight.bold,
                          textColor: Colors.black),
                      button(
                          c: Colors.white10,
                          context: context,
                          t: 'Already have an account?',
                          route: () => Navigator.of(context)
                              .pushReplacementNamed('/signin'),
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
                              Navigator.of(context).pushReplacementNamed('/signin'),
                          weight: FontWeight.bold,
                          textColor: Colors.black),
                      button(
                          c: Colors.white,
                          context: context,
                          t: 'Login with Facebook',
                          route: () =>
                              Navigator.of(context).pushReplacementNamed('/signin'),
                          weight: FontWeight.bold,
                          textColor: Colors.black),
                      button(
                          c: Colors.white,
                          context: context,
                          t: 'Login with Apple     ',
                          route: () =>
                              Navigator.of(context).pushReplacementNamed('/signin'),
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
