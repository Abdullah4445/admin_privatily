String generateChatRoomId(String userA, String userB) {
  final ids = [userA, userB]..sort();
  String chatRoomId = ids.join("-");
  print("🔧 Generated ChatRoomId: $chatRoomId");
  return chatRoomId;
}
