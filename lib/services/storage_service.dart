import 'dart:io';

import 'package:chat_app/utilities/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  Future<File> _compressImage(String imageId, File image) async {
    final tempDir =
        await getTemporaryDirectory(); //give access to the local file system
    final path = tempDir.path;
    File compressedImageFile = await FlutterImageCompress.compressAndGetFile(
        image.absolute.path, '$path/img_$imageId.jpg',
        quality: 70);
    return compressedImageFile;
  }

  Future<String> _uploadImage(String path, String imageId, File image) async {
    StorageUploadTask uploadTask = storageRef.child(path).putFile(image);
    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;
    String downloadUrl = await storageSnap.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> uploadChatImage(String url, File imageFile) async {
    String imageId = Uuid().v4(); //Randon alpanumeric string
    File image = await _compressImage(imageId, imageFile);

    //for change image you need image id, there for extract id
    if (url != null) {
      RegExp exp = RegExp(r'chat_(.*).jpg');
      imageId = exp.firstMatch(url)[1];
    }

    String downloadUrl =
        await _uploadImage('image/chats/chat_$imageId.jpg', imageId, imageFile);

    return downloadUrl;
  }

  Future<String> uploadMessageImage(File imageFile) async {
    String imageId = Uuid().v4(); //Randon alpanumeric string
    File image = await _compressImage(imageId, imageFile);

    String downloadUrl = await _uploadImage(
        'image/messages/message_$imageId.jpg', imageId, imageFile);

    return downloadUrl;
  }
}
