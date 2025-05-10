import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

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

  @override
  void onClose() {
    // You don't need to call Get.delete here. GetX manages the lifecycle.
    super.onClose();
  }
}