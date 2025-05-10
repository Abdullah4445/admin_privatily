import 'dart:async';

import 'package:admin_privatily/chatting_page/widgets/chat_bubble.dart';
import 'package:admin_privatily/chatting_page/widgets/date_header.dart';
import 'package:admin_privatily/chatting_page/widgets/message_input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../firebase_utils.dart';
import '../login_screen/logic.dart';
import 'chatting_page_logic.dart';

class ChattingPage extends StatefulWidget {
  final String chatRoomId;
  final String receiverId;
  final String receiverName;

  const ChattingPage({
    Key? key,
    required this.chatRoomId,
    required this.receiverName,
    required this.receiverId,
  }) : super(key: key);

  @override
  State<ChattingPage> createState() => _ChattingPageState();
}

class _ChattingPageState extends State<ChattingPage>
    with WidgetsBindingObserver {
  final ChattingPageLogic logic = Get.put(ChattingPageLogic());
  final Login_pageLogic logic1 = Get.put(Login_pageLogic());
  final TextEditingController _messageController = TextEditingController();
  bool isLoading = false;

  Timer? _typingTimer;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setUserOnline();

    logic.getMessages(widget.chatRoomId).listen((newMessages) {
      logic.updateMessages(newMessages);
    });
  }

  @override
  void dispose() {
    setUserOffline();
    WidgetsBinding.instance.removeObserver(this);
    _typingTimer?.cancel();
    Get.delete<ChattingPageLogic>();
    super.dispose();
  }

  Future<void> setUserOffline() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setUserOnline();
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      setUserOffline();
    }
  }

  void setTypingStatus(bool isTyping) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'isTyping': isTyping,
      }, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.receiverName,
                style: const TextStyle(color: Colors.white)),
            SizedBox(width: 8),
            GuestStatus(guestUserId: widget.receiverId),
          ],
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Obx(() {
                  final messages = logic.messages;
                  if (messages.isEmpty) {
                    return const Center(child: Text('No messages'));
                  }

                  return ListView.builder(
                    reverse: true,
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe =
                          message.senderId == logic.myFbAuth.currentUser?.uid;
                      final showDateHeader = index == messages.length - 1 ||
                          message.timestamp!.day !=
                              messages[index + 1].timestamp!.day;
                      return Column(
                        children: [
                          if (showDateHeader)
                            DateHeader(date: message.timestamp!),
                          ChatBubble(message: message, isMe: isMe),
                        ],
                      );
                    },
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MessageInputField(
                  controller: _messageController,
                  onSendPressed: () {
                    final text = _messageController.text.trim();
                    if (text.isNotEmpty) {
                      setState(() => isLoading = true);
                      logic.sendMessage(
                          widget.chatRoomId, widget.receiverId, text);
                      _messageController.clear();
                      setState(() => isLoading = false);
                    }
                  },
                  onImagePressed: () async {
                    setState(() => isLoading = true);
                    await logic.pickImage(
                        widget.chatRoomId, widget.receiverId);
                    setState(() => isLoading = false);
                  },
                  onChanged: (text) {
                    final isTyping = text.trim().isNotEmpty;
                    print("onChanged called. text: '$text', isTyping: $isTyping");
                    setTypingStatus(isTyping);
                    if (_typingTimer != null && _typingTimer!.isActive) {
                      print("Timer cancelled");
                      _typingTimer!.cancel();
                    }
                    if (isTyping) {
                      _typingTimer = Timer(const Duration(seconds: 1), () {
                        print("Timer expired, setting isTyping to false");
                        setTypingStatus(false);
                      });
                    } else {
                      print("Text field is empty");
                    }
                  },
                ),
              ),
            ],
          ),
          if (isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  Future<void> setUserOnline() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'isOnline': true,
          'lastSeen': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        print("User ${user.uid} set to online");
      } catch (e) {
        print("Error setting user online: $e");
      }
    } else {
      print("No user logged in, cannot set online status.");
    }
  }
}

class GuestStatus extends StatelessWidget {
  final String guestUserId;

  const GuestStatus({Key? key, required this.guestUserId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(guestUserId)
          .snapshots(),
      builder: (context, snapshot) {
        print("StreamBuilder snapshot: ${snapshot.data?.data()}");
        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final isOnline = userData['isOnline'] ?? false;
          final isTyping = userData['isTyping'] ?? false;
          final lastSeen = userData['lastSeen'] as Timestamp?;

          if (isTyping) {
            return const Text("(Typing...)");
          } else if (isOnline) {
            return const Text("(Online)");
          } else {
            if (lastSeen != null) {
              DateTime dateTime = lastSeen.toDate();
              String formattedDate =
              DateFormat('dd/MM/yyyy hh:mm a').format(dateTime);
              return Text("(Last seen: $formattedDate)");
            } else {
              return const Text("(Offline)");
            }
          }
        } else {
          return const Text("(Loading status...)");
        }
      },
    );
  }
}