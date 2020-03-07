import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:frontend/model/user/userMetainfo.dart';
import 'package:frontend/model/user/userPrivate.dart';

class User {
  String id;
  String name;
  String surname;
  List<String> roles = [];
  String avatarUrl;
  ImageProvider<dynamic> _avatar;
  UserPrivate _privateInfo;
  UserMetainfo _metainfo;
  FirebaseUser _firebaseUser;

  User(
    this.id,
    {
      this.name,
      this.surname,
      this.avatarUrl,
      this.roles,
      UserPrivate privateInfo,
      UserMetainfo metainfo,
      FirebaseUser firebaseUser
    }) {
    _avatar = this.avatarUrl != null
        ? Image.network(this.avatarUrl).image
        : AssetImage('assets/image/cross.png');

    this.privateInfo = privateInfo;
    this.metainfo = metainfo;
    this.firebaseUser = firebaseUser;
  }

  ImageProvider<dynamic> get avatar => _avatar;

  Future<bool> updateAvatar([String avatarUrl]) {
    if (avatarUrl != null) {
      this.avatarUrl = avatarUrl;
    }

    if (this.avatarUrl != null) {
      _avatar = Image
          .network(this.avatarUrl)
          .image;
    }
  }

  UserPrivate get privateInfo => _privateInfo;

  set privateInfo(UserPrivate value) {
    if (value != null && this.id == value.id) {
      _privateInfo = value;
    }
  }

  UserMetainfo get metainfo => _metainfo;

  set metainfo(UserMetainfo value) {
    if (value != null && this.id == value.id) {
      _metainfo = value;
    }
  }

  FirebaseUser get firebaseUser => _firebaseUser;

  set firebaseUser(FirebaseUser value) {
    if (value != null && this.id == value.uid) {
      _firebaseUser = value;
    }
  }
}