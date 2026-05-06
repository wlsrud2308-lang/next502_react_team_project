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
      if (createdAt.contains('T')) {
        return createdAt.split('T')[1].substring(0, 5);
      }
      if (createdAt.length >= 16) {
        return createdAt.substring(11, 16);
      }
    } catch (e) {
      debugPrint("시간 파싱 에러: $e");
    }
    return createdAt;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true, // 최신 메시지가 아래에 오도록 역순 배치
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final bool isMe = msg.senderId.toString() == myId.toString();
        final String displayTime = _formatTime(msg.createdAt);


        // 1. 이미지 타입인 경우
        if (msg.chatType.toUpperCase() == 'IMAGE' && msg.fileUrl != null) {
          return ChatImageBubble(
            imageUrl: msg.fileUrl!,
            isMe: isMe,
            time: displayTime,
          );
        }

        // 2. 보이스톡 타입인 경우 (필요 시 추가)
        if (msg.chatType.toUpperCase() == 'VOICE') {
          return _buildVoiceMessage(isMe, displayTime);
        }

        // 3. 일반 텍스트 타입인 경우
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 내가 보낸 메시지라면 왼쪽에 상태 표시
              if (isMe) _buildStatus(msg.isReadYn, displayTime, isMe),
              if (isMe) const SizedBox(width: 5),

              BubbleSpecialThree(
                text: msg.message,
                color: isMe ? const Color(0xFF673AB7) : const Color(0xFFE8E8EE),
                tail: true,
                isSender: isMe,
                textStyle: TextStyle(
                  color: isMe ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),

              // 상대방이 보낸 메시지라면 오른쪽에 상태 표시
              if (!isMe) const SizedBox(width: 5),
              if (!isMe) _buildStatus(msg.isReadYn, displayTime, isMe),
            ],
          ),
        );
      },
    );
  }

  // 읽음 숫자 '1'과 시간 표시 위젯
  Widget _buildStatus(String isReadYn, String time, bool isMe) {
    return Column(
      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (isReadYn == 'N')
          const Text(
            "1",
            style: TextStyle(
              color: Colors.yellow,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        Text(
          time,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ],
    );
  }

  // 보이스톡용 간이 UI (필요 시)
  Widget _buildVoiceMessage(bool isMe, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.phone_callback, size: 16),
            const SizedBox(width: 5),
            const Text("보이스톡 종료"),
            const SizedBox(width: 5),
            Text(time, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}


