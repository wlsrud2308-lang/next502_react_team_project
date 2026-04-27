import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:next502_app/services/ChatSocketService.dart';
import 'dart:convert';

class ChatScreen extends StatefulWidget {
  // main.dart의 routes 설정에서 에러가 나지 않도록 인자를 제거합니다.
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  ChatSocketService? _chatService; // late 대신 ? 사용
  final List<Map<String, dynamic>> _messages = [];

  int? roomId;
  int? myUserSeq;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // didChangeDependencies는 context가 사용 가능해지는 시점이라 arguments를 꺼내기 좋습니다.
    if (!_isInitialized) {
      final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      roomId = args['roomId'];
      myUserSeq = args['myUserSeq'];

      // 데이터를 꺼낸 후 웹소켓 연결
      _chatService = ChatSocketService(
        roomId: roomId!,
        onMessageReceived: (data) {
          if (mounted) {
            setState(() => _messages.add(data));
          }
        },
      );
      _chatService!.connect();
      _loadChatHistory(); // 과거 내역 불러오기
      _isInitialized = true;
    }
  }

  // 과거 대화 내역 불러오기 API (URL 오타 수정)
  Future<void> _loadChatHistory() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2'),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> body = json.decode(response.body);
        final List<dynamic> content = body['content'];
        setState(() {
          // 최신순 정렬 등을 고려하여 리스트에 추가
          _messages.addAll(content.cast<Map<String, dynamic>>().reversed);
        });
      }
    } catch (e) {
      print("과거 내역 로드 에러: $e");
    }
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    _chatService?.sendMessage(myUserSeq!, _controller.text);
    _controller.clear();
  }

  void _sendImage() {
    print("이미지 선택창 열기");
  }

  @override
  void dispose() {
    _chatService?.disconnect();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // roomId가 로드되기 전까지 로딩 인디케이터 표시
    if (roomId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('채팅방')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                // 서버 데이터의 sender -> userSeq 구조 확인
                bool isMe = msg['sender']['userSeq'] == myUserSeq;
                return _buildChatBubble(msg, isMe);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(Map<String, dynamic> msg, bool isMe) {
    bool isImage = msg['chatType'] == 'IMAGE';
    bool isRead = msg['isReadYn'] == 'Y';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isMe) _buildReadStatus(isRead),
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Colors.deepPurple : Colors.grey[300],
              borderRadius: BorderRadius.circular(15),
            ),
            child: isImage
                ? Image.network(msg['fileUrl'] ?? '', errorBuilder: (c, e, s) => const Icon(Icons.broken_image))
                : Text(msg['content'] ?? '', style: TextStyle(color: isMe ? Colors.white : Colors.black)),
          ),
          if (!isMe) _buildReadStatus(isRead),
        ],
      ),
    );
  }

  Widget _buildReadStatus(bool isRead) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(isRead ? '' : '1', style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(onPressed: _sendImage, icon: const Icon(Icons.camera_alt)),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '메시지 입력...',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send, color: Colors.deepPurple)),
        ],
      ),
    );
  }
}

