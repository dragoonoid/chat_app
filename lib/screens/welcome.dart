import 'package:chatapp/model/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Welcome extends StatefulWidget {
  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  bool? isLoggedIn=false;

  @override
  void didChangeDependencies() {
    // Provider.of<UserProvider>(context).getDetailsFromDevice();
    // isLoggedIn=Provider.of<UserProvider>(context).isLoggedIn;
    super.didChangeDependencies();
  }
//(isLoggedIn!=null && isLoggedIn==true)?:
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width * 1,
                child: Image.asset(
                  "images/chat_img.jpg",
                  fit: BoxFit.cover,
                ),
                //child: Image.asset("images/chat2.png",fit: BoxFit.cover,),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Hey! Welcome',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const Text(
              'We are an online end to end encrypted chat application',
              style: TextStyle(fontSize: 16,color: Colors.grey),
            ),
            const SizedBox(
              height: 15,
            ),
            button(
              c: Colors.blue[600],
              context: context,
              t: 'Get Started',
              func: "up",
              textColor: Colors.white,
            ),
            const SizedBox(
              height: 15,
            ),
            button(
              c: Colors.white,
              context: context,
              t: 'Already have an account.',
              func: "in",
              textColor: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}

button(
    {required Color? c,
    required BuildContext context,
    required String t,
    required String func,
    required Color textColor}) {
  return Center(
    child: GestureDetector(
      onTap: () {
        if (func == 'in') {
          Navigator.of(context).pushNamed('/signin');
        } else {
          Navigator.of(context).pushNamed('/signup');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: c,
        ),
        height: 40,
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Center(
          child: Text(
            t,
            style: TextStyle(color: textColor,),
          ),
        ),
      ),
    ),
  );
}
