import 'package:flutter/cupertino.dart';

class ChatMessage {
  String id;
  String chatId;
  String message;
  String authorId;
  DateTime date;
  List<String> imageUrlList = [];
  List<ImageProvider<dynamic>> _imageList = [];

  ChatMessage(
      this.id,
      this.authorId,
      this.chatId,
      this.message,
      this.date,
      {
        this.imageUrlList,
      }
  ) {
    if (this.imageUrlList != null) {
      _imageList = [];
      imageUrlList.forEach((url) => _imageList.add(
          Image.network(url).image));
    }
  }
}