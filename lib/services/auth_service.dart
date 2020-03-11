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
      AuthResult authResult = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      if (authResult.user != null) {
        String token = await _firebaseMessaging.getToken();
        usersRef.document(authResult.user.uid).setData({
          'name': name,
          'emai': email,
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

  Future<void> logout() {
    Future.wait([
      _auth.signOut(),
    ]);
  }
}
