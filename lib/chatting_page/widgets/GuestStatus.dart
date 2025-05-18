import 'package:admin_privatily/chatting_page/widgets/typing_indicator.dart';
import 'package:admin_privatily/chatting_page/widgets/variables/globalVariables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GuestStatus extends StatelessWidget {
  final String guestUserId;

  const GuestStatus({Key? key, required this.guestUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.
        collection('ChatsRoomId').doc(globalChatRoomId).collection("usersStatus")
          .doc(guestUserId)
          .snapshots(),
      builder: (context, snapshot) {
        // Log to debug
        print("StreamBuilder snapshot: ${snapshot.data?.data()}");

        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final isOnline = userData['isOnline'] ?? false;
          final isTyping = userData['isTyping'] ?? false;
          final lastSeen = userData['lastSeen'] as Timestamp?;

          if (isTyping) {
            return const TypingIndicator(); // 👈 Beautiful animated indicator
          } else if (isOnline) {
            return const Text(
              "(Online)",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            );
          } else {
            if (lastSeen != null) {
              DateTime dateTime = lastSeen.toDate();
              String formattedDate =
              DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
              return Text(
                "(Last seen: $formattedDate)",
                style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              );
            } else {
              return const Text(
                "(Offline)",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              );
            }
          }
        } else {
          return const Text(
            "(Loading status...)",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          );
        }
      },
    );
  }
}
