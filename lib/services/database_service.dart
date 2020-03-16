import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  Future<User> getUser(String userId) async {
    DocumentSnapshot userDoc = await usersRef.document(userId).get();
    return User.fromDoc(userDoc);
  }

  Future<List<User>> searchUser(String currentUserID, String name) async {
    QuerySnapshot usersSnap = await usersRef
        .where('name', isGreaterThanOrEqualTo: name)
        .getDocuments();
    List<User> users = [];
    usersSnap.documents.forEach((doc) {
      User user = User.fromDoc(doc);
      if (user.id != currentUserID) {
        users.add(user);
      }
    });
    return users;
  }
}
