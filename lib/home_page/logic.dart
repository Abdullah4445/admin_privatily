import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../chatting_page/chatting_page_view.dart';
import '../models/students.dart';
import '../utils/utils.dart';

class HomeLogic extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<Students> getStudents = [];
  final String fixedAdminId = 'bnS6fNg9srhKktTSufF2AA9tdQZ2';

  Future<List<Students>> getUserOnFirebase() async {
    try {
      QuerySnapshot data = await firestore.collection("ChatsRoomId").get();
      for (var element in data.docs) {
        Students students =
        Students.fromJson(element.data() as Map<String, dynamic>);
        getStudents.add(students);
      }
      return getStudents;
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch users: $e");
      return [];
    }
  }
  Future<void> createChatRoomId(String otherUserId, String receiverName) async {
    try {
      if (otherUserId.isEmpty) {
        Get.snackbar("Error", "❗ otherUserId is empty");
        return;
      }

      String chatRoomId = generateChatRoomId(otherUserId,fixedAdminId, );

      print("📌 fixedAdminId: $fixedAdminId");
      print("📌 otherUserId: $otherUserId");
      print("🔍 Checking ChatRoom: $chatRoomId");

      DocumentSnapshot chatRoomDoc = await firestore
          .collection("ChatsRoomId")
          .doc(chatRoomId)
          .get();

      if (!chatRoomDoc.exists) {
        print("🆕 Chat Room Does NOT Exist, creating new one...");
        await firestore.collection('ChatsRoomId').doc(chatRoomId).set({
          'chatRoomId': chatRoomId,
          'participants': [fixedAdminId, otherUserId],
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("✅ New Chat Room Created: $chatRoomId");
      } else {
        print("⚡ Chat Room Already Exists: $chatRoomId");
      }

      // Navigate to chat page
      Get.to(() => ChattingPage(
        chatRoomId: chatRoomId,
        receiverId: otherUserId,
        receiverName: receiverName,
      ));
    } catch (e) {
      Get.snackbar("Error", "❌ Failed to create chat room: $e");
      print("❌ Error creating chat room: $e");
    }
  }
}
