import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class VoiceCallScreen extends StatefulWidget {
  final String channelId; // 채팅방 ID 등을 사용
  final String userName;

  const VoiceCallScreen({super.key, required this.channelId, required this.userName});

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  late RtcEngine _engine;
  bool _localUserJoined = false;
  int? _remoteUid;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    // 1. 마이크 권한 요청
    await [Permission.microphone].request();

    // 2. 엔진 생성 (App ID 입력)
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: "67aca30cc8104c4aa334818c6cd581a0",
    ));

    // 3. 이벤트 핸들러 설정
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() => _localUserJoined = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() => _remoteUid = null);
          Navigator.pop(context); // 상대방이 나가면 통화 종료
        },
      ),
    );

    // 4. 오디오 엔진 설정 및 채널 입장
    await _engine.enableAudio();
    await _engine.joinChannel(
      token: '', // 테스트용(No Certificate)일 때는 빈 문자열
      channelId: widget.channelId,
      uid: 0, // 0으로 설정하면 아고라가 자동으로 부여
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C2C2C),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 20),
            Text(widget.userName, style: const TextStyle(color: Colors.white, fontSize: 24)),
            const SizedBox(height: 10),
            Text(
              _remoteUid == null ? "연결 중..." : "통화 중",
              style: const TextStyle(color: Colors.greenAccent),
            ),
            const SizedBox(height: 100),
            IconButton(
              iconSize: 70,
              icon: const Icon(Icons.call_end, color: Colors.red),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
