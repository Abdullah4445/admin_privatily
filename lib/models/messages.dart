// import 'package:cloud_firestore/cloud_firestore.dart';

// class Messages {
//   final String id;
//   final String senderId;
//   final String receiverId;
//   final String messageText;
//   final String messageType;
//   final String? imageUrl;
//
//   Messages({
//     required this.id,
//     required this.senderId,
//     required this.receiverId,
//     required this.messageText,
//     required this.messageType,
//     this.imageUrl,
//   });
//
//   factory Messages.fromJson(Map<String, dynamic> json, String id) {
//     return Messages(
//       id: id,
//       senderId: json['senderId'] ?? '',
//       receiverId: json['receiverId'] ?? '',
//       messageText: json['messageText'] ?? '',
//       messageType: json['messageType'] ?? 'text',
//       imageUrl: json['imageUrl'],
//     );
//   }
//
//   Map<String, dynamic> toJson() => {
//     'senderId': senderId,
//     'receiverId': receiverId,
//     'messageText': messageText,
//     'messageType': messageType,
//     if (imageUrl != null) 'imageUrl': imageUrl,
//   };
// }



import 'package:cloud_firestore/cloud_firestore.dart';

class Messages {
  String id;
  String senderId;
  String messageText;
  String receiverId;
  String messageType; // 'text' or 'image'
  DateTime? timestamp;
  String? imageUrl;

  Messages({
    required this.id,
    required this.senderId,
    required this.messageText,
    required this.receiverId,
    required this.messageType,
    this.timestamp,
    this.imageUrl,
  });

  factory Messages.fromJson(Map<String, dynamic> json, String id) {
    return Messages(
      id: id,
      senderId: json['senderId'] ?? '',
      messageText: json['messageText'] ?? '',
      receiverId: json['receiverId'] ?? '',
      messageType: json['messageType'] ?? 'text',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate(),
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'messageText': messageText,
      'receiverId': receiverId,
      'messageType': messageType,
      'timestamp': timestamp != null
          ? Timestamp.fromDate(timestamp!)
          : FieldValue.serverTimestamp(),
      'imageUrl': imageUrl,
    };
  }
}
