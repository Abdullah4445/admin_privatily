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
  final RxString receiverStatusText = ''.obs;
  bool isLoading = false;
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    logic.getMessages(widget.chatRoomId).listen((newMessages) {
      logic.updateMessages(newMessages);
    });
    _updateOnlineStatus(true);
    _listenToReceiverStatus();
  }

  @override
  void dispose() {
    _updateOnlineStatus(false);
    _setTyping(false);
    _typingTimer?.cancel();
    super.dispose();
    Get.delete<ChattingPageLogic>();
  }

  void _updateOnlineStatus(bool online) async {
    final uid = logic.myFbAuth.currentUser!.uid;
    print("Setting online status for user $uid to $online");

    try {
      await logic.myFbFs.collection('ChatsRoomId').doc(widget.chatRoomId).set({
        'onlineStatus': {uid: online},
        if (!online) 'lastSeen': {uid: Timestamp.now()},
      }, SetOptions(merge: true));
      print("Online status updated successfully in Firestore.");
    } catch (e) {
      print("Error updating online status: $e");
    }
  }

  Future<void> _setTyping(bool isTyping) async {
    final uid = logic.myFbAuth.currentUser!.uid;
    // Prevent unnecessary writes if the status is already the same
    final currentTypingStatus = await logic.myFbFs.collection('ChatsRoomId')
        .doc(widget.chatRoomId)
        .get()
        .then((doc) => doc.data()?['typingStatus']?[uid] as bool?);

    if (currentTypingStatus == isTyping) {
      print("Typing status is already $isTyping, skipping update");
      return;
    }

    print("Setting typing status for user $uid to $isTyping");

    try {
      await logic.myFbFs.collection('ChatsRoomId').doc(widget.chatRoomId).set({
        'typingStatus': {uid: isTyping}
      }, SetOptions(merge: true));
      print("Typing status updated successfully in Firestore.");
    } catch (e) {
      print("Error setting typing status: $e");
    }
  }


  void _listenToReceiverStatus() {
    print("Listening to receiver status for chatRoomId: ${widget.chatRoomId}, receiverId: ${widget.receiverId}");

    logic.myFbFs.collection('ChatsRoomId').doc(widget.chatRoomId).snapshots().listen((doc) {
      if (!mounted) {
        print("Widget is not mounted.  Exiting _listenToReceiverStatus.");
        return;
      }

      final data = doc.data();
      print("Snapshot Data: $data");

      if (data != null) {
        final typingStatusMap = data['typingStatus'] as Map<String, dynamic>?;
        final onlineStatusMap = data['onlineStatus'] as Map<String, dynamic>?;
        final lastSeenMap = data['lastSeen'] as Map<String, dynamic>?;

        print("Typing Status Map: $typingStatusMap");
        print("Online Status Map: $onlineStatusMap");
        print("Last Seen Map: $lastSeenMap");

        // Check for receiverId (Guest User Id)
        final isReceiverTypingValue = typingStatusMap?[widget.receiverId] == true;
        final isReceiverOnline = onlineStatusMap?[widget.receiverId] == true;
        final lastSeenTimestamp = lastSeenMap?[widget.receiverId];

        print("widget.receiverId: ${widget.receiverId}");
        print("isReceiverTypingValue: $isReceiverTypingValue");

        String newStatusText = 'Offline'; // Default status

        if (isReceiverTypingValue) {
          newStatusText = 'Typing...';
          print("Setting receiverStatusText to 'Typing...'");
        } else if (isReceiverOnline) {
          newStatusText = 'Online';
          print("Setting receiverStatusText to 'Online'");
        } else if (lastSeenTimestamp != null && lastSeenTimestamp is Timestamp) {
          final dt = lastSeenTimestamp.toDate();
          final timeString = '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
          newStatusText = 'Last seen at $timeString';
          print("Setting receiverStatusText to 'Last seen at $timeString'");
        }

        // Only update if the status has changed
        if (receiverStatusText.value != newStatusText) {
          receiverStatusText.value = newStatusText;
        }

      } else {
        if (receiverStatusText.value != 'Offline') {
          receiverStatusText.value = 'Offline';
          print("Setting receiverStatusText to 'Offline' (no data)");// Default status when data is null
        }
      }
    }, onError: (error) {
      print("Error listening to receiver status: $error");
      if (receiverStatusText.value != 'Error') {
        receiverStatusText.value = 'Error';
        print("Setting receiverStatusText to 'Error'");// Set an error status
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
            Obx(() => Text(
              receiverStatusText.value,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            )),
          ],
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: GestureDetector( // Dismiss keyboard on tap
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
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
                      padding: const EdgeInsets.only(bottom: 10),
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final isMe = message.senderId == logic.myFbAuth.currentUser?.uid;

                        final showDateHeader = index == messages.length - 1 ||
                            (message.timestamp != null &&
                                messages[index + 1].timestamp != null &&
                                message.timestamp!.day != messages[index + 1].timestamp!.day);

                        return Column(
                          children: [
                            if (showDateHeader && message.timestamp != null) DateHeader(date: message.timestamp!),
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
                    onSendPressed: () async {
                      final text = _messageController.text.trim();
                      if (text.isNotEmpty) {
                        setState(() => isLoading = true);
                        await logic.sendMessage(widget.chatRoomId, widget.receiverId, text);
                        _setTyping(false);
                        _messageController.clear();
                        if (mounted) setState(() => isLoading = false);
                      }
                    },
                    onImagePressed: () async {
                      if (mounted) setState(() => isLoading = true);
                      await logic.pickImage(widget.chatRoomId, widget.receiverId);
                      if (mounted) setState(() => isLoading = false);
                    },
                    onChanged: (text) {
                      print("onChanged called. Text: $text");
                      final isTyping = text.isNotEmpty;
                      _setTyping(isTyping); // Set typing based on if text is empty or not.

                      if (isTyping) {
                        // Cancel the previous timer if it exists
                        _typingTimer?.cancel();

                        // Start a new timer
                        _typingTimer = Timer(const Duration(seconds: 2), () {
                          print("Timer fired. Setting typing to false.");
                          _setTyping(false);
                        });
                      } else {
                        // If the text is empty, immediately set typing to false and cancel the timer
                        _typingTimer?.cancel();
                        _setTyping(false);
                      }
                    },
                  ),
                ),
              ],
            ),
            if (isLoading) const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }
}