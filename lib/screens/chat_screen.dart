import 'dart:async';
import 'dart:io';

import 'package:chat_app/models/chat_model.dart';
import 'package:chat_app/models/message_model.dart';
import 'package:chat_app/models/user_data.dart';
import 'package:chat_app/services/database_service.dart';
import 'package:chat_app/services/storage_service.dart';
import 'package:chat_app/utilities/constants.dart';
import 'package:chat_app/widgets/message_buble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final Chat chat;

  const ChatScreen({this.chat});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageControlle = TextEditingController();
  Timer _readTimer;
  DatabaseService _databaseService;
  bool _isComposingMessage = false;

  @override
  void initState() {
    super.initState();
    _databaseService = Provider.of<DatabaseService>(context, listen: false);
    _databaseService.setChatRead(context, widget.chat, true);

    // call readMessage function every two secnds
    // _readTimer = Timer.periodic(Duration(seconds: 2), (_) {
    //   _databaseService.setChatRead(context, widget.chat, true);
    // });

    //now doing this wrapping scafild with WillPopScope widget
  }

  _buildMessageTF() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
                icon: Icon(
                  Icons.photo,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () async {
                  File imageFile =
                      await ImagePicker.pickImage(source: ImageSource.gallery);
                  if (imageFile != null) {
                    String imageUrl = await Provider.of<StorageService>(context,
                            listen: false)
                        .uploadMessageImage(imageFile);
                    _sendMessage(null, imageUrl);
                  }
                }),
          ),
          Expanded(
              child: TextField(
            controller: _messageControlle,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (message) {
              setState(() {
                _isComposingMessage = message.isNotEmpty;
              });
            },
            decoration: InputDecoration.collapsed(hintText: 'Send a Message'),
          )),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => _isComposingMessage
                    ? _sendMessage(_messageControlle.text, null)
                    : null),
          ),
        ],
      ),
    );
  }

  _sendMessage(String text, String imageUrl) async {
    print('Send msg 1111111111');
    if ((text != null && text.trim().isNotEmpty) || (imageUrl != null)) {
      if (imageUrl == null) {
        print('Send msg 111111111122222222222');

        //send text message
        _messageControlle.clear();
        setState(() => _isComposingMessage = false);
      }
    }
    Message message = Message(
        senderId: Provider.of<UserData>(context, listen: false).curretUserId,
        text: text,
        imageUrl: imageUrl,
        timestamp: Timestamp.now());
    _databaseService.sendChatMessage(widget.chat, message);
  }

  _buildMessageStream() {
    return StreamBuilder(
        stream: chatRef
            .document(widget.chat.id)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            print('NOOOOOOOOOOOOOO data');
            return SizedBox.shrink();
          }
          return Expanded(
              child: GestureDetector(
            //remove keyboard when tap on massges
            onTap: () => Focus.of(context).unfocus(),
            child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              physics: AlwaysScrollableScrollPhysics(),
              reverse: true,
              children: _buildMessageBubbles(snapshot),
            ),
          ));
        });
  }

  List<MessageBubble> _buildMessageBubbles(AsyncSnapshot<QuerySnapshot> messages){
    List<MessageBubble> messageBubbles = [];
    messages.data.documents.forEach((doc){
      Message message = Message.fromDoc(doc);
      MessageBubble messageBubble = MessageBubble(chat: widget.chat,message: message,);
      messageBubbles.add(messageBubble);
    });
    return messageBubbles;

  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //when user click back this function will be called
      onWillPop: () {
        _databaseService.setChatRead(context, widget.chat, true);
        return Future.value(true);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.chat.name),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildMessageStream(),
              Divider(
                height: 1.0,
              ),
              _buildMessageTF(),
            ],
          ),
        ),
      ),
    );
  }
}
