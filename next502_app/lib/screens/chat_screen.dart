import 'dart:convert'; // 👈 json.decode 사용을 위해 추가
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:next502_app/widgets/messagelist.dart';
import 'package:provider/provider.dart';
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
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 👈 StreamBuilder 내부에서 다이얼로그 무한 루프 팝업이 도는 것을 방지하기 위한 변수
  bool _isCallDialogShowing = false;
  String? _lastVoiceCallId;

  @override
  void initState() {
    super.initState();
  }

  // 1. [실시간 메시지 전송 로직]
  void _sendMessage() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    final auth = context.read<AuthProvider>();
    final String myId = auth.userId.toString();

    try {
      await _firestore
          .collection('chatRooms')
          .doc(widget.chatRoomId.toString())
          .collection('messages')
          .add({
        'senderId': myId,
        'content': text,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'chatType': 'TEXT',
      });
    } catch (e) {
      debugPrint("❌ 파이어베이스 메시지 전송 에러: $e");
    }
  }

  // 2. [이미지 업로드 로직]
  Future<void> _handleImageUpload(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile == null) return;

    final auth = context.read<AuthProvider>();
    final String myId = auth.userId.toString();

    try {
      var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2'));
      request.headers['Authorization'] = 'Bearer ${auth.token}';
      request.files.add(await http.MultipartFile.fromPath('file', pickedFile.path));
      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        final String imageUrl = json.decode(response.body)['url'];

        await _firestore
            .collection('chatRooms')
            .doc(widget.chatRoomId.toString())
            .collection('messages')
            .add({
          'senderId': myId,
          'content': '[사진]',
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
          'chatType': 'IMAGE',
          'fileUrl': imageUrl,
        });
      }
    } catch (e) {
      debugPrint("❌ 이미지 업로드 중 에러 발생: $e");
    }
  }

  // 3. [보이스톡 실행 로직]
  void _initiateVoiceCall() async {
    final auth = context.read<AuthProvider>();
    final String myId = auth.userId.toString();

    try {
      await _firestore
          .collection('chatRooms')
          .doc(widget.chatRoomId.toString())
          .collection('messages')
          .add({
        'senderId': myId,
        'content': '보이스톡 요청',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'chatType': 'VOICE',
        'senderName': auth.userId.toString(),
      });

      _goToCall();
    } catch (e) {
      debugPrint("❌ 보이스톡 신호 전송 에러: $e");
    }
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

  // 보이스톡 수신 팝업
  void _showCallAcceptDialog(String? senderName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("보이스톡 요청"),
        content: Text("${senderName ?? '상대방'}님이 보이스톡을 요청했습니다."),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                _isCallDialogShowing = false; // 플래그 해제
              },
              child: const Text("거절", style: TextStyle(color: Colors.red))
          ),
          ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _isCallDialogShowing = false; // 플래그 해제
                _goToCall();
              },
              child: const Text("받기")
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final myId = auth.userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.warehouseName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // 4. [메시지 리스트 영역]
          Expanded(
            child: myId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chatRooms')
                  .doc(widget.chatRoomId.toString())
                  .collection('messages')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('메시지가 없습니다.'));
                }

                // ⚠️ Firestore 전용 생성자(fromFirestore)를 사용하여 데이터를 깔끔하게 파싱합니다.
                final List<ChatMessageModel> messages = snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return ChatMessageModel.fromFirestore(doc.id, data);
                }).toList();

                // ⚠️ 5. [실시간 보이스톡 팝업 가로채기 중복 방지 로직]
                final firstDoc = snapshot.data!.docs.first;
                final firstData = firstDoc.data() as Map<String, dynamic>;

                if (messages.isNotEmpty &&
                    messages.first.chatType == 'VOICE' &&
                    messages.first.senderId != myId.toString() &&
                    _lastVoiceCallId != firstDoc.id && // 새로운 통화 고유 ID 일때만 실행
                    !_isCallDialogShowing) { // 다이얼로그가 안 떠있을 때만 실행

                  _isCallDialogShowing = true;
                  _lastVoiceCallId = firstDoc.id;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showCallAcceptDialog(firstData['senderName']);
                  });
                }

                // 6. [기존 위젯 재사용] 데이터 매핑
                return MessageList(messages: messages, myId: myId);
              },
            ),
          ),

          // 하단 입력창 (잘린 코드 완벽 결합)
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





