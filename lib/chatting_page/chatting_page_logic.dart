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

  // Method to send text and image messages
  Future<void> sendMessage(String chatRoomId, String receiverId, String messageText, {File? imageFile, Uint8List? imageBytes}) async {
    try {
      String senderId = myFbAuth.currentUser!.uid;
      String imageUrl = ""; // Default image URL for text messages

      // If an image is selected, upload it to Firebase Storage
      if (imageFile != null) {
        print("Uploading image..."); // Debug log
        // Upload image to Firebase Storage
        TaskSnapshot uploadTask = await storage
            .ref('chat_images/${'img.png'}')
            .putFile(imageFile);
        imageUrl = await uploadTask.ref.getDownloadURL();
        print("Image uploaded successfully: $imageUrl"); // Debug log
      } else if (imageBytes != null) {
        print("Uploading image bytes..."); // Debug log
        // For Web: Upload image bytes directly to Firebase Storage
        TaskSnapshot uploadTask = await storage
            .ref('chat_images/${'img.png'}')
            .putData(imageBytes); // Upload directly from bytes
        imageUrl = await uploadTask.ref.getDownloadURL();
        print("Image uploaded successfully: $imageUrl"); // Debug log
      }

      // Save message and image URL in Firestore
      await myFbFs.collection('Chatting')
          .doc(chatRoomId)
          .collection('Messages')
          .add({
        'senderId': senderId,
        'messageText': messageText,
        'receiverId': receiverId,
        'timestamp': FieldValue.serverTimestamp(),
        'messageType': imageFile != null || imageBytes != null ? 'image' : 'text',
        'imageUrl': imageUrl, // Store image URL if any
      });
      print("Message saved to Firestore with image URL: $imageUrl"); // Debug log

    } catch (e) {
      print("Error during image upload: $e"); // Debug log
      Get.snackbar('Error', 'Failed to send message: $e');
    }
  }

  // Method to update the messages list
  void updateMessages(List<Messages> newMessages) {
    messages.value = newMessages; // Update the messages observable
  }

  // Method to fetch messages from Firestore
  Stream<List<Messages>> getMessages(String chatRoomId) {
    try {
      return myFbFs
          .collection('Chatting')
          .doc(chatRoomId)
          .collection('Messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) =>
          Messages.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList());
    } catch (e) {
      print('Error fetching messages: $e');
      return Stream.value([]);
    }
  }

  // Method to pick image from the gallery for web
  Future<void> pickImage() async {
    try {
      if (kIsWeb) {
        final pickedFile = await ImagePickerWeb.getImageAsBytes();
        if (pickedFile != null) {
          sendMessage('chatRoomId', 'receiverId', '', imageBytes: pickedFile); // Send image directly as bytes
        }
      } else {
        final XFile? pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          File imageFile = File(pickedFile.path);
          sendMessage('chatRoomId', 'receiverId', '', imageFile: imageFile); // Send image with an empty message
        }
      }
    } catch (e) {
      print("Error selecting image: $e");
      Get.snackbar('Error', 'Error picking image: $e');
    }
  }
}
