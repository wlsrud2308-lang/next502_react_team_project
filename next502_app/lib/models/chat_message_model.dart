class ChatMessageModel {
  final int id;
  final String message;
  final String chatType;
  final int senderId;
  final String? fileUrl;
  final String createdAt;
  final String isReadYn;

  ChatMessageModel({required this.id, required this.message, required this.chatType, required this.senderId, this.fileUrl, required this.createdAt,required this.isReadYn,});

  ChatMessageModel copyWith({
    int? id,
    String? message,
    String? chatType,
    int? senderId,
    String? fileUrl,
    String? createdAt,
    String? isReadYn,
  }) {
    return ChatMessageModel(
      id: id ?? this.id,
      message: message ?? this.message,
      chatType: chatType ?? this.chatType,
      senderId: senderId ?? this.senderId,
      fileUrl: fileUrl ?? this.fileUrl,
      createdAt: createdAt ?? this.createdAt,
      isReadYn: isReadYn ?? this.isReadYn,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] ?? 0,
      message: json['message'] ?? '',
      chatType: json['chatType'] ?? 'TEXT',
      senderId: json['senderId'] ?? 0,
      fileUrl: json['fileUrl'],
      createdAt: json['createDate'] ?? '',
      isReadYn: json['isReadYn'] ?? 'N',
    );
  }
}

class ChatRoomModel {
  final int chatRoomId;
  final String warehouseName;
  final String otherUserNick;
  final DateTime updateDate;

  ChatRoomModel({required this.chatRoomId, required this.warehouseName, required this.otherUserNick, required this.updateDate});

  factory ChatRoomModel.fromJson(Map<String, dynamic> json, int myId) {
    bool isMeBuyer = json['member']['id'] == myId;
    final opponent = isMeBuyer ? json['provider'] : json['member'];

    return ChatRoomModel(
      chatRoomId: json['chatRoomId'],
      warehouseName: json['warehouse']['name'] ?? '',
      otherUserNick: opponent['userNick'] ?? '이름 없음',
      updateDate: DateTime.parse(json['updateDate']),
    );
  }
}

