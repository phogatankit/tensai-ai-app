import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:remixicon/remixicon.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tensai/data/models/msg_model.dart';
import 'package:tensai/features/chat/bloc/chat_bloc.dart';
import 'package:tensai/features/chat/bloc/chat_event.dart';
import 'package:tensai/features/chat/bloc/chat_state.dart';
import 'package:tensai/features/chat/ui/widgets/chat_drawer.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateFormat dtFormat = DateFormat.yMMM();

  final List<String> availableModels = [
    "gpt-4.1-mini",
    "gpt-3.5-turbo",
    "gpt-4o",
    "gpt-4-turbo",
  ];

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const ChatDrawer(),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            /// APNI_APP_BAR
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    child: const Icon(Remix.menu_2_line, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    "Tensai",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _showModelSelectionDialog(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Remix.robot_2_line, color: Colors.white70, size: 16),
                            const SizedBox(width: 6),
                            BlocBuilder<ChatBloc, ChatState>(
                              builder: (context, state) {
                                String currentModel = "gpt-4-turbo"; // Fallback
                                if (state is ChatLoaded) currentModel = state.currentModel;
                                else if (state is ChatLoading) currentModel = state.currentModel;
                                else if (state is ChatInitial) currentModel = state.currentModel;

                                return Expanded(
                                  child: Text(
                                    currentModel,
                                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            ),
                            const Icon(Remix.arrow_down_s_line, color: Colors.white70, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
              ),
            ),

            /// chatvew
            Expanded(
              child: BlocBuilder<ChatBloc, ChatState>(
                builder: (context, state) {
                  List<MessageModel> listMsg = [];
                  if (state is ChatLoaded) listMsg = state.messages;
                  else if (state is ChatLoading) listMsg = state.messages;
                  else if (state is ChatInitial) listMsg = state.messages;

                  if (listMsg.isEmpty) {
                    return Center(
                      child: Text(
                        "How can I help you today?",
                        style: GoogleFonts.poppins(color: Colors.white54, fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: listMsg.length + (state is ChatLoading ? 1 : 0),
                    itemBuilder: (_, index) {
                      if (index == listMsg.length && state is ChatLoading) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: CircularProgressIndicator(color: Colors.blueAccent),
                          ),
                        );
                      }
                      return listMsg[index].sendId == 0
                          ? userChatBox(listMsg[index])
                          : botChatBox(listMsg[index]);
                    },
                  );
                },
              ),
            ),

            /// Input Area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: TextField(
                        controller: controller,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                        cursorColor: Colors.white,
                        maxLines: null, // Allows multiline input
                        textInputAction: TextInputAction.send,
                        onSubmitted: (value) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText: "Ask anything...",
                          hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 15),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Remix.send_plane_fill, size: 20, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (controller.text.trim().isEmpty) return;
    context.read<ChatBloc>().add(SendMessageEvent(controller.text.toString()));
    controller.clear();
  }

  Widget userChatBox(MessageModel msgModel) {
    var time = dtFormat.format(DateTime.fromMillisecondsSinceEpoch(int.parse(msgModel.sentAt!)));

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(top: 8, bottom: 8, left: 60, right: 12),
        // BoxConstraints handles responsive bubble sizing dynamically
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msgModel.msg!,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              time,
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget botChatBox(MessageModel msgModel) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(7),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E1E),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(21),
          topRight: Radius.circular(21),
          bottomRight: Radius.circular(21),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MarkdownBody(
            data: msgModel.msg!,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              p: GoogleFonts.poppins(color: Colors.white, fontSize: 15, height: 1.5),
              tableHead: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              tableBody: GoogleFonts.poppins(color: Colors.white70, fontSize: 13),
              tableBorder: TableBorder.all(color: Colors.white24, width: 1),
              tableCellsPadding: const EdgeInsets.all(8),
              codeblockDecoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              code: GoogleFonts.firaCode(color: Colors.greenAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showModelSelectionDialog(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (bottomSheetContext) {
        return BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
            String currentModel = "gpt-4-turbo";
            if (state is ChatLoaded) currentModel = state.currentModel;
            else if (state is ChatLoading) currentModel = state.currentModel;
            else if (state is ChatInitial) currentModel = state.currentModel;

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Select AI Model",
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white24),
                  ...availableModels.map((model) {
                    bool isSelected = currentModel == model;
                    return ListTile(
                      title: Text(
                        model,
                        style: GoogleFonts.poppins(
                          color: isSelected ? Colors.greenAccent : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Remix.check_line, color: Colors.greenAccent)
                          : null,
                      onTap: () {
                        context.read<ChatBloc>().add(UpdateModelEvent(model));
                        Navigator.pop(bottomSheetContext);
                      },
                    );
                  }),
                ],
              ),
            );
          },
        );
      },
    );
  }
}