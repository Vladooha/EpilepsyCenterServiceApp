import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/bloc/chat/chatBlocEvent.dart';
import 'package:frontend/bloc/chat/chatBlocState.dart';
import 'package:frontend/bloc/user/userBloc.dart';
import 'package:frontend/model/chat/chat.dart';
import 'package:frontend/model/chat/chatMessage.dart';
import 'package:frontend/model/user/userMetainfo.dart';
import 'package:frontend/service/ioc/abstractBloc.dart';
import 'package:frontend/service/ioc/blocContainerService.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

import 'chatBlocEvent.dart';

class ChatBloc extends AbstractBloc {
  static const String BLOC_NAME = "chat-bloc";

  static const String CHATS_PATH = "chats";
  static const String CHAT_MESSAGES_PATH = "messages";

  @override
  List<String> get dependencyNames => [UserBloc.BLOC_NAME];
  
  UserBloc userBloc = BlocContainerService.instance.getAndInit(UserBloc.BLOC_NAME);
  
  /// BLoC streams and mappers

  BehaviorSubject<ChatBlocEvent> _eventListener;
  BehaviorSubject<ChatListBlocState> _chatListStreamController;
  Map<String, BehaviorSubject<ChatBlocState>> _chatStreamControllerMap;

  Sink<ChatBlocEvent> get eventListener => _eventListener.sink;
  Stream<ChatListBlocState> get chatList => _chatListStreamController.stream.asBroadcastStream();
  Stream<ChatBlocState> getChatMessages(Chat chat) {
    if (_isChatClosed(chat.id)) {
      _chatStreamControllerMap[chat.id] = BehaviorSubject<ChatBlocState>();
    }

    return _chatStreamControllerMap[chat.id].stream;
  }

  ChatListBlocState get lastChatList => _chatListStreamController.value;
  ChatBlocState getLastChatMessages(Chat chat) {
    if (_isChatClosed(chat.id)) {
      return null;
    }

    return _chatStreamControllerMap[chat.id].value;
  }

  ChatBloc() {
    init();
  }

  @override
  bool init() {
    if (super.init()) {
      _eventListener = BehaviorSubject<ChatBlocEvent>();
      _chatListStreamController = BehaviorSubject<ChatListBlocState>();
      _chatStreamControllerMap = {};

      // Chat list updates always actual and shouldn't be controlled by user
      _initChatListStream();

      _eventListener.stream.listen(_eventToStateMapper);

      return true;
    }

    return true;
  }

  @override
  String get name => BLOC_NAME;

  @override
  bool dispose() {
    if (super.dispose()) {
      _eventListener.close();
      _chatListStreamController.close();
      _chatStreamControllerMap.values.forEach((stream) => stream.close());

      return true;
    }

    return false;
  }

  void _initChatListStream() async {
    _chatListStreamController.sink.add(GettingChatList());
    
    userBloc.userData.listen((userData) { 
      if (userData.user != null && userData.isCurrentUser) {
        print("[$BLOC_NAME]: Recieved chat list - ${userData.user.metainfo.chats[0]}");

        _chatListStreamController.sink.addStream(
            _mapMetainfoToChatListFuture(userData.user.metainfo)
                .asStream()
                .map((chatList) => GotChatList(chatList))
        );
      }
    });
  }

  /// User event handlers

  void _eventToStateMapper(ChatBlocEvent event) {
    if (event is OpenChat) {
      _openChat(event.chat);
    } else if (event is CloseChat) {
      _closeChat(event.chat);
    } else if (event is SendMessage) {
      _sendMessage(event.chatMessage);
    }
  }

  bool _isChatClosed(String chatId) {
    return _chatStreamControllerMap[chatId] == null
        || _chatStreamControllerMap[chatId].isClosed;
  }

  void _openChat(Chat chat) {
    print('Chat opening: ${chat.id}');

    String chatId = chat.id;
    if (_isChatClosed(chat.id)) {
      _chatStreamControllerMap[chatId] = BehaviorSubject<ChatBlocState>();
      _chatStreamControllerMap[chatId].sink.add(GettingChat());
    }

    print('Chat loading...');
    _chatStreamControllerMap[chatId].sink.addStream(
        Firestore.instance
          .collection(CHATS_PATH)
          .document(chatId)
          .collection(CHAT_MESSAGES_PATH)
          .snapshots()
          .map((snapshots) => snapshots.documents
            .map(_mapSnapshotToChatMessage).toList()
          )
          .map((snapshot) => GotChat(snapshot))
    );
    print('Chat loaded...');
  }

  void _closeChat(Chat chat) async {
    print('Chat closing: ${chat.id}');

    String chatId = chat.id;
    if (!_isChatClosed(chatId)) {
      await _chatStreamControllerMap[chatId].stream.drain();
      _chatStreamControllerMap[chatId].close();
    }
  }

  void _sendMessage(ChatMessage chatMessage) {
    print('Sending message: ' + chatMessage.message);
    print('Chat id: ${chatMessage.chatId}');

    String chatId = chatMessage.chatId;
    if (!_isChatClosed(chatId)) {
      print('Chat ${chatMessage.chatId} isnt closed!');
      //_chatStreamControllerMap[chatId].sink.add(MessageLoading());
      Firestore.instance
          .collection(CHATS_PATH)
          .document(chatId)
          .collection(CHAT_MESSAGES_PATH)
          .document(chatMessage.id)
          .setData(_mapChatMessageToSnapshot(chatMessage));
          //.whenComplete(() => _chatStreamControllerMap[chatId].sink.add(MessageSended()));
    }
  }

  /// Mapping

  Future<List<Chat>> _mapMetainfoToChatListFuture (UserMetainfo userMetaInfo) async {

    List<Chat> chats = [];

    if (userMetaInfo != null && userMetaInfo.chats != null) {
      for (String chatId in userMetaInfo.chats) {
        Chat newChat = await Firestore.instance
            .collection(CHATS_PATH)
            .document(chatId)
            .get()
            .then((snapshot) => _mapSnapshotToChat(snapshot));

        chats.add(newChat);
      }
    }

    return chats;
  }

  Chat _mapSnapshotToChat(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      return Chat(
          snapshot.documentID,
          snapshot.data["doctor-id"],
          snapshot.data["patient-id"],
          ChatMessage(
            snapshot.data["last-message-id"],
            snapshot.data["last-message-author-id"],
            snapshot.documentID,
            snapshot.data["last-message-text"],
            snapshot.data["last-message-date"],
          )
      );
    }

    return null;
  }

  ChatMessage _mapSnapshotToChatMessage(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      return ChatMessage(
          snapshot.documentID,
          snapshot.data["author-id"],
          snapshot.reference.parent().parent().documentID,
          snapshot.data["text"],
          (snapshot.data["date"] as Timestamp).toDate(),
          imageUrlList: snapshot.data["imageUrls"],
      );
    }

    return null;
  }

  Map<String, dynamic> _mapChatToSnapshot(Chat chat) {
    if (chat != null) {
      return {
        "id":         chat.id,
        "doctor-id":  chat.doctorId,
        "patient-id": chat.patientId
      };
    }

    return null;
  }

  Map<String, dynamic> _mapChatMessageToSnapshot(ChatMessage chatMessage) {
    if (chatMessage != null) {
      return {
        "text":       chatMessage.message,
        "author-id":  chatMessage.authorId,
        "date":       chatMessage.date,
        "imageUrls":  chatMessage.imageUrlList
      };
    }

    return null;
  }
}