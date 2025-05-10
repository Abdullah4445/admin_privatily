import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonQuestions extends StatelessWidget {
  final void Function(String) onSelect;
  final RxBool showToggle;

  const CommonQuestions({super.key, required this.onSelect, required this.showToggle});

  @override
  Widget build(BuildContext context) {
    final commonQuestions = [
      "Hello", "How are you?", "What are you doing?",
      "Where are you from?", "Can we talk?", "Are you available?",
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text("Common questions", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Obx(() => GestureDetector(
              onTap: () => showToggle.value = !showToggle.value,
              child: Icon(
                showToggle.value ? Icons.expand_less : Icons.expand_more,
                size: 20,
                color: Colors.grey.shade700,
              ),
            )),
          ],
        ),
        const SizedBox(height: 6),
        Obx(() => showToggle.value
            ? Wrap(
          spacing: 10,
          runSpacing: 10,
          children: commonQuestions.map((q) {
            return InkWell(
              onTap: () => onSelect(q),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Text(q, style: const TextStyle(fontSize: 13)),
              ),
            );
          }).toList(),
        )
            : const SizedBox.shrink()),
      ],
    );
  }
}
