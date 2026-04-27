class ChatMessageModel {
  final int? messageSeq;
  final int chatRoomSeq;
  final int senderSeq;
  final String content;
  final String chatType; // TEXT, IMAGE, VOICE
  final String? fileUrl;
  final String isReadYn;
  final DateTime createDate;

  ChatMessageModel({
    this.messageSeq,
    required this.chatRoomSeq,
    required this.senderSeq,
    required this.content,
    required this.chatType,
    this.fileUrl,
    this.isReadYn = 'N',
    required this.createDate,
  });

  // JSON -> Object (서버에서 받을 때)
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      messageSeq: json['messageSeq'],
      chatRoomSeq: json['chatRoom']['chatRoomSeq'],
      senderSeq: json['sender']['userSeq'],
      content: json['content'] ?? '',
      chatType: json['chatType'],
      fileUrl: json['fileUrl'],
      isReadYn: json['isReadYn'],
      createDate: DateTime.parse(json['createDate']),
    );
  }
}
