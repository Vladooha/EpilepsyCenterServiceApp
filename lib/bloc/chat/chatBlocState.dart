import 'package:frontend/model/chat/chat.dart';
import 'package:frontend/model/chat/chatMessage.dart';

abstract class ChatBlocState {}
abstract class ChatListBlocState {}

class GettingChatList extends ChatListBlocState {}
class GotChatList extends ChatListBlocState {
  final List<Chat> chatList;

  GotChatList(this.chatList);
}

class GettingChat extends ChatBlocState {}
class GotChat extends ChatBlocState {
  final List<ChatMessage> chatMessageList;

  GotChat(this.chatMessageList);
}

class SendingMessage extends ChatBlocState {}
class SendedMessage extends ChatBlocState {}
