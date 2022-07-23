import 'package:chatapp/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthFirebase {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  dynamic userFromFirebase(User? firebaseUser) {
    // reutrn AppUser
    print('firebase user');
    print(firebaseUser);
    return firebaseUser == null ? null : AppUser(firebaseUser.uid);
  }

  Future signInEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? firebaseUser = result.user;
      return userFromFirebase(firebaseUser);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
        return null;
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
        return null;
      }
    }
  }

  Future signUpEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? firebaseUser = result.user;
      return userFromFirebase(firebaseUser);
    } catch (e) {
      // ignore: avoid_print
      print(e);
      print('22222222');
    }
  }

  Future resetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      // ignore: avoid_print
      print(e);
      print('3333333');
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }
}
