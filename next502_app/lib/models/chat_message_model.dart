import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessageModel {
  final String id;        // 👈 Firestore 랜덤 문자열 ID 수용을 위해 String 변경
  final String message;
  final String chatType;
  final String senderId;  // 👈 데이터 타입 충돌 방지를 위해 String 변경
  final String? fileUrl;
  final String createdAt;
  final String isReadYn;

  ChatMessageModel({
    required this.id,
    required this.message,
    required this.chatType,
    required this.senderId,
    this.fileUrl,
    required this.createdAt,
    required this.isReadYn,
  });

  ChatMessageModel copyWith({
    String? id,
    String? message,
    String? chatType,
    String? senderId,
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

  /// 1. 기존 스프링부트 REST API 및 소켓 데이터를 다룰 때 사용하는 생성자
  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id']?.toString() ?? '0', // 숫자가 오든 문자가 오든 문자로 안전하게 치환
      message: json['message'] ?? '',
      chatType: json['chatType'] ?? 'TEXT',
      senderId: json['senderId']?.toString() ?? '0',
      fileUrl: json['fileUrl'],
      createdAt: json['createDate'] ?? '',
      isReadYn: json['isReadYn'] ?? 'N',
    );
  }

  /// 2. ⚠️ [추가] 파이어베이스 Firestore에서 데이터를 가져올 때 사용하는 전용 생성자
  factory ChatMessageModel.fromFirestore(String docId, Map<String, dynamic> json) {
    String formattedCreatedAt;
    final dynamic rawCreatedAt = json['createdAt'];

    // Firestore의 Timestamp 및 Null 상태를 방어하는 안전한 파싱 로직
    if (rawCreatedAt is Timestamp) {
      formattedCreatedAt = rawCreatedAt.toDate().toIso8601String();
    } else if (rawCreatedAt is DateTime) {
      formattedCreatedAt = rawCreatedAt.toIso8601String();
    } else if (rawCreatedAt is String) {
      formattedCreatedAt = rawCreatedAt;
    } else {
      formattedCreatedAt = DateTime.now().toIso8601String(); // 기본값 부여
    }

    return ChatMessageModel(
      id: docId, // Firestore의 문서 고유 ID 주입
      message: json['content'] ?? '', // 팀원 규격인 content 매핑
      chatType: json['chatType'] ?? 'TEXT',
      senderId: json['senderId']?.toString() ?? '0',
      fileUrl: json['fileUrl'],
      createdAt: formattedCreatedAt,
      isReadYn: json['isRead'] == true ? 'Y' : 'N', // bool 타입을 기존 규격인 Y/N으로 치환
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


