
import 'package:flutter/material.dart';
import 'chat_room_screen.dart';

// 사용자가 아이디와 채팅방 번호를 입력하고 입장하는 초기 화면
class ChatLoginScreen extends StatefulWidget {
  const ChatLoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ChatLoginScreenState();
}

class _ChatLoginScreenState extends State<ChatLoginScreen> {
  // 텍스트 입력 제어를 위한 컨트롤러
  // 초기값으로 사용자명을 'FlutterUser1'를 설정함 (생략 시 빈 텍스트 출력)
  final TextEditingController _userIdController = TextEditingController(text: 'FlutterUser1');
  // 채팅방 이름 설정
  final TextEditingController _roomIdController = TextEditingController();

  // 채팅방 입장 로직
  // 방 번호가 입력되었는지 확인 후, 상세 채팅 화면으로 이동
  void _enterChatRoom() {
    // 입력값 유효성 검사 (Trim을 통해 공백 제거 후 확인)
    if (_roomIdController.text.trim().isEmpty) {
      // 스낵바를 사용하여 메시지 출력, 토스트 메시지를 사용해도 됨
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('방 번호를 입력해주세요')),
      );
      return;
    }

    // MaterialPageRoute를 사용하여 화면 전환 및 데이터 전달
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatRoomScreen(
          userId: _userIdController.text.trim(),
          roomId: _roomIdController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('💬 Flutter 실시간 채팅 테스트')),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 내 ID 입력 필드
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(labelText: '테스트용 내 ID'),
            ),
            const SizedBox(height: 20),
            // 채팅방 번호 입력 필드
            TextField(
              controller: _roomIdController,
              decoration: const InputDecoration(labelText: '채팅방 번호 (예: room_100)'),
            ),
            const SizedBox(height: 40),
            // 입장 버튼
            ElevatedButton(
              onPressed: _enterChatRoom,
              child: const Text('입장하기'),
            ),
          ],
        ),
      ),
    );
  }
}
