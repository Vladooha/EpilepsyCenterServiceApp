import 'package:flutter/material.dart';
import 'package:frontend/model/chat/chatMessage.dart';
import 'package:frontend/model/user/user.dart';

class ChatMessageView extends StatelessWidget {
  final User _currentUser;
  final User _contactUser;
  final ChatMessage _chatMessage;
  bool _isMine;

  ChatMessageView(this._chatMessage, this._contactUser, this._currentUser) {
    _isMine = _chatMessage.authorId == _currentUser.id;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        contentPadding: _isMine
            ? EdgeInsets.only(left: _getPaddingByMessageText(context), right: 10)
            : EdgeInsets.only(right: _getPaddingByMessageText(context), left: 10),
        isThreeLine: true,
        title: Text(
          _getMessageHeader(),
          textAlign: _isMine
              ? TextAlign.right
              : TextAlign.left,
          style: TextStyle(
              color: Colors.grey,
              fontSize: 14
          ),
        ),
        subtitle: Container(
          width: _getPaddingByMessageText(context),
          decoration: BoxDecoration(
            color: _isMine ? Colors.blue : Colors.grey[350],
            borderRadius: BorderRadius.only(
                topLeft: Radius.elliptical(15, 10),
                topRight: Radius.elliptical(15, 10),
                bottomLeft: Radius.elliptical(15, 10),
                bottomRight: Radius.elliptical(15, 10)
            ),
          ),
          child: Padding(
              padding: EdgeInsets.only(bottom: 5.0, top: 8.0, ),
              child: Text(
                  _chatMessage.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18
                  )
              )
          ),
        )
    );
  }

  _getMessageHeader() =>
      (_isMine ? "Вы" : _contactUser.name)
          + ", " + _chatMessage.date.toIso8601String();

  _getPaddingByMessageText(BuildContext context) {
    double minPadding = MediaQuery.of(context).size.width * 0.6;
    double realPadding =
        MediaQuery.of(context).size.width - _chatMessage.message.length * 2.0 + 10.0;

    return minPadding < realPadding || realPadding < 0
        ? minPadding
        : realPadding;
  }
}