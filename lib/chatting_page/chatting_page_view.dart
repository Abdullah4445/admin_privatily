import 'package:admin_privatily/chatting_page/widgets/chat_bubble.dart';
import 'package:admin_privatily/chatting_page/widgets/date_header.dart';
import 'package:admin_privatily/chatting_page/widgets/message_input_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/messages.dart';
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

class _ChattingPageState extends State<ChattingPage> {
  final ChattingPageLogic logic = Get.put(ChattingPageLogic());
  final TextEditingController _messageController = TextEditingController();
  final RxBool isReceiverTyping = false.obs;
  bool isLoading = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    logic.getMessages(widget.chatRoomId).listen((newMessages) {
      logic.updateMessages(newMessages);
    });
    _updateOnlineStatus(true);
    _listenToChatStatus();
  }

  @override
  void dispose() {
    _updateOnlineStatus(false);
    _setTyping(false);
    _typingTimer?.cancel();
    super.dispose();
  }

  void _updateOnlineStatus(bool online) {
    logic.myFbFs.collection('ChatsRoomId').doc(widget.chatRoomId).set({
      'onlineStatus': {
        logic.myFbAuth.currentUser!.uid: online,
      }
    }, SetOptions(merge: true));
  }

  void _setTyping(bool isTyping) {
    logic.myFbFs.collection('ChatsRoomId').doc(widget.chatRoomId).set({
      'typingStatus': {
        logic.myFbAuth.currentUser!.uid: isTyping,
      }
    }, SetOptions(merge: true));
  }

  void _listenToChatStatus() {
    logic.myFbFs.collection('ChatsRoomId').doc(widget.chatRoomId).snapshots().listen((doc) {
      final data = doc.data();
      if (data != null) {
        final typingData = data['typingStatus'];
        final onlineData = data['onlineStatus'];

        if (typingData != null && typingData is Map) {
          isReceiverTyping.value = typingData[widget.receiverId] == true;
        }

        if (onlineData != null && onlineData is Map) {
          logic.receiverOnlineStatus.value = onlineData[widget.receiverId] == true;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.receiverName, style: const TextStyle(color: Colors.white)),
            Obx(() {
              final typing = isReceiverTyping.value;
              final onlineStatus = logic.receiverOnlineStatus.value;
              String subtitle = '';

              if (typing) {
                subtitle = 'Typing...';
              } else if (onlineStatus) {
                subtitle = 'Online';
              } else {
                subtitle = 'Offline';
              }

              return Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              );
            }),
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
                      final isMe = message.senderId == logic.myFbAuth.currentUser?.uid;
                      final showDateHeader = index == messages.length - 1 ||
                          message.timestamp!.day != messages[index + 1].timestamp!.day;
                      return Column(
                        children: [
                          if (showDateHeader) DateHeader(date: message.timestamp!),
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
                      logic.sendMessage(widget.chatRoomId, widget.receiverId, text);
                      _setTyping(false);
                      _messageController.clear();
                      setState(() => isLoading = false);
                    }
                  },
                  onImagePressed: () async {
                    setState(() => isLoading = true);
                    await logic.pickImage(widget.chatRoomId, widget.receiverId);
                    setState(() => isLoading = false);
                  },
                  onChanged: (text) {
                    _setTyping(true);
                    _typingTimer?.cancel();
                    _typingTimer = Timer(const Duration(seconds: 2), () {
                      _setTyping(false);
                    });
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