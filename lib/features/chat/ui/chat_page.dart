import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:tensai/data/models/msg_model.dart';
import 'package:tensai/features/chat/provider/msg_provider.dart';
import 'package:tensai/features/news/bloc/headline_bloc.dart';
import 'package:tensai/features/news/ui/headline_screen.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();
  DateFormat dtFormat = DateFormat.yMMM();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                 /* GestureDetector(
                    onTap: () {},
                    child: const Icon(RemixIcons.menu_2_line, color: Colors.white),
                  ),*/
                  const SizedBox(width: 16),

                  Text("Tensai", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22,),),
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
                            const Icon(RemixIcons.robot_2_line, color: Colors.white70, size: 16),
                            const SizedBox(width: 6),
                            Consumer<MessageProvider>(
                                builder: (context, provider, child) {
                                  return Expanded(
                                    child: Text(
                                      provider.currentModel,
                                      style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }
                            ),
                            const Icon(RemixIcons.arrow_down_s_line, color: Colors.white70, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),
                  InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                  create: (_) => HeadlineBloc(),
                                ),
                              ],
                              child: HeadlinePage(),
                            ),
                          ),
                        );
                      },
                      child: const Icon(LucideIcons.newspaper, color: Colors.white)
                  ),
                ],
              ),
            ),

            Expanded(child: Consumer<MessageProvider>(
              builder: (context, provider, child) {
                var listMsg = provider.fetchAllMessages();
                return ListView.builder(
                  itemCount: listMsg.length,
                  itemBuilder: (_, index) {
                    return listMsg[index].sendId == 0
                        ? userChatBox(listMsg[index])
                        : botChatBox(listMsg[index]);
                  },
                );
              },
            )),

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
                    onTap: () {
                      if(controller.text.trim().isEmpty) return;
                      Provider.of<MessageProvider>(context, listen: false).sendMessage(message: controller.text.toString());
                      controller.clear();
                    },
                    child: Container(
                      height: 48,
                      width: 48,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(RemixIcons.send_plane_fill, size: 20, color: Colors.black),
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

  Widget userChatBox(MessageModel msgModel) {
    var time = dtFormat.format(DateTime.fromMillisecondsSinceEpoch(int.parse(msgModel.sentAt!)));

    return Align(
      alignment: Alignment.centerRight,
      child: Container(

        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(top: 8, bottom: 8, left: 60, right: 12),

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
            bottomRight: Radius.circular(4), // Tail effect
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
      builder: (context) {
        return Consumer<MessageProvider>(
          builder: (context, provider, child) {
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
                  ...provider.availableModels.map((model) {
                    bool isSelected = provider.currentModel == model;
                    return ListTile(
                      title: Text(
                        model,
                        style: GoogleFonts.poppins(
                          color: isSelected ? Colors.greenAccent : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(RemixIcons.check_line, color: Colors.greenAccent)
                          : null,
                      onTap: () {
                        provider.setModel(model);
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}