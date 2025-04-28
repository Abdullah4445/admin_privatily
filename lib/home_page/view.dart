import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/students.dart';
import 'logic.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final HomeLogic logic = Get.put(HomeLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white)),
        backgroundColor: Colors.deepPurple,

      ),
    //  using stream
      body: Column(
        children: [
          Expanded(
           child: StreamBuilder<List<Students>>(
      stream: logic.getUserStreamOnFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.deepPurple),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No users found",
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        final users = snapshot.data!;
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        final filteredUsers = users.where((user) => user.id != currentUserId).toList();

        if (filteredUsers.isEmpty) {
          return const Center(
            child: Text(
              "No other users found",
              style: TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final user = filteredUsers[index];

            return Card(
              elevation: 6,
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                onTap: () => logic.createChatRoomId(user.id, user.guestName),
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Text(
                    user.guestName.isNotEmpty ? user.guestName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  user.guestName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
            );
          },
        );
      },
    ),

    ),
        ],
      ),
    );
  }
}