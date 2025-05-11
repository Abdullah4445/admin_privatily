import 'dart:ui';

import 'package:admin_privatily/chatting_page/widgets/variables/globalVariables.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../firebase_utils.dart';
import '../models/messages.dart'; // Ensure this path is correct

class ChattingPageLogic extends GetxController {
  final FirebaseFirestore myFbFs = FirebaseFirestore.instance;
  final FirebaseAuth myFbAuth = FirebaseAuth.instance;
  var messages = <Messages>[].obs;
  final RxBool receiverOnlineStatus = false.obs;
  final RxBool isLoading = false.obs; // Added isLoading observable

  // ✅ Send text message
  Future<void> sendMessage(String chatRoomId, String receiverId, String messageText) async {
    isLoading.value = true;
    try {
      final senderId = myFbAuth.currentUser?.uid;
      if (senderId == null) return;

      await myFbFs.collection('ChatsRoomId').doc(chatRoomId).collection('Messages').add({
        'senderId': senderId,
        'receiverId': receiverId,
        'messageText': messageText,
        'messageType': 'text',
        'timestamp': FieldValue.serverTimestamp(),
      }); // success message
    } catch (e) {
      print("Error sending message: $e"); // Crucial for debugging
      Get.snackbar('Send Failed', 'An error occurred: ${e.toString()}'); // User-friendly message
    } finally {
      print("Finally block executed");
      isLoading.value = false; // Stop loading
    }
  }

  // ✅ Pick & send image message (placeholder only)
  Future<void> pickImage(String chatRoomId, String receiverId) async {
    isLoading.value = true; // Start loading
    try {
      // You can use image_picker or file_picker package here
      // For now, let's simulate sending an image URL
      const dummyImageUrl = "https://via.placeholder.com/150";
      final senderId = myFbAuth.currentUser?.uid;
      if (senderId == null) return;

      await myFbFs.collection('ChatsRoomId').doc(chatRoomId).collection('Messages').add({
        'senderId': senderId,
        'receiverId': receiverId,
        'messageType': 'image',
        'imageUrl': dummyImageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });
      Get.snackbar('Success', 'Image sent successfully!'); // success message
    } catch (e) {
      print("Error picking image: $e");
      Get.snackbar('Image Upload Failed', 'An error occurred: ${e.toString()}');
    } finally{
      isLoading.value = false; // Stop loading
    }
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

  void didChangeAppLifecycleState(AppLifecycleState state,String chatIdoomId ) {
    if (state == AppLifecycleState.resumed) {
      setUserOnline(globalChatRoomId);
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      setUserOffline(chatIdoomId);
    }
  }
  Future<void> setUserOffline(String chatIdoomId ) async {
    final user = myFbAuth.currentUser;
    if (user != null) {
      await myFbFs.collection('ChatsRoomId').doc(chatIdoomId).collection("usersStatus").doc(user.uid).set({
        'isOnline': false,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }
  void setTypingStatus(bool isTyping ,String chatIdoomId ) async {
    final user = myFbAuth.currentUser;
    if (user != null) {
      await myFbFs.collection('ChatsRoomId').doc(chatIdoomId).collection("usersStatus").doc(user.uid).set({
        'isTyping': isTyping,
      }, SetOptions(merge: true));
    }
  }

  @override
  void onClose() {
    // You don't need to call Get.delete here. GetX manages the lifecycle.
    super.onClose();
  }

// Future<void> setUserOnline() async {
//   final user = _auth.currentUser;
//   if (user != null) {
//     try {
//       await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//         'isOnline': true,
//         'lastSeen': FieldValue.serverTimestamp(),
//       }, SetOptions(merge: true));
//       print("User ${user.uid} set to online");
//     } catch (e) {
//       print("Error setting user online: $e");
//     }
//   } else {
//     print("No user logged in, cannot set online status.");
//   }
// }
}