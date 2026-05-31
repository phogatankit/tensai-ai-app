import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:remixicon/remixicon.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tensai/data/models/chat_session_model.dart';
import 'package:tensai/features/auth/bloc/auth_bloc.dart';
import 'package:tensai/features/auth/bloc/auth_event.dart';
import 'package:tensai/features/chat/bloc/chat_bloc.dart';
import 'package:tensai/features/chat/bloc/chat_event.dart';
import 'package:tensai/features/auth/ui/login_screen.dart';

class ChatDrawer extends StatelessWidget {
  const ChatDrawer({super.key});

  // Direct Firestore stream to keep the drawer history real-time
  Stream<List<ChatSession>> _getChatSessionsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('chat_sessions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ChatSession.fromJson(doc.data()))
        .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF121212),
      child: SafeArea(
        child: Column(
          children: [
            /// NEW CHAT BUTTON
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  context.read<ChatBloc>().add(CreateNewChatEvent());
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Remix.add_line, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(
                        "New Chat",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(color: Colors.white12),

            /// RECENT CHATS LIST
            Expanded(
              child: StreamBuilder<List<ChatSession>>(
                stream: _getChatSessionsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        "No recent chats",
                        style: GoogleFonts.poppins(color: Colors.white54),
                      ),
                    );
                  }

                  List<ChatSession> sessions = snapshot.data!;
                  return ListView.builder(
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      ChatSession session = sessions[index];
                      return ListTile(
                        leading: const Icon(Remix.message_3_line, color: Colors.white54, size: 20),
                        title: Text(
                          session.title,
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          context.read<ChatBloc>().add(LoadSessionEvent(session.id));
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),

            const Divider(color: Colors.white12),

            ///LOGOUT BUTTON
            ListTile(
              leading: const Icon(Remix.logout_box_r_line, color: Colors.redAccent),
              title: Text(
                "Logout",
                style: GoogleFonts.poppins(color: Colors.redAccent, fontWeight: FontWeight.w600),
              ),
              onTap: () {
                context.read<ChatBloc>().add(CreateNewChatEvent());

                context.read<AuthBloc>().add(LogoutRequested());

                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}