import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StorageService {
  StorageService(this._storage);

  final FirebaseStorage _storage;
  final _uuid = const Uuid();

  Future<String> uploadCropImage(File file) async {
    final ref = _storage.ref('crop_images/${_uuid.v4()}.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
