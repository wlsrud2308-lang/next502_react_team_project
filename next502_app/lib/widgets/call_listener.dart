import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/voice_call_screen.dart';

class CallListener extends StatefulWidget {
  final Widget child; // 앱의 메인 화면(BottomNavBar 등)을 여기에 담습니다.

  const CallListener({super.key, required this.child});

  @override
  State<CallListener> createState() => _CallListenerState();
}

class _CallListenerState extends State<CallListener> {
  bool _isCallDialogShowing = false;
  String? _lastVoiceCallId;

  @override
  Widget build(BuildContext context) {
    // 1. 로그인한 내 정보를 가져옵니다.
    final auth = context.watch<AuthProvider>();
    final myId = auth.userId?.toString();

    // 로그인 상태가 아니면 리스너를 돌리지 않고 화면만 보여줍니다.
    if (myId == null) return widget.child;

    return Stack(
      children: [
        widget.child, // 원래 보여줘야 할 화면 (목록, 마이페이지 등)

        // 2. 전역 보이스톡 감시 리스너
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collectionGroup('messages') // 모든 채팅방의 메시지를 통틀어 감시
              .where('chatType', isEqualTo: 'VOICE')
              .orderBy('createdAt', descending: true)
              .limit(1) // 가장 최근의 요청 하나만 확인
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              final doc = snapshot.data!.docs.first;
              final data = doc.data() as Map<String, dynamic>;

              // 수신 조건 체크
              // 1. 내가 보낸 게 아님 2. 새로운 통화 요청임 3. 현재 팝업이 안 떠있음
              if (data['senderId'] != myId &&
                  _lastVoiceCallId != doc.id &&
                  !_isCallDialogShowing) {

                // 시간 체크: 너무 오래된(예: 1분 전) 요청은 무시 (앱 켰을 때 옛날 전화 뜨는 것 방지)
                final Timestamp? createdAt = data['createdAt'] as Timestamp?;
                if (createdAt != null) {
                  final diff = DateTime.now().difference(createdAt.toDate()).inSeconds;
                  if (diff < 60) { // 60초 이내의 따끈따끈한 요청만!

                    _isCallDialogShowing = true;
                    _lastVoiceCallId = doc.id;

                    // 화면 빌드 후에 다이얼로그를 띄워야 에러가 안 납니다.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showIncomingCallDialog(context, data, doc.reference.parent.parent!.id);
                    });
                  }
                }
              }
            }
            return const SizedBox.shrink(); // 화면에는 아무 흔적도 안 남김
          },
        ),
      ],
    );
  }

  // 보이스톡 수신 팝업 UI
  void _showIncomingCallDialog(BuildContext context, Map<String, dynamic> data, String roomId) {
    showDialog(
      context: context,
      barrierDismissible: false, // 버튼을 눌러야만 닫히게 설정
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.phone_in_talk, color: Colors.green),
            SizedBox(width: 10),
            Text("보이스톡 요청"),
          ],
        ),
        content: Text("${data['senderName'] ?? '상대방'}님이 보이스톡을 요청했습니다."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isCallDialogShowing = false);
            },
            child: const Text("거절", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isCallDialogShowing = false);

              // 3. 받기 버튼 클릭 시 어느 화면에서든 통화 화면으로 이동!
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => VoiceCallScreen(
                  channelId: roomId,
                  userName: data['senderName'] ?? "상대방",
                ),
              ));
            },
            child: const Text("받기"),
          ),
        ],
      ),
    );
  }
}
