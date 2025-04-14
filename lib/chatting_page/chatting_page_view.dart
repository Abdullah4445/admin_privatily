import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/messages.dart';
import 'chatting_page_logic.dart';

class ChattingPage extends StatefulWidget {
  final String chatRoomId;
  final String receiverId;
  final String receiverName;

  ChattingPage({
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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    logic.getMessages(widget.chatRoomId).listen((newMessages) {
      logic.updateMessages(newMessages);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.receiverName,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.red,
        elevation: 8,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (logic.messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    );
                  }
                  return ListView.builder(
                    reverse: true,
                    itemCount: logic.messages.length,
                    itemBuilder: (context, i) {
                      Messages message = logic.messages[i];
                      bool isMe = message.senderId == logic.myFbAuth.currentUser!.uid;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.deepPurple : Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(2, 2),
                              ),
                            ],
                          ),
                          child: message.messageType == 'text'
                              ? Text(
                            message.messageText,
                            style: TextStyle(fontSize: 16, color: isMe ? Colors.white : Colors.black87),
                          )
                              : message.imageUrl != null && message.imageUrl!.isNotEmpty
                              ? SizedBox(
                            height: 150,
                            width: 150,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                message.imageUrl!,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(child: CircularProgressIndicator());
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading image: $error');
                                  return const Icon(Icons.error, color: Colors.red);
                                },
                              ),
                            ),
                          )
                              : const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      );
                    },
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Type a message...",
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        setState(() {
                          isLoading = true;
                        });
                        await logic.pickImage(widget.chatRoomId, widget.receiverId);
                        setState(() {
                          isLoading = false;
                        });
                      },
                      icon: const Icon(Icons.image),
                    ),
                    GestureDetector(
                      onTap: () {
                        String messageText = _messageController.text.trim();
                        if (messageText.isNotEmpty) {
                          setState(() {
                            isLoading = true;
                          });
                          logic.sendMessage(widget.chatRoomId, widget.receiverId, messageText);
                          _messageController.clear();
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.deepPurple,
                        ),
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
