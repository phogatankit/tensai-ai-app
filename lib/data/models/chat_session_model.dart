import 'package:tensai/data/models/msg_model.dart';

class ChatSession {
  final String id;
  final String title;
  final DateTime timestamp;
  final List<MessageModel> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.timestamp,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'timestamp': timestamp.toIso8601String(),

    'messages': messages.map((m) => {
      'msg': m.msg,
      'sendId': m.sendId,
      'sentAt': m.sentAt,
      'isRead': m.isRead,
    }).toList(),
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    var msgList = json['messages'] as List? ?? [];
    return ChatSession(
      id: json['id'] ?? '',
      title: json['title'] ?? 'New Chat',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      //  --> Model
      messages: msgList.map((m) => MessageModel(
        msg: m['msg'],
        sendId: m['sendId'],
        sentAt: m['sentAt'],
        isRead: m['isRead'] ?? true,
      )).toList(),
    );
  }
}