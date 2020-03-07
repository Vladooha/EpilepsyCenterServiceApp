import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frontend/bloc/chat/chatBloc.dart';
import 'package:frontend/bloc/chat/chatBlocEvent.dart';
import 'package:frontend/bloc/chat/chatBlocState.dart';
import 'package:frontend/bloc/user/userBloc.dart';
import 'package:frontend/model/chat/chat.dart';
import 'package:frontend/model/chat/chatMessage.dart';
import 'package:frontend/model/user/user.dart';
import 'package:frontend/service/ioc/blocContainerService.dart';
import 'package:frontend/view/uiparts/drawerMenuPart.dart';
import 'package:uuid/uuid.dart';

import 'chatMessageView.dart';

class ChatView extends StatefulWidget {
  final UserBloc userBloc = BlocContainerService.instance.getAndInit(UserBloc.BLOC_NAME);
  final ChatBloc chatBloc = BlocContainerService.instance.getAndInit(ChatBloc.BLOC_NAME);

  Chat _chat;
  User _contactUser;
  User _currentUser;

  ChatView(this._chat, this._contactUser) {
    _currentUser = userBloc.cachedUser;
  }

  @override
  State<StatefulWidget> createState() =>
      ChatViewState(
          _chat,
          _contactUser,
          _currentUser
      );
}

class ChatViewState extends State<ChatView> with DrawerMenuPart {
  static const int MAX_MESSAGE_LENGTH = 999;

  Chat _chat;
  User _contactUser;
  User _currentUser;

  TextEditingController _messageController = TextEditingController();

  ChatViewState(
      this._chat,
      this._contactUser,
      this._currentUser);

  @override
  void initState() {
    super.initState();

    widget.chatBloc.eventListener.add(OpenChat(_chat));
  }

  @override
  Widget build(BuildContext context) {
    String chatName = _contactUser.name + " " + _contactUser.surname;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          chatName
        ),
      ),
      drawer: createDrawerMenuPart(context),
      body: Column(
        children: <Widget>[
          Expanded(
              child: StreamBuilder<ChatBlocState>(
                initialData: widget.chatBloc.getLastChatMessages(_chat),
                stream: widget.chatBloc.getChatMessages(_chat),
                builder: (context, snapshot) {
                  print('ChatView: Builder enbaled');
                  print('ChatView: Connection state - ${snapshot.connectionState}');
                  switch (snapshot.connectionState) {
                    case ConnectionState.done:
                    case ConnectionState.active:
                      ChatBlocState state = snapshot.data;
                      if (state is GotChat) {
                        print('Chat ${state.chatMessageList[0].chatId} loaded!');
                        List<ChatMessage> chatMessageList = state.chatMessageList;

                        return ListView.builder(
                          itemCount: chatMessageList.length,
                          itemBuilder: (buildContext, number) {
                            return ChatMessageView(chatMessageList[number], _contactUser, _currentUser);
                          },
                        );
                      }

                      // TODO: Implement chat loading
                      return SizedBox();
                      break;
                    default:
                      // TODO: Implement chat loading
                      return SizedBox();
                      break;
                  }
                },
              )
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            height: 60,
            child: Row(
                children: [
                  Expanded(
                      child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                              hintText: 'Введите сообщение'
                          )
                      )
                  ),
                  IconButton(
                      iconSize: 48,
                      padding: EdgeInsets.all(6.0),
                      onPressed: _sendMessage,
                      icon: Image(
                        image: AssetImage('assets/image/message.png'),
                      )
                  )]
            ),
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    super.dispose();

    widget.chatBloc.eventListener.add(CloseChat(_chat));
  }

  _sendMessage() {
    // TODO: Implement file uploading

    String message = _messageController.text.trim();
    message = message.length > MAX_MESSAGE_LENGTH
      ? message.substring(0, MAX_MESSAGE_LENGTH)
      : message;

    var time = DateTime.now();

    ChatMessage newMessage = ChatMessage(
      time.millisecondsSinceEpoch.toString() + "-" + Uuid().v4(),
      _currentUser.id,
      _chat.id,
      message,
      time,
    );

    widget.chatBloc.eventListener.add(SendMessage(newMessage));
  }
}

class ChatViewRoute extends CupertinoPageRoute {
  ChatViewRoute(Chat chat, User contactUser)
      : super(builder: (BuildContext context) => ChatView(chat, contactUser));
}
