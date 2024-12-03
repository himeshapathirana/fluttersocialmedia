import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:socialmediaf/features/storage/domain/storage_repo.dart';
import 'dart:typed_data';

class FirebaseStorageRepo implements StorageRepo {
  final FirebaseStorage storage = FirebaseStorage.instance;
  @override
  Future<String?> uploadProfileImageMobile(String path, String fileName) {
    return _uploadFile(path, fileName, "profile_images");
  }

  @override
  Future<String?> uploadProfileImageWeb(Uint8List fileBytes, String fileName) {
    return _uploadFileBytes(fileBytes, fileName, "profile_images");
  }

  //mobile platforms(applying files)
  Future<String?> _uploadFile(
      String path, String fileName, String folder) async {
    try {
      final file = File(path);

      final storageRef = storage.ref().child('$folder/$fileName');
      final uploadTask = await storageRef.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<String?> _uploadFileBytes(
      Uint8List fileBytes, String fileName, String folder) async {
    try {
      final storageRef = storage.ref().child('$folder/$fileName');
      final uploadTask = await storageRef.putData(fileBytes);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }
}
