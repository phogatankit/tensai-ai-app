import 'package:flutter/foundation.dart';
import 'package:tensai/core/network/api_client.dart';
import 'package:tensai/data/models/ai_generated_model.dart';
import 'package:tensai/data/models/msg_model.dart';

class MessageProvider extends ChangeNotifier {
  final List<MessageModel> _listMessage = [];


  String _currentModel = "gpt-4.1-mini";
  String get currentModel => _currentModel;

  final List<String> availableModels = [
    "gpt-4.1-mini",
    "gpt-3.5-turbo",
    "gpt-4o",
    "gpt-4",
  ];

  void setModel(String newModel) {
    _currentModel = newModel;
    notifyListeners();
  }


  List<MessageModel> fetchAllMessages() {
    return _listMessage;
  }

  Future<void> sendMessage({required String message}) async {
    _listMessage.add(MessageModel(msg: message, sendId: 0, sentAt: DateTime.now().millisecondsSinceEpoch.toString(),),);
    notifyListeners();

    try {
      String conversationHistory = "You are Tensai, an intelligent assistant. Here is the conversation history:\n\n";
      int startIndex = _listMessage.length > 6 ? _listMessage.length - 6 : 0;

      for (int i = startIndex; i < _listMessage.length - 1; i++) {
        String role = _listMessage[i].sendId == 0 ? "User" : "Tensai";
        conversationHistory += "$role: ${_listMessage[i].msg}\n";
      }

      conversationHistory += "User: $message\nTensai:";

      var mData = await ApiClient().sendMsgApi(msg: conversationHistory, model: _currentModel,);

      AIGeneratedModel generatedModel = AIGeneratedModel.fromJson(mData);

      _listMessage.add(MessageModel(msg: generatedModel.output?[0].content?[0].text ?? "No Response", sendId: 1, sentAt: DateTime.now().millisecondsSinceEpoch.toString(), isRead: true,),);

      notifyListeners();

    } catch (e) {
      _listMessage.add(MessageModel(msg: e.toString(), sendId: 1, sentAt: DateTime.now().millisecondsSinceEpoch.toString(), isRead: true,),);
      notifyListeners();
    }
  }

  void updateMsgRead(int index){
    _listMessage[index].isRead = true;
    notifyListeners();
  }
}