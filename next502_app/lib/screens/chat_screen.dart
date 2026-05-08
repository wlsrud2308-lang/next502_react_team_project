import 'dart:convert';
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

  // 2. [이미지 업로드 및 전송 로직]
  Future<void> _handleImageUpload(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 70);
    if (pickedFile == null) return;

    final auth = context.read<AuthProvider>();
    final String myId = auth.userId.toString();

    try {
      var request = http.MultipartRequest('POST', Uri.parse('http://10.0.2.2:8080/chat/upload'));
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

  // 3. [보이스톡 시작 로직] (내가 전화를 거는 상황)
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
        'senderName': auth.userId.toString(), // 수신자 화면에 뜰 이름
      });

      _goToCall(widget.warehouseName); // 내가 걸었을 때는 창고 이름으로 표시
    } catch (e) {
      debugPrint("❌ 보이스톡 신호 전송 에러: $e");
    }
  }

  // 4. [통화 화면 이동 공통 함수]
  void _goToCall(String displayName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VoiceCallScreen(
          channelId: widget.chatRoomId.toString(),
          userName: displayName,
        ),
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
          // 5. [메시지 리스트 영역]
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

                final docs = snapshot.data!.docs;

                // ✅ [실시간 감지 로직]
                // 렌더링 중에 루프를 돌며 보이스톡 신호와 읽음 처리를 수행합니다.
                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final String senderId = data['senderId'].toString();
                  final bool isRead = data['isRead'] ?? false;
                  final String chatType = data['chatType'] ?? 'TEXT';

                  // 내가 보낸 게 아닌 메시지들 처리
                  if (senderId != myId.toString()) {

                    // 1. [보이스톡 신호 감지] 상대방이 건 전화라면 화면 전환
                    if (chatType == 'VOICE' && !isRead) {
                      // 중복 방지를 위해 즉시 읽음 처리 후 이동
                      doc.reference.update({'isRead': true});

                      // 빌드 도중 화면 이동을 위해 지연 실행
                      Future.delayed(Duration.zero, () {
                        _goToCall(data['senderName'] ?? "상대방");
                      });
                    }

                    // 2. [일반 읽음 처리]
                    if (!isRead) {
                      doc.reference.update({'isRead': true});
                    }
                  }
                }

                final List<ChatMessageModel> messages = docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return ChatMessageModel.fromFirestore(doc.id, data);
                }).toList();

                return MessageList(messages: messages, myId: myId);
              },
            ),
          ),

          // 6. [하단 입력창 영역]
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





