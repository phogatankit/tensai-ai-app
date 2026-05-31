import 'package:tensai/data/models/msg_model.dart';
abstract class ChatState {}
class ChatInitial extends ChatState {
  final List<MessageModel> messages;
  final String currentModel;
  ChatInitial(this.messages, this.currentModel);
}
class ChatLoading extends ChatState {
  final List<MessageModel> messages;
  final String currentModel;
  ChatLoading(this.messages, this.currentModel);
}
class ChatLoaded extends ChatState {
  final List<MessageModel> messages;
  final String currentModel;
  ChatLoaded(this.messages, this.currentModel);
}
class ChatError extends ChatState {
  final String error;
  ChatError(this.error);
}