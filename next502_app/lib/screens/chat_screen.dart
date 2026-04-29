import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../widgets/chat_input.dart';
import '../models/chat_message_model.dart'; // 모델 import 확인

class ChatScreen extends StatefulWidget {
  final int chatRoomId;
  final String warehouseName;

  const ChatScreen({
    super.key,
    required this.chatRoomId,
    required this.warehouseName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  // 모델 리스트로 변경하여 데이터 관리를 안전하게 함
  final List<ChatMessageModel> _messages = [];
  late StompClient stompClient;

  @override
  void initState() {
    super.initState();
    _fetchChatHistory();
    _connect();
  }

  // 1. 과거 내역 로드 (URL 수정 완료)
  Future<void> _fetchChatHistory() async {
    try {
      // 주소를 서버 API 경로에 맞게 수정했습니다.
      final response = await http.get(
        Uri.parse('http://10.0.2{widget.chatRoomId}/messages'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        // Slice 객체 내부의 content 추출
        final List<dynamic> history = data['content'] ?? [];

        setState(() {
          _messages.addAll(history.map((e) => ChatMessageModel.fromJson(e)).toList());
        });
      }
    } catch (e) {
      debugPrint("과거 내역 로드 에러: $e");
    }
  }

  // 2. 웹소켓 연결
  void _connect() {
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://10.0.2.2:8080/ws-stomp',
        onConnect: (frame) {
          stompClient.subscribe(
            destination: '/sub/chat/room/${widget.chatRoomId}',
            callback: (frame) {
              if (frame.body != null) {
                setState(() {
                  // 수신된 메시지를 리스트 맨 앞에 추가
                  _messages.insert(0, ChatMessageModel.fromJson(json.decode(frame.body!)));
                });
              }
            },
          );
        },
        onWebSocketError: (e) => debugPrint('Websocket Error: $e'),
      ),
    );
    stompClient.activate();
  }

  // 3. 메시지 전송
  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final auth = context.read<AuthProvider>();
    if (auth.userId == null) return;

    stompClient.send(
      destination: '/pub/chat/message',
      body: json.encode({
        'chatRoom': {'chatRoomId': widget.chatRoomId},
        'sender': {'id': auth.userId},
        'message': _controller.text.trim(),
        'chatType': 'TEXT',
      }),
    );
    _controller.clear();
  }

  @override
  void dispose() {
    stompClient.deactivate();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myId = context.read<AuthProvider>().userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.warehouseName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, // 최신 메시지가 아래에 배치됨
              padding: const EdgeInsets.symmetric(vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                // 모델(ChatMessageModel)의 senderId를 사용하여 나/상대방 구분
                final bool isMe = msg.senderId == myId;

                return BubbleSpecialThree(
                  text: msg.message,
                  color: isMe ? const Color(0xFF673AB7) : const Color(0xFFE8E8EE),
                  tail: true,
                  isSender: isMe,
                  textStyle: TextStyle(
                    color: isMe ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ChatInput(
              controller: _controller,
              onSend: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}


