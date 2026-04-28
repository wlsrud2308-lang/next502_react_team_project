import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../widgets/chat_input.dart';

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
  final List<Map<String, dynamic>> _messages = [];
  late StompClient stompClient;

  @override
  void initState() {
    super.initState();
    _fetchChatHistory(); // 1. 과거 내역 로드
    _connect();          // 2. 웹소켓 연결
  }

  // 백엔드 API: GET /chat/room/{chatRoomId}/messages 호출
  Future<void> _fetchChatHistory() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2{widget.chatRoomId}/messages'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        // Slice 객체인 경우 content 리스트 추출
        final List<dynamic> history = data['content'] ?? data;

        setState(() {
          _messages.addAll(history.map((e) => e as Map<String, dynamic>).toList());
        });
      }
    } catch (e) {
      debugPrint("과거 내역 로드 에러: $e");
    }
  }

  void _connect() {
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://10.0.2.2:8080/ws-stomp',
        onConnect: (frame) {
          // 구독 경로: /sub/chat/room/{chatRoomId}
          stompClient.subscribe(
            destination: '/sub/chat/room/${widget.chatRoomId}',
            callback: (frame) {
              if (frame.body != null) {
                setState(() {
                  _messages.insert(0, json.decode(frame.body!));
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

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final auth = context.read<AuthProvider>();
    if (auth.userId == null) return; // AuthProvider에 userId 필드가 있어야 함

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
    // AuthProvider에서 내 PK 아이디를 가져와 나/상대방 구분
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
              reverse: true, // 최신 메시지가 아래에 오도록
              padding: const EdgeInsets.symmetric(vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];

                // sender 정보 추출 (Map 구조 대응)
                final dynamic senderData = msg['sender'];
                final int senderId = (senderData is Map) ? senderData['id'] : senderData;
                final bool isMe = senderId == myId;

                return BubbleSpecialThree(
                  text: msg['message'] ?? '',
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
          // 키보드가 올라올 때 입력창 가려짐 방지
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


