import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tensai/core/network/api_client.dart';
import 'package:tensai/core/constants/api_endpoints.dart';
import 'package:tensai/data/models/ai_generated_model.dart';
import 'package:tensai/data/models/msg_model.dart';
import 'package:tensai/data/models/chat_session_model.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<MessageModel> _currentMessages = [];
  String _currentModel = "gpt-4.1-mini";
  String? _currentSessionId;

  ChatBloc() : super(ChatInitial(const [], "gpt-4-turbo")) {

    ///CREATE NEW CHAT
    on<CreateNewChatEvent>((event, emit) {
      _currentMessages.clear();
      _currentSessionId = null;
      emit(ChatLoaded(List.from(_currentMessages), _currentModel));
    });

    ///UPDATE AI MODEL
    on<UpdateModelEvent>((event, emit) {
      _currentModel = event.model;
      emit(ChatLoaded(List.from(_currentMessages), _currentModel));
    });

    ///LOAD EXISTING SESSION
    on<LoadSessionEvent>((event, emit) async {
      String? uid = _auth.currentUser?.uid;
      if (uid == null) return;

      emit(ChatLoading(List.from(_currentMessages), _currentModel));

      try {
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(uid)
            .collection('chat_sessions')
            .doc(event.sessionId)
            .get();

        if (doc.exists) {
          ChatSession session = ChatSession.fromJson(doc.data() as Map<String, dynamic>);
          _currentMessages = session.messages;
          _currentSessionId = session.id;
          emit(ChatLoaded(List.from(_currentMessages), _currentModel));
        } else {
          emit(ChatError("Session not found"));
        }
      } catch (e) {
        emit(ChatError("Failed to load chat: $e"));
      }
    });

    ///SEND MESSAGE
    on<SendMessageEvent>((event, emit) async {
      if (event.message.trim().isEmpty) return;

      _currentMessages.add(
          MessageModel(
              msg: event.message,
              sendId: 0,
              sentAt: DateTime.now().millisecondsSinceEpoch.toString()
          )
      );
      emit(ChatLoading(List.from(_currentMessages), _currentModel));

      try {
        String promptContext = "You are Tensai, an intelligent assistant.\n\nConversation History:\n";

        int startIndex = _currentMessages.length > 6 ? _currentMessages.length - 6 : 0;
        for (int i = startIndex; i < _currentMessages.length; i++) {
          String role = _currentMessages[i].sendId == 0 ? "User" : "Tensai";
          promptContext += "$role: ${_currentMessages[i].msg}\n";
        }

        var response = await ApiClient().post(
            url: ApiEndpoints.chatAiUrl,
            headers: {
              "Authorization": "Bearer ${ApiEndpoints.openAiApiKey}",
              "Content-Type": "application/json"
            },
            body: {
              "model": _currentModel,
              "input": promptContext,
            }
        );

        AIGeneratedModel generatedModel = AIGeneratedModel.fromJson(response);
        String aiResponse = generatedModel.output?[0].content?[0].text ?? "No Response";

        _currentMessages.add(
            MessageModel(
                msg: aiResponse,
                sendId: 1,
                sentAt: DateTime.now().millisecondsSinceEpoch.toString(),
                isRead: true
            )
        );

        await _saveSessionToFirebase(event.message);

        emit(ChatLoaded(List.from(_currentMessages), _currentModel));

      } catch (e) {
        _currentMessages.add(
            MessageModel(
                msg: "Error: ${e.toString()}",
                sendId: 1,
                sentAt: DateTime.now().millisecondsSinceEpoch.toString(),
                isRead: true
            )
        );
        emit(ChatLoaded(List.from(_currentMessages), _currentModel));
      }
    });

  }

  // --- FIREBASE SAVE HELPER ---
  Future<void> _saveSessionToFirebase(String firstQuery) async {
    String? uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      if (_currentSessionId == null) {

        _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
        String title = firstQuery.length > 25 ? "${firstQuery.substring(0, 25)}..." : firstQuery;

        ChatSession newSession = ChatSession(
          id: _currentSessionId!,
          title: title,
          timestamp: DateTime.now(),
          messages: _currentMessages,
        );

        await _firestore
            .collection('users')
            .doc(uid)
            .collection('chat_sessions')
            .doc(_currentSessionId)
            .set(newSession.toJson());
      } else {

        await _firestore
            .collection('users')
            .doc(uid)
            .collection('chat_sessions')
            .doc(_currentSessionId)
            .update({
          'messages': _currentMessages.map((m) => {
            'msg': m.msg,
            'sendId': m.sendId,
            'sentAt': m.sentAt,
            'isRead': m.isRead,
          }).toList(),
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      print("Error saving session to Firebase: $e");
    }
  }
}