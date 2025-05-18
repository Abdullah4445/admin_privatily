import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:rxdart/rxdart.dart';
import '../chatting_page/chatting_page_view.dart';
import '../models/students.dart';

class HomeLogic extends GetxController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final String fixedAdminId = 'bnS6fNg9srhKktTSufF2AA9tdQZ2';

  Stream<List<Students>> getUserStreamOnFirebase() {
    return firestore.collection("ChatsRoomId").snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Students.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    }).onErrorReturn([]);
  }

  Future<void> createChatRoomId(String otherUserId, String receiverName) async {
    if (otherUserId.isEmpty) {
      Get.snackbar("Error", "❗ otherUserId is empty");
      return;
    }

    String chatRoomId = generateChatRoomId(fixedAdminId, otherUserId);

    try {
      DocumentSnapshot chatRoomDoc = await firestore.collection("ChatsRoomId").doc(chatRoomId).get();

      if (!chatRoomDoc.exists) {
        await firestore.collection('ChatsRoomId').doc(chatRoomId).set({
          'chatRoomId': chatRoomId,
          'participants': [fixedAdminId, otherUserId],
          'createdAt': FieldValue.serverTimestamp(),
        });
        print("✅ New Chat Room Created: $chatRoomId");
      } else {
        print("⚡ Chat Room Already Exists: $chatRoomId");
      }

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

  String generateChatRoomId(String userA, String userB) {
    List<String> ids = [userA, userB];

    // Ensure fixedAdminId is always the first element
    if (userA != fixedAdminId) {
      ids = [fixedAdminId, userA];  //put userA in userB's old place
    } else {
      ids = [userA, userB]; //userA is already the fixed admin id
    }

    String chatRoomId = ids.join("-");
    print("🔧 Generated ChatRoomId: $chatRoomId");
    return chatRoomId;
  }
}