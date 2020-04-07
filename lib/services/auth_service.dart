import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/utilities/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Stream<FirebaseUser> get user => _auth.onAuthStateChanged;

  Future<void> signup(String name, String email, String password) async {
    try {
      AuthResult authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

      if (authResult.user != null) {
        String token = await _firebaseMessaging.getToken();
        usersRef.document(authResult.user.uid).setData({
          'name': name,
          'email': email,
          'token': token,
        });
      }
    } on PlatformException catch (err) {
      throw (err);
    }
  }

  Future<void> login(String email, String password) async {
    try {
      AuthResult _authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on PlatformException catch (err) {
      throw (err);
    }
  }

  Future<void> logout() async {
    await removeToken();
    Future.wait([
      _auth.signOut(),
    ]);
  }

  Future<void> removeToken() async {
    final curerentUser = await _auth.currentUser();
    await usersRef.document(curerentUser.uid)
        //marge: true -> update only token field
        .setData({'token': ''}, merge: true);
  }

  Future<void> updateToken() async {
    print('UUUUUUPDATING TOKEN');
    final currentUser = await _auth.currentUser();
    final token = await _firebaseMessaging.getToken();
    final userDoc = await usersRef.document(currentUser.uid).get();
    if (userDoc.exists) {
      print('1UUUUUUPDATING TOKEN');
      User user = User.fromDoc(userDoc);
      if (token != user.token) {
        print('2UUUUUUPDATING TOKEN');
        usersRef
            .document(currentUser.uid)
            .setData({'token': token}, merge: true);
      }
    }
  }
}
