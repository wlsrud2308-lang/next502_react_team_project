import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chat_bubbles/chat_bubbles.dart'; // 패키지
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../providers/auth_provider.dart';
import '../widgets/chat_input.dart'; // 만드신 위젯

class ChatDetailScreen extends StatefulWidget {
  final int chatRoomId;
  final String warehouseName;

  const ChatDetailScreen({
    super.key,
    required this.chatRoomId,
    required this.warehouseName,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = []; // 메시지 리스트
  late StompClient stompClient;

  @override
  void initState() {
    super.initState();
    _connect();
  }

  // 웹소켓 연결 로직
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
                  _messages.insert(0, json.decode(frame.body!));
                });
              }
            },
          );
        },
      ),
    );
    stompClient.activate();
  }

  // 메시지 전송 로직
  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final auth = context.read<AuthProvider>();
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
    // AuthProvider에서 내 ID를 가져옴 (isMe 판단용)
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
          // 1. 메시지 리스트 영역
          Expanded(
            child: ListView.builder(
              reverse: true, // 최신 메시지가 아래로 오게 설정
              padding: const EdgeInsets.symmetric(vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final bool isMe = msg['sender']['id'] == myId;

                // chat_bubbles 패키지 위젯 사용
                return BubbleSpecialThree(
                  text: msg['message'],
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

          // 2. 하단 입력창 영역 (직접 만드신 위젯)
          // 키보드가 올라올 때 입력창이 가려지지 않게 처리
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
