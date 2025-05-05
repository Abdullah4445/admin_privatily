import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/messages.dart';

class ChattingPageLogic extends GetxController {
  final FirebaseFirestore myFbFs = FirebaseFirestore.instance;
  final FirebaseAuth myFbAuth = FirebaseAuth.instance;
  var messages = <Messages>[].obs;

  // ✅ Send text message
  Future<void> sendMessage(String chatRoomId, String receiverId, String messageText) async {
    try {
      final senderId = myFbAuth.currentUser?.uid;
      if (senderId == null) return;

      await myFbFs.collection('ChatsRoomId').doc(chatRoomId).collection('Messages').add({
        'senderId': senderId,
        'receiverId': receiverId,
        'messageText': messageText,
        'messageType': 'text',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      Get.snackbar('Send Failed', e.toString());
    }
  }

  // ✅ Pick & send image message (placeholder only)
  Future<void> pickImage(String chatRoomId, String receiverId) async {
    // You can use image_picker or file_picker package here
    // For now, let's simulate sending an image URL
    final dummyImageUrl = "https://via.placeholder.com/150";
    final senderId = myFbAuth.currentUser?.uid;

    await myFbFs.collection('ChatsRoomId').doc(chatRoomId).collection('Messages').add({
      'senderId': senderId,
      'receiverId': receiverId,
      'messageType': 'image',
      'imageUrl': dummyImageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ✅ Get messages from Firestore
  Stream<List<Messages>> getMessages(String chatRoomId) {
    return myFbFs
        .collection('ChatsRoomId')
        .doc(chatRoomId)
        .collection('Messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Messages.fromJson(doc.data(), doc.id))
        .toList());
  }

  void updateMessages(List<Messages> newMessages) {
    messages.value = newMessages;
    }
}
