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

  // 🌟 중복 보이스톡 화면 이동을 원천 차단하는 상태 제어 플래그 추가
  bool _isCallNavigating = false;

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
        'message': text, // 웹 대시보드 호환용
        'createdAt': FieldValue.serverTimestamp(), // 서버 정렬용
        'createDate': DateTime.now().toIso8601String(), // 👈 웹 및 앱 시간 텍스트 출력용 표준 키 동시 적재
        'isRead': false,
        'isReadYn': 'N',
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
          'message': '[사진]',
          'createdAt': FieldValue.serverTimestamp(),
          'createDate': DateTime.now().toIso8601String(), // 👈 이미지 전송 시에도 표준 시간 키 동시 적재
          'isRead': false,
          'isReadYn': 'N',
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
        'isReadYn': 'N', // 👈 React 크로스 호환용 필드 통합
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

  // 🌟 5. [비즈니스 사이드 이펙트 제어 분리] 빌드가 끝난 후 안전하게 Firestore 업데이트 수행
  void _handleSideEffects(List<QueryDocumentSnapshot> docs, String myId) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      for (var doc in docs) {
        final data = doc.data() as Map<String, dynamic>;
        final String senderId = data['senderId'].toString();
        final String chatType = data['chatType'] ?? 'TEXT';

        // 크로스 플랫폼(웹/앱)이 저장하는 모든 형태의 읽음 유무 데이터를 유연하게 교차 검증
        final bool isAlreadyRead = (data['isRead'] == true) || (data['isReadYn'] == 'Y');

        // 내가 보낸 게 아닌 상대방이 보낸 메시지들만 가공 대상 적용
        if (senderId != myId) {

          // 1. [보이스톡 신호 감지] 아직 안 읽은 통화 요청이며, 중복 이동 중이 아닐 때
          if (chatType == 'VOICE' && !isAlreadyRead && !_isCallNavigating) {
            _isCallNavigating = true; // 플래그 락(Lock) 세팅

            // 데이터 무결성을 위해 양쪽 웹/앱 필드를 동시에 업데이트
            await doc.reference.update({
              'isRead': true,
              'isReadYn': 'Y',
            });

            _goToCall(data['senderName'] ?? "상대방");
            _isCallNavigating = false; // 플래그 언락(Unlock)
            break; // 화면 이탈이 일어나므로 트래픽 루프 즉시 정지
          }

          // 2. [일반 읽음 처리] 정말로 읽지 않은 새 메시지가 식별되었을 때만 단 한 번 업데이트 요청
          if (!isAlreadyRead) {
            doc.reference.update({
              'isRead': true,
              'isReadYn': 'Y', // 👈 웹 플로팅 바 컴포넌트와의 읽음 연동 완전 동기화 핵심
            });
          }
        }
      }
    });
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
          // 5. [메시지 리스트 영역] -> 화면 렌더링에만 집중하도록 극도로 경량화
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

                // 👈 [수정 적용]: 프레임워크 렌더링 파이프라인 우회 콜백 함수 호출 처리 완료
                _handleSideEffects(docs, myId.toString());

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




