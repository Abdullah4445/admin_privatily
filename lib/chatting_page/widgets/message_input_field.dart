import 'package:flutter/material.dart';

class MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed;
  final VoidCallback onImagePressed;
  final ValueChanged<String> onChanged; // Fix here

  const MessageInputField({
    Key? key,
    required this.controller,
    required this.onSendPressed,
    required this.onImagePressed,
    required this.onChanged, // Fix here
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged, // <- Use onChanged here
            decoration: InputDecoration(
              hintText: "Type a message...",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ),
        IconButton(
          onPressed: onImagePressed,
          icon: const Icon(Icons.image),
        ),
        GestureDetector(
          onTap: onSendPressed,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.deepPurple,
            ),
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
