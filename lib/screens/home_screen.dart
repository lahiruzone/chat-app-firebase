import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/models/user_data.dart';
import 'package:chat_app/screens/search_screen.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/utilities/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

_buildChat(Chat chat, String currentUserId) {
  print('>>>>>>>>>>>>>>>>>.');
  print(chat.imageUrl);
  print(chat.recentMessage);
  print(chat.name);
  final bool isRead = chat.readStatus[currentUserId];
  final TextStyle readStyle =
      TextStyle(fontWeight: isRead ? FontWeight.w400 : FontWeight.bold);
  return ListTile(
    leading: CircleAvatar(
      backgroundColor: Colors.white,
      radius: 28.0,
      backgroundImage: CachedNetworkImageProvider(chat.imageUrl),
    ),
    title: Text(
      chat.name,
      overflow: TextOverflow.ellipsis,
      style: readStyle,
    ),
    subtitle: chat.recentSender.isEmpty
        ? Text(
            'Chat Created',
            overflow: TextOverflow.ellipsis,
            style: readStyle,
          )
        : chat.recentMessage != null
            ? Text(
                '${chat.memberInfo[chat.recentSender]['name']}: ${chat.recentMessage}',
                overflow: TextOverflow.ellipsis,
                style: readStyle,
              )
            : Text(
                '${chat.memberInfo[chat.recentSender]['name']} sent an image',
                overflow: TextOverflow.ellipsis,
                style: readStyle),
    // trailing: Text(
    //   timeFormat.format(
    //     chat.recentTimeStamp.toDate(),
    //   ),
    //   style: readStyle,
    // ),
    // onTap: () => Navigator.push(
    //     context, MaterialPageRoute(builder: (_) => ChatScreen(chat),),),
  );
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserId = Provider.of<UserData>(context, listen: false)
        .curretUserId; //listen: false -> Not listen for changes

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: Provider.of<AuthService>(context, listen: false).logout),
        title: Text('Chats'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.add),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => SearchScreen())))
        ],
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('chats')
            .where('memberIds', arrayContains: currentUserId)
            .orderBy('recentTimeStamp', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView.separated(
                itemBuilder: (BuildContext context, int index) {
                  Chat chat = Chat.fromDoc(snapshot.data.documents[index]);
                  return _buildChat(chat, currentUserId);
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    thickness: 1.0,
                  );
                },
                itemCount: snapshot.data.documents.length);
          }
        },
      ),
    );
  }
}
