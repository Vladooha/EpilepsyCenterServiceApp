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
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class Message {
  final String message;
  final String owner;
  final DateTime time;
  final bool isMine;

  Message(this.message, this.owner, this.time, this.isMine);
  
}

class ChatPreview extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChatViewState();
}

class ChatViewState extends State<ChatPreview> with DrawerMenuPart {
  static const int MAX_MESSAGE_LENGTH = 999;

  var messageController = BehaviorSubject<List<Message>>();
  List<Message> messages = [
    Message("Здравствуйте", "Врач", DateTime.now(), false),
    Message("Здравствуйте", "Пациент", DateTime.now(), true),
    Message("ЗдравствуйтеЗдравствуйтеЗдравствуйтеЗдравствуйтеЗдравствуйтеЗдравствуйте", "Врач", DateTime.now(), false),
    Message("Здравствуйте", "Врач", DateTime.now(), false),
  ];

  TextEditingController _messageController = TextEditingController();

  ChatViewState();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.purple,
        accentColor: Colors.grey[600],
        fontFamily: 'Pacifico',
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text("Сообщения врача"),
        ),
        //drawer: createDrawerMenuPart(context),
        body: Column(
          children: <Widget>[
            Expanded(
                child: StreamBuilder<List<Message>>(
                  stream: messageController.stream,
                  builder: (context, snapshot) {
                    return ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (buildContext, number) {
                        return ChatMessageView(messages[number]);
                      },
                    );
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
      ),
    );
  }

  _sendMessage() {
    // TODO: Implement file uploading

    String message = _messageController.text.trim();
    message = message.length > MAX_MESSAGE_LENGTH
        ? message.substring(0, MAX_MESSAGE_LENGTH)
        : message;

    var time = DateTime.now();
  }
}

class ChatMessageView extends StatelessWidget {
  final Message message;

  ChatMessageView(this.message);

  @override
  Widget build(BuildContext context) {
    return ListTile(
//        contentPadding: message.isMine
//            ? EdgeInsets.only(left: _getPaddingByMessageText(context), right: 10)
//            : EdgeInsets.only(right: _getPaddingByMessageText(context), left: 10),
        isThreeLine: true,
        title: Padding(
          padding: EdgeInsets.all(5.0),
          child: Text(
            _getMessageHeader(),
            textAlign: message.isMine
                ? TextAlign.right
                : TextAlign.left,
            style: TextStyle(
                color: Colors.grey,
                fontSize: 14
            ),
          ),
        ),
        subtitle: Row(
          children: [
            message.isMine ? Spacer() : SizedBox(),
            Flexible(
              flex: 1,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: message.isMine ? Colors.purple : Colors.grey[350],
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.elliptical(15, 10),
                      topRight: Radius.elliptical(15, 10),
                      bottomLeft: Radius.elliptical(15, 10),
                      bottomRight: Radius.elliptical(15, 10)
                  ),
                ),
                child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                        message.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18
                        )
                    )
                ),
              ),
            ),
            message.isMine ? SizedBox() : Spacer(),
          ]
        )
    );
  }

  _getMessageHeader() =>
      "${message.owner} ${message.time.day}/${message.time.month}/${message.time.year}";

  _getPaddingByMessageText(BuildContext context) {
    return MediaQuery.of(context).size.width * 0.3;
  }
}