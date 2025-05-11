import 'dart:async';

import 'package:admin_privatily/chatting_page/widgets/GuestStatus.dart';
import 'package:admin_privatily/chatting_page/widgets/chat_bubble.dart';
import 'package:admin_privatily/chatting_page/widgets/date_header.dart';
import 'package:admin_privatily/chatting_page/widgets/message_input_field.dart';
import 'package:admin_privatily/chatting_page/widgets/variables/globalVariables.dart';
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


  @override
  void initState() {
    super.initState();

    globalChatRoomId = widget.chatRoomId;
    WidgetsBinding.instance.addObserver(this);
    setUserOnline(globalChatRoomId);

    logic.getMessages(widget.chatRoomId).listen((newMessages) {
      logic.updateMessages(newMessages);
    });
  }

  @override
  void dispose() {
   logic.setUserOffline(widget.chatRoomId);
    WidgetsBinding.instance.removeObserver(this);
    _typingTimer?.cancel();
    Get.delete<ChattingPageLogic>();
    super.dispose();
  }



  @override


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Card(
color: Colors.grey,
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(10),
            height: 50,
            width: screenWidth*.65,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.receiverName,
                    style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(width: 8),
                GuestStatus(guestUserId: widget.receiverId),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white70,
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
                    logic.setTypingStatus(isTyping,widget.chatRoomId);
                    if (_typingTimer != null && _typingTimer!.isActive) {
                      print("Timer cancelled");
                      _typingTimer!.cancel();
                    }
                    if (isTyping) {
                      _typingTimer = Timer(const Duration(seconds: 1), () {
                        print("Timer expired, setting isTyping to false");
                        logic.setTypingStatus(false,widget.chatRoomId);
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


}

