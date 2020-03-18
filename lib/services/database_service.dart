import 'dart:io';

import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:chat_app/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

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

  Future<bool> createChat(
      BuildContext context, String name, File file, List<String> users) async {
    String imageUrl = await Provider.of<StorageService>(context, listen: false)
        .uploadChatImage(null, file);

    DocumentReference chatDoc = await chatRef.add({
      'name': name,
      'immageUrl': imageUrl,
      'recentMessage': 'Chat created',
      'recentSender': '',
      'recentTimestam': Timestamp.now(),
    });
    final String chatId = chatDoc.documentID;
    List<String> memberIds = [];
    Map<String, dynamic> memberInfo = {};
    Map<String, dynamic> readStatus = {};

    for(String userId in users){
      memberIds.add(userId);

      User user = await getUser(userId);
      Map<String, dynamic> userMap = {
        'name': user.name,
        'email': user.email,
        'toke': user.token
      };
      memberInfo[userId] = userMap;

      readStatus[userId] = false;
    }

  }
}
