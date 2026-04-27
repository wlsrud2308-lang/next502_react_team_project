class ChatRoomModel {
  final int chatRoomSeq;
  final String warehouseName; // 창고 이름
  final String otherUserNick; // 상대방 닉네임
  final String lastMessage;   // 마지막 메시지
  final DateTime updateDate;  // 마지막 대화 시간

  ChatRoomModel({
    required this.chatRoomSeq,
    required this.warehouseName,
    required this.otherUserNick,
    required this.lastMessage,
    required this.updateDate,
  });

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) {
    return ChatRoomModel(
      chatRoomSeq: json['chatRoomSeq'],
      warehouseName: json['warehouse']['name'],
      // 내가 구매자면 판매자 닉네임을, 내가 판매자면 구매자 닉네임을 가져오는 로직 필요
      otherUserNick: json['provider']['userNick'],
      lastMessage: json['status'], // 실제로는 마지막 메시지 필드를 서버에서 주는 게 좋음
      updateDate: DateTime.parse(json['updateDate']),
    );
  }
}
