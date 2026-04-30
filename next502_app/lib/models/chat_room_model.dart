class ChatRoomModel {
  final int chatRoomId;
  final String warehouseName;
  final String otherUserNick;
  final String lastMessage;
  final DateTime updateDate;

  ChatRoomModel({
    required this.chatRoomId,
    required this.warehouseName,
    required this.otherUserNick,
    required this.lastMessage,
    required this.updateDate,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json, int myId) {

    return ChatRoomModel(
      chatRoomId: json['chatRoomId'] as int,
      warehouseName: json['warehouseName'] ?? '이름 없는 창고',
      otherUserNick: json['userid'] ?? '익명 사용자',
      lastMessage: '채팅방 입장하기',
      updateDate: (json['updateDate'] != null && json['updateDate'] != "")
          ? DateTime.parse(json['updateDate'])
          : DateTime.now(),
    );
  }
}
