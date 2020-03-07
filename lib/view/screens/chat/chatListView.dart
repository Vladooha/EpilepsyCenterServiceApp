import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:frontend/bloc/chat/chatBloc.dart';
import 'package:frontend/bloc/chat/chatBlocState.dart';
import 'package:frontend/model/chat/chat.dart';
import 'package:frontend/service/ioc/blocContainerService.dart';
import 'package:frontend/view/uiparts/drawerMenuPart.dart';
import 'package:frontend/view/uiparts/popupPart.dart';

import 'chatListPosition.dart';

class ChatListView extends StatelessWidget with DrawerMenuPart, PopupPart {
  ChatBloc _chatBloc = BlocContainerService.instance
      .getAndInit(ChatBloc.BLOC_NAME);

  @override
  Widget build(BuildContext context) {
    //createWarningPopup(context, "В данный момент находятся в разработке!");

    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Чаты"
        ),
      ),
      drawer: createDrawerMenuPart(context),
      body: StreamBuilder<ChatListBlocState>(
        initialData: _chatBloc.lastChatList,
        stream: _chatBloc.chatList,
        builder: (context, snapshot) {
          print('ChatListView: Building body...');

          var data = snapshot.data;
          if (data is GotChatList) {
            List<Chat> chatList = data.chatList;

            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: chatList.length,
              itemBuilder: (context, number) {
                var screenSize = MediaQuery.of(context).size;
                var chatPositionWidth = screenSize.width * 0.9;
                var chatPositionHeight = 80.0;

                return Container(
                  width: chatPositionWidth,
                  height: chatPositionHeight,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ChatListPosition(chatList[number])
                  )
                );
              }
            );
          } else if (data is GettingChatList){
            // TODO: Chat loading
            return Text("Загрузка...");
          } else {
            return Text("Ошибка");
          }
        }
      ),
    );
  }
}


class ChatListViewRoute extends CupertinoPageRoute {
  ChatListViewRoute() : super(builder: (BuildContext context) => ChatListView());
}