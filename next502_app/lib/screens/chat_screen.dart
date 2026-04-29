import 'dart:convert';
import 'dart:io'; // 추가: File 객체 사용
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // 추가: ImageSource 오류 해결
import 'package:next502_app/widgets/chatImageBubble.dart';
import 'package:provider/provider.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:http/http.dart' as http;
import '../providers/auth_provider.dart';
import '../widgets/chat_input.dart';
import '../models/chat_message_model.dart';

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
  final List<ChatMessageModel> _messages = [];
  final ImagePicker _picker = ImagePicker(); // 추가
  late StompClient stompClient;

  @override
  void initState() {
    super.initState();
    _fetchChatHistory();
    _connect();
  }

  // 1. 과거 내역 로드
  Future<void> _fetchChatHistory() async {
    final auth = context.read<AuthProvider>();
    final String? token = auth.token;

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/chat/room/${widget.chatRoomId}/messages'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> content = data['content'] ?? [];
        setState(() {
          _messages.clear();
          _messages.addAll(content.map((e) => ChatMessageModel.fromJson(e)).toList());
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

  // 3. 텍스트 메시지 전송
  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final auth = context.read<AuthProvider>();
    if (auth.userId == null) return;

    stompClient.send(
      destination: '/pub/chat/message',
      body: json.encode({
        'chatRoomId': widget.chatRoomId,
        'senderId': auth.userId,
        'message': _controller.text.trim(),
        'chatType': 'TEXT',
      }),
    );
    _controller.clear();
  }

  // 4. 이미지 선택 및 업로드 함수 (추가)
  Future<void> _handleImageUpload(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile != null) {
      final auth = context.read<AuthProvider>();
      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://10.0.2'),
        );
        request.headers['Authorization'] = 'Bearer ${auth.token}';
        request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));

        var streamedResponse = await request.send();
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          final String imageUrl = json.decode(response.body)['url'];

          // STOMP로 이미지 메시지 전송
          stompClient.send(
            destination: '/pub/chat/message',
            body: json.encode({
              'chatRoomId': widget.chatRoomId,
              'senderId': auth.userId,
              'message': '[사진]',
              'chatType': 'IMAGE',
              'fileUrl': imageUrl,
            }),
          );
        }
      } catch (e) {
        debugPrint("이미지 업로드 에러: $e");
      }
    }
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
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final bool isMe = msg.senderId == myId;

                // 이미지 타입인 경우 커스텀 위젯 반환
                if (msg.chatType == 'IMAGE' && msg.fileUrl != null) {
                  return ChatImageBubble(
                    imageUrl: msg.fileUrl!,
                    isMe: isMe,
                    time: msg.createdAt.length > 16 ? msg.createdAt.substring(11, 16) : "",
                  );
                }

                // 텍스트 타입인 경우 기존 버블 반환
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
              onImagePick: _handleImageUpload, // 이미지 함수 연결
              onVoiceCall: () {
                // TODO: 보이스톡 화면 이동 로직
                print("보이스톡 호출");
              },
            ),
          ),
        ],
      ),
    );
  }
}


