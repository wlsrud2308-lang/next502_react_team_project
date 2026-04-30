import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:next502_app/widgets/messagelist.dart';
import 'package:provider/provider.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:http/http.dart' as http;

import '../providers/auth_provider.dart';
import '../widgets/chat_input.dart';
import '../models/chat_message_model.dart';
import 'voice_call_screen.dart';

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
  final ImagePicker _picker = ImagePicker();
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
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/chat/room/${widget.chatRoomId}/messages'),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> content = data['content'] ?? [];
        setState(() {
          _messages.clear();
          _messages.addAll(content.map((e) => ChatMessageModel.fromJson(e)).toList());
        });

        _markAsRead();
      }
    } catch (e) {
      debugPrint("과거 내역 로드 에러: $e");
    }
  }

  void _updateReadStatus() {
    setState(() {
      for (var i = 0; i < _messages.length; i++) {
        if (_messages[i].isReadYn == 'N') {
          _messages[i] = _messages[i].copyWith(isReadYn: 'Y');
        }
      }
    });
  }
  // 2. 웹소켓 연결
  void _connect() {
    stompClient = StompClient(
      config: StompConfig(
        url: 'ws://10.0.2.2:8080/ws-stomp',
        onConnect: (frame) {
          debugPrint('연결 성공!');
          stompClient.subscribe(
            destination: '/sub/chat/room/${widget.chatRoomId}',
            callback: (frame) {
              if (frame.body != null) {
                final data = json.decode(frame.body!);
                final auth = context.read<AuthProvider>();

                // 1. 실시간 보이스톡 팝업 처리
                if (data['chatType'] == 'VOICE' && data['senderId'].toString() != auth.userId.toString()) {
                  _showCallAcceptDialog(data['senderName']);
                }

                // 2. 실시간 읽음 상태 업데이트 신호 처리 (만약 전용 신호를 보낸다면)
                if (data['chatType'] == 'READ') {
                  _updateReadStatus();
                  return;
                }

                // 3. 메시지 리스트에 추가 (실시간 반영)
                setState(() {
                  final newMessage = ChatMessageModel.fromJson(data);
                  _messages.insert(0, newMessage);
                });

                // 4. 내가 메시지를 받았으니 서버에 읽었다고 알림 (Patch API 호출)
                _markAsRead();
              }
            },
          );
        },
        onWebSocketError: (e) => debugPrint('웹소켓 에러: $e'),
        onStompError: (d) => debugPrint('스톰프 에러: $d'),
        onDisconnect: (f) => debugPrint('연결 끊김'),
      ),
    );
    stompClient.activate();
  }


// 읽음 처리 API 호출 (백엔드 컨트롤러 4번 엔드포인트와 연결)
  Future<void> _markAsRead() async {
    final auth = context.read<AuthProvider>();
    await http.patch(
      Uri.parse('http://10.0.2.2:8080/chat/room/${widget.chatRoomId}/read'),
      headers: {'Authorization': 'Bearer ${auth.token}'},
    );
  }

  // 3. 메시지 전송
  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final auth = context.read<AuthProvider>();
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

  // 4. 이미지 업로드
  Future<void> _handleImageUpload(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile == null) return;

    final auth = context.read<AuthProvider>();
    try {
      var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:8080/chat/upload'));
      request.headers['Authorization'] = 'Bearer ${auth.token}';
      request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));
      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        final String imageUrl = json.decode(response.body)['url'];
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
    } catch (e, stacktrace) {
      debugPrint("❌ 이미지 업로드 중 진짜 에러 발생: $e");
      debugPrint("❌ 상세 스택트레이스: $stacktrace");
    }
  }

  // 5. 보이스톡 실행 로직
  void _initiateVoiceCall() {
    final auth = context.read<AuthProvider>();
    stompClient.send(
      destination: '/pub/chat/message',
      body: json.encode({
        'chatRoomId': widget.chatRoomId,
        'senderId': auth.userId,
        'senderName': auth.userId.toString(),
        'message': '보이스톡 요청',
        'chatType': 'VOICE',
      }),
    );
    _goToCall();
  }

  void _goToCall() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoiceCallScreen(
          channelId: widget.chatRoomId.toString(),
          userName: widget.warehouseName,
        ),
      ),
    );
  }

  void _showCallAcceptDialog(String? senderName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("보이스톡 요청"),
        content: Text("${senderName ?? '상대방'}님이 보이스톡을 요청했습니다."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("거절", style: TextStyle(color: Colors.red))),
          ElevatedButton(onPressed: () { Navigator.pop(context); _goToCall(); }, child: const Text("받기")),
        ],
      ),
    );
  }

  @override
  void dispose() {
    stompClient.deactivate();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final myId = auth.userId;

    // 디버깅용: ID가 로드되는지 확인
    debugPrint("ChatScreen build - 내 ID: $myId");

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.warehouseName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // 1. 메시지 리스트 영역 (로딩 상태 처리)
          Expanded(
            child: myId == null
                ? const Center(child: CircularProgressIndicator()) // ID 로딩 중
                : MessageList(messages: _messages, myId: myId),     // ID 로드 완료 시
          ),

          // 2. 채팅 입력창 영역 (키보드 대응 포함)
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: ChatInput(
              controller: _controller,
              onSend: _sendMessage,
              onImagePick: _handleImageUpload,
              onVoiceCall: _initiateVoiceCall,
            ),
          ),
        ],
      ),
    );
  }
}



