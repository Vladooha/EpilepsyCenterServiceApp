import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/bloc/user/userBloc.dart';
import 'package:frontend/bloc/user/userBlocEvent.dart';
import 'package:frontend/bloc/user/userBlocState.dart';
import 'package:frontend/model/chat/chat.dart';
import 'package:frontend/model/user/user.dart';
import 'package:frontend/service/ioc/blocContainerService.dart';
import 'package:frontend/view/screens/chat/chatView.dart';

class ChatListPosition extends StatelessWidget {
  static const int MESSAGE_MAX_LENGTH = 30;
  static const String MESSAGE_OWNER_DELIM  = ": ";

  UserBloc userBloc = BlocContainerService.instance.getAndInit(UserBloc.BLOC_NAME);

  Chat _chat;
  User _currentUser;
  User _contactUser;
  String _contactUserId;

  ChatListPosition(this._chat) {
    _currentUser = userBloc.cachedUser;
    _contactUserId = _getContactId(_currentUser.id, _chat);

    _whenWidgetBuilt(() {
      print('ChatList - Sending GetUser...');
      userBloc.eventListener.add(GetUser(id: _contactUserId));
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserData>(
        stream: userBloc.userData,
        builder: (context, snapshot) {
          String chatName = "Загрузка...";
          bool isCorrectUser = !snapshot.hasError && snapshot.hasData;
          if (isCorrectUser) {
            var contactUser = snapshot.data.user;

            if (contactUser != null && contactUser.id == _contactUserId) {
              _contactUser = contactUser;
              chatName = _contactUser.name + " " + _contactUser.surname;
            }
          }

          return Card(
            child: ListTile(
              isThreeLine: true,
              leading: _createAvatar(_contactUser),
              title: Text(chatName),
              subtitle: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: _getMessageOwner(),
                      style: TextStyle(
                        color: Colors.grey
                      )
                    ),
                    TextSpan(
                      text: _chat.lastMessage.message,
                    )
                  ]
                ),
                overflow: TextOverflow.fade,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              onTap: () {
                if (isCorrectUser) {
                  Navigator
                      .of(context)
                      .push(ChatViewRoute(_chat, _contactUser));
                }
              },
            ),
          );
        }
    );
  }

  String _getMessageOwner() {
    String message = _chat.lastMessage.message;
    if (message != null) {
      bool isMine = _chat.lastMessage.authorId == _currentUser.id;
      return isMine ? "Вы" : _contactUser.name;
    } else {
      return "";
    }
  }

  String _getContactId(String currentUserId, Chat chat) {
    return currentUserId == chat.patientId
        ? chat.doctorId
        : chat.patientId;
  }

  void _whenWidgetBuilt(Function fun) {
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      fun.call();
    });
  }

  Widget _createAvatar(User user) {
    return Container(
      width: 40.0,
      height: 40.0,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
              fit: BoxFit.fill,
              image: user.avatar
          )
      ),
    );
  }
}
