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
    final bool isMeBuyer = json['member']['id'] == myId;

    final opponent = isMeBuyer ? json['provider'] : json['member'];

    return ChatRoomModel(
      chatRoomId: json['chatRoomId'] as int,
      warehouseName: json['warehouse']['name'] ?? '',
      otherUserNick: opponent['userNick'] ?? '이름 없음',
      lastMessage: json['status'] == 'OPEN' ? '대화 중인 방입니다' : '종료된 대화',
      updateDate: DateTime.parse(json['updateDate']),
    );
  }
}
