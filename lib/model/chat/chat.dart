import 'package:frontend/model/chat/chatMessage.dart';

class Chat {
  String id;
  String doctorId;
  String patientId;
  ChatMessage lastMessage;

  Chat(
      this.id,
      this.doctorId,
      this.patientId,
      this.lastMessage
  );
}