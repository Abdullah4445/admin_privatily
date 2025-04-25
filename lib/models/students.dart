import 'package:cloud_firestore/cloud_firestore.dart';

class Students {
  String guestName;
  int createdAt; // Stored as microsecondsSinceEpoch
  String id;

  Students({
    required this.guestName,
    required this.id,
    required this.createdAt,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': guestName,
      'id': id,
      'createdAt': createdAt,
    };
  }

  // Create from Firestore JSON
  factory Students.fromJson(Map<String, dynamic> json) {
    int timestamp;

    if (json['createdAt'] is Timestamp) {
      timestamp = (json['createdAt'] as Timestamp).microsecondsSinceEpoch;
    } else if (json['createdAt'] is int) {
      timestamp = json['createdAt'];
    } else {
      timestamp = 0; // Fallback if unknown type
    }

    return Students(
      guestName: json['guestName'] ?? '',
      id: json['id'] ?? '',
      createdAt: timestamp,
    );
  }
}
