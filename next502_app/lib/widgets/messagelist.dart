import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import '../models/chat_message_model.dart';
import '../widgets/chatImageBubble.dart';

class MessageList extends StatelessWidget {
  final List<ChatMessageModel> messages;
  final dynamic myId;

  const MessageList({super.key, required this.messages, required this.myId});

  // 시간을 안전하게 잘라주는 헬퍼 함수
  String _formatTime(String createdAt) {
    if (createdAt.isEmpty) return "";

    try {
      // T가 포함된 경우 (2026-04-30T15:21:27)
      if (createdAt.contains('T')) {
        return createdAt.split('T')[1].substring(0, 5);
      }
      // 공백으로 구분된 경우 (2026-04-30 15:21:27)
      if (createdAt.length >= 16) {
        return createdAt.substring(11, 16);
      }
    } catch (e) {
      debugPrint("시간 파싱 에러: $e");
    }
    return createdAt; // 파싱 실패 시 원본 반환
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final bool isMe = msg.senderId.toString() == myId.toString();
        final String displayTime = _formatTime(msg.createdAt);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // [내가 보낸 메시지] 왼쪽에 '1' 및 시간 표시
                  if (isMe) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (msg.isReadYn == 'N')
                          const Text("1", style: TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(displayTime, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                    const SizedBox(width: 5),
                  ],

                  // 말풍선 (이미지 vs 텍스트)
                  msg.chatType == 'IMAGE' && msg.fileUrl != null
                      ? ChatImageBubble(
                    imageUrl: msg.fileUrl!,
                    isMe: isMe,
                    time: displayTime,
                  )
                      : BubbleSpecialThree(
                    text: msg.message,
                    color: isMe ? const Color(0xFF673AB7) : const Color(0xFFE8E8EE),
                    tail: true,
                    isSender: isMe,
                    textStyle: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 16),
                  ),

                  // [상대방이 보낸 메시지] 오른쪽에 '1' 및 시간 표시
                  if (!isMe) ...[
                    const SizedBox(width: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg.isReadYn == 'N')
                          const Text("1", style: TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(displayTime, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}



