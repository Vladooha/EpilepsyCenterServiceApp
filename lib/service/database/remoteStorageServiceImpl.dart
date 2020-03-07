import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:frontend/bloc/user/userBloc.dart';
import 'package:frontend/service/ioc/blocContainerService.dart';
import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';

import 'remoteStorageService.dart';

class RemoteStorageServiceImpl implements RemoteStorageService {
  UserBloc userBloc = BlocContainerService.instance.getAndInit(UserBloc.BLOC_NAME);

  RemoteStorageServiceImpl() {
    print("Remote storage service setted up!");
    GetIt.instance.registerSingleton<RemoteStorageService>(this, signalsReady: true);
  }

  @override
  Future<StorageTaskSnapshot> uploadFile(
      File file,
      {
        String fileName,
        num timeoutSec
      }) async {
    timeoutSec = timeoutSec ?? 10;
    fileName = fileName ?? Uuid().v1();
    String uid = userBloc.lastCurrentUserData.user.id;
    String urlPath = fileName.startsWith('/${uid}')
        ? '/${fileName}'
        : '/${uid}/${fileName}';

    return FirebaseStorage.instance
        .ref()
        .child(urlPath)
        .putFile(file)
        .onComplete
        .timeout(Duration(seconds: timeoutSec));
  }

  @override
  Future<String> getFileUrl(
      String path,
      {
        num timeoutSec
      }) async {
    String uid = userBloc.lastCurrentUserData.user.id;
    String urlPath = path.startsWith('/${uid}')
        ? '/${path}'
        : '/${uid}/${path}';
    timeoutSec = timeoutSec ?? 10;

    return FirebaseStorage.instance
        .ref()
        .child(urlPath)
        .getDownloadURL()
        .then((value) => value.toString())
        .timeout(Duration(seconds: timeoutSec));
  }

  @override
  Future<FileDownloadTaskSnapshot> downloadFile(
      String path,
      File file,
      {
        num timeoutSec
      }) async {
    timeoutSec = timeoutSec ?? 10;
    String uid = userBloc.lastCurrentUserData.user.id;
    String urlPath = path.startsWith('/${uid}')
      ? '/${path}'
      : '/${uid}/${path}';

    return FirebaseStorage.instance
        .ref()
        .child(urlPath)
        .writeToFile(file)
        .future
        .timeout(Duration(seconds: timeoutSec));
  }
}