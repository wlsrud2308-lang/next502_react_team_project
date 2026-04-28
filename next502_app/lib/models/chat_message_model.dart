class ChatMessageModel {
  final int id;
  final String message;
  final String chatType;
  final int senderId;
  final String? fileUrl;
  final String createdAt;

  ChatMessageModel({
    required this.id,
    required this.message,
    required this.chatType,
    required this.senderId,
    this.fileUrl,
    required this.createdAt,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as int? ?? 0,
      message: json['message'] ?? '',
      chatType: json['chatType'] ?? 'TEXT',
      // 백엔드 sender 객체에서 id만 추출
      senderId: json['sender'] != null ? json['sender']['id'] : 0,
      fileUrl: json['fileUrl'],
      createdAt: json['createDate'] ?? '', // BaseTimeEntity 필드명 확인
    );
  }
}
