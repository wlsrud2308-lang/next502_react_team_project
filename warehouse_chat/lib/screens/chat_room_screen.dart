

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// 실제 채팅이 이루어지는 화면
// Firestore의 실시간 데이터(Stream)를 사용하여 메시지를 표시
class ChatRoomScreen extends StatefulWidget {
  final String userId;
  final String roomId;

  const ChatRoomScreen({super.key, required this.userId, required this.roomId});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  // 메시지 입력을 위한 컨트롤러
  final TextEditingController _messageController = TextEditingController();
  // Firestore 인스턴스 참조
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 메시지 전송 로직
  // Firestore의 해당 채팅방 'messages' 서브 컬렉션에 문서를 추가합니다.
  void _sendMessage() async {
    String text = _messageController.text.trim();
    if (text.isEmpty) return; // 빈 메시지는 전송하지 않음

    _messageController.clear(); // 전송 즉시 입력창 초기화 (사용자 경험 개선)

    try {
      // React 웹과 동일한 데이터 구조 및 키값을 사용하여 호환성을 유지합니다.
      // Firestore 경로: chatRooms/{roomId}/messages
      await _firestore
          .collection('chatRooms')
          .doc(widget.roomId)
          .collection('messages')
          .add({
        'senderId': widget.userId,
        'content': text,
        'createdAt': FieldValue.serverTimestamp(), // 서버측 시간 사용 (기기 간 시간차 방지)
        'isRead': false,
      });
    } catch (e) {
      // 전송 중 에러 발생 시 로그 출력
      debugPrint("메시지 전송 에러: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text('방 번호: ${widget.roomId}'),
      ),
      body: Column(
        children: [
          // 메시지 목록 영역 (실시간 데이터 연동)
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Firestore 쿼리 설정: 최신 메시지가 위로 오도록 정렬 (ListView.reverse와 조합)
              stream: _firestore
                  .collection('chatRooms')
                  .doc(widget.roomId)
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // 데이터 수신 대기 중일 때 로딩 인디케이터 표시
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 데이터가 없거나 문서가 비어있을 경우 처리
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('메시지가 없습니다.'));
                }

                var messages = snapshot.data!.docs;

                // 채팅 인터페이스 구현을 위해 reverse: true를 사용
                return ListView.builder(
                  reverse: true, // 하단부터 아이템이 쌓이도록 설정
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var msg = messages[index].data() as Map<String, dynamic>;
                    bool isMe = msg['senderId'] == widget.userId;

                    // 말풍선 UI 생성
                    return _buildChatBubble(msg, isMe);
                  },
                );
              },
            ),
          ),

          // 하단 메시지 입력창 UI
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onSubmitted: (_) => _sendMessage(), // 키보드 엔터(완료) 버튼 대응
                  ),
                ),
                const SizedBox(width: 8),
                // 전송 아이콘 버튼
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 말풍선 UI 위젯 메서드
  // [msg]: Firestore에서 가져온 메시지 데이터 Map
  // [isMe]: 현재 사용자가 보낸 메시지인지 여부
  Widget _buildChatBubble(Map<String, dynamic> msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // 보낸 사람의 ID 표시
            Text(
              msg['senderId'] ?? 'Unknown',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 2),
            // 메시지 내용이 담긴 박스
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                // 나: 노란색, 상대방: 하얀색 (카카오톡 스타일)
                color: isMe ? const Color(0xFFFFE33A) : Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: isMe ? null : Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                msg['content'] ?? '',
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}









