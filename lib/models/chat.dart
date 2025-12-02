import 'message.dart';
import 'user.dart';

class Chat {
  final String id;
  final User user;
  final Message? lastMessage;
  final DateTime? lastMessageTime;

  Chat({
    required this.id,
    required this.user,
    this.lastMessage,
    this.lastMessageTime,
  });
}


