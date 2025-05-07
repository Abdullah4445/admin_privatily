import 'package:flutter/material.dart';

class MessageInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSendPressed;
  final VoidCallback onImagePressed;

  const MessageInputField({
    Key? key,
    required this.controller,
    required this.onSendPressed,
    required this.onImagePressed, required  onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
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
