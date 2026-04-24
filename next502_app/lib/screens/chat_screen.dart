import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  // 메시지 데이터 리스트 (상태 관리)
  final List<Map<String, dynamic>> _messages = [
    {'text': '안녕하세요, 창고 문의 드립니다!', 'isMe': true, 'isRead': true, 'type': 'text'},
    {'text': '네, 안녕하세요! 어떤 창고가 궁금하신가요?', 'isMe': false, 'isRead': true, 'type': 'text'},
  ];

  // 1. 메시지 전송 기능
  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'text': _controller.text,
        'isMe': true,
        'isRead': false, // 새로 보낸 메시지는 아직 안 읽음 상태
        'type': 'text'
      });
      _controller.clear(); // 입력창 비우기
    });
  }

  // 3. 이미지 전송 기능 (UI 시뮬레이션)
  void _sendImage() {
    setState(() {
      _messages.add({
        'text': '창고 사진입니다.',
        'isMe': true,
        'isRead': false,
        'type': 'image' // 이미지 타입 추가
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('임대인 01')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg) {
    bool isMe = msg['isMe'];
    bool isImage = msg['type'] == 'image';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isMe) _buildReadStatus(msg['isRead']), // 2. 읽음 표시 (나일 때만)
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Colors.deepPurple : Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
            child: isImage
                ? const Icon(Icons.image, size: 100, color: Colors.white) // 이미지 대신 아이콘
                : Text(msg['text'], style: TextStyle(color: isMe ? Colors.white : Colors.black)),
          ),
          if (!isMe) _buildReadStatus(msg['isRead']),
        ],
      ),
    );
  }

  // 읽음 표시 위젯
  Widget _buildReadStatus(bool isRead) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        isRead ? '' : '1', // 읽지 않았으면 1 표시
        style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(onPressed: _sendImage, icon: const Icon(Icons.camera_alt)), // 이미지 전송 버튼
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '메시지 입력...',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _sendMessage(), // 엔터 쳐도 전송
            ),
          ),
          IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send, color: Colors.deepPurple)),
        ],
      ),
    );
  }
}
