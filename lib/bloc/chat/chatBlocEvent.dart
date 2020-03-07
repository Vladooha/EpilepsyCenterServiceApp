import 'package:frontend/model/chat/chat.dart';
import 'package:frontend/model/chat/chatMessage.dart';

abstract class ChatBlocEvent {}

class OpenChat extends ChatBlocEvent {
  final Chat chat;

  OpenChat(this.chat);
}

class CloseChat extends ChatBlocEvent {
  final Chat chat;

  CloseChat(this.chat);
}

class SendMessage extends ChatBlocEvent {
  final ChatMessage chatMessage;

  SendMessage(this.chatMessage);
}