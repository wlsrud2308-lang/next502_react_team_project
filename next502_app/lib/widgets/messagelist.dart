import 'package:flutter/material.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import '../models/chat_message_model.dart';
import '../widgets/chatImageBubble.dart';

class MessageList extends StatelessWidget {
  final List<ChatMessageModel> messages;
  final dynamic myId;

  const MessageList({super.key, required this.messages, required this.myId});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        final bool isMe = msg.senderId.toString() == myId.toString();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // [내가 보낸 메시지] 왼쪽에 '1' 표시
              if (isMe && msg.isReadYn == 'N')
                const Padding(
                  padding: EdgeInsets.only(right: 5, bottom: 2),
                  child: Text("1", style: TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold)),
                ),

              // 말풍선
              msg.chatType == 'IMAGE' && msg.fileUrl != null
                  ? ChatImageBubble(imageUrl: msg.fileUrl!, isMe: isMe, time: msg.createdAt.substring(11, 16))
                  : BubbleSpecialThree(
                text: msg.message,
                color: isMe ? const Color(0xFF673AB7) : const Color(0xFFE8E8EE),
                tail: true,
                isSender: isMe,
                textStyle: TextStyle(color: isMe ? Colors.white : Colors.black87, fontSize: 16),
              ),

              // [상대방이 보낸 메시지] 오른쪽에 '1' 표시 (내가 안 읽었을 때)
              if (!isMe && msg.isReadYn == 'N')
                const Padding(
                  padding: EdgeInsets.only(left: 5, bottom: 2),
                  child: Text("1", style: TextStyle(color: Colors.yellow, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        );
      },
    );
  }
}


