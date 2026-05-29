class MessageModel {
  String msg;
  int sendId; //0->user, 1->bot,
  String sentAt;
  bool isRead;

  MessageModel({
    required this.msg,
    required this.sendId,
    required this.sentAt,
    this.isRead = false,
  });
}