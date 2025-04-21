import 'dart:typed_data'; // For image bytes
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart'; // Web-specific import
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/messages.dart';

class ChattingPageLogic extends GetxController {
  var messages = <Messages>[].obs;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore myFbFs = FirebaseFirestore.instance;
  final FirebaseAuth myFbAuth = FirebaseAuth.instance;

  // Method to send messages (text & image)
  Future<void> sendMessage(String chatRoomId, String receiverId, String messageText, {File? imageFile, Uint8List? imageBytes}) async {
    try {
      String senderId = myFbAuth.currentUser!.uid;
      String imageUrl = ""; // Default empty URL for text messages

      // Upload image if provided
      if (imageFile != null || imageBytes != null) {
        print("Uploading image...");
        Reference ref = storage.ref('chat_images/${DateTime.now().millisecondsSinceEpoch}.png');
        UploadTask uploadTask = imageFile != null ? ref.putFile(imageFile) : ref.putData(imageBytes!);

        TaskSnapshot uploadSnapshot = await uploadTask;
        imageUrl = await uploadSnapshot.ref.getDownloadURL();
        print("Image uploaded: $imageUrl");
      }

      // Save message in Firestore
      await myFbFs.collection('Guests')
          .doc(chatRoomId)
          .collection('Messages')
          .add({
        'senderId': senderId,
        'receiverId': receiverId,
        'messageText': messageText,
        'timestamp': FieldValue.serverTimestamp(),
        'messageType': imageFile != null || imageBytes != null ? 'image' : 'text',
        'imageUrl': imageUrl,
      });

      print("Message sent successfully");

    } catch (e) {
      print("Error sending message: $e");
      Get.snackbar('Error', 'Failed to send message');
    }
  }

  // Method to update messages
  void updateMessages(List<Messages> newMessages) {
    messages.value = newMessages;
  }

  // Fetch messages
  Stream<List<Messages>> getMessages(String chatRoomId) {
    return myFbFs
        .collection('Guests')
        .doc(chatRoomId)
        .collection('Messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) =>
        Messages.fromJson(doc.data(), doc.id))
        .toList());
  }

  // Image picker function (supports Web & Mobile)
  Future<void> pickImage(String chatRoomId, String receiverId) async {
    try {
      if (kIsWeb) {
        final pickedFile = await ImagePickerWeb.getImageAsBytes();
        if (pickedFile != null) {
          sendMessage(chatRoomId, receiverId, '', imageBytes: pickedFile);
        } else {
          print("No image selected");
        }
      } else {
        final XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          File imageFile = File(pickedFile.path);
          sendMessage(chatRoomId, receiverId, '', imageFile: imageFile);
        } else {
          print("No image selected");
        }
      }
    } catch (e) {
      print("Error selecting image: $e");
      Get.snackbar('Error', 'Error picking image');
    }
  }
}

