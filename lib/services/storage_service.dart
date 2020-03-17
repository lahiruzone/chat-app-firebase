import 'dart:io';

import 'package:chat_app/utilities/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';

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
  }
}
