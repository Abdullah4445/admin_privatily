import 'package:cloud_firestore/cloud_firestore.dart';

class Students {
  String name;
  int createdAt; // We'll store it as microsecondsSinceEpoch
  String id;

  Students({
    required this.name,
    required this.id,
    required this.createdAt,
  });

  // ✅ Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'createdAt': createdAt, // You can store as int
    };
  }

  // ✅ Create from Firestore JSON
  factory Students.fromJson(Map<String, dynamic> json) {
    int timestamp;

    if (json['createdAt'] is Timestamp) {
      // Firestore timestamp
      timestamp = (json['createdAt'] as Timestamp).microsecondsSinceEpoch;
    } else if (json['createdAt'] is int) {
      timestamp = json['createdAt'];
    } else {
      timestamp = 0; // fallback if unknown type
    }

    return Students(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      createdAt: timestamp,
    );
  }
}
