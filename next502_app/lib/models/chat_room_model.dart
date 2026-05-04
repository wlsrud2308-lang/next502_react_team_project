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

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    // 1. chatRoomId가 String으로 올 경우를 대비한 안전한 파싱
    final dynamic rawRoomId = json['chatRoomId'];
    final int parsedRoomId = rawRoomId is int
        ? rawRoomId
        : int.tryParse(rawRoomId?.toString() ?? '') ?? 0;

    return ChatRoomModel(
      chatRoomId: parsedRoomId,
      warehouseName: json['warehouseName'] ?? '이름 없는 창고',
      otherUserNick: json['userid'] ?? '익명 사용자',
      lastMessage: json['lastMessage'] ?? '',

      // 2. 문자열 'null'이 들어오는 경우까지 완벽 방어
      updateDate: (json['updateDate'] != null && json['updateDate'] != "" && json['updateDate'] != "null")
          ? DateTime.parse(json['updateDate'])
          : DateTime.now(),
    );
  }
}
