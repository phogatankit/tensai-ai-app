abstract class ChatEvent {}
class CreateNewChatEvent extends ChatEvent {}
class LoadSessionEvent extends ChatEvent { final String sessionId; LoadSessionEvent(this.sessionId); }
class SendMessageEvent extends ChatEvent { final String message; SendMessageEvent(this.message); }
class UpdateModelEvent extends ChatEvent { final String model; UpdateModelEvent(this.model); }