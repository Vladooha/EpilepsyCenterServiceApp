import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

abstract class RemoteStorageService {
  Future<StorageTaskSnapshot> uploadFile(
      File file,
      { String fileName, num timeoutSec });

  Future<String> getFileUrl(
      String path,
      { num timeoutSec });

  Future<FileDownloadTaskSnapshot> downloadFile(
      String path, File file,
      { num timeoutSec});
}