import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class VoiceCallScreen extends StatefulWidget {
  final String channelId; // 채팅방 ID
  final String userName;  // 상대방 이름

  const VoiceCallScreen({
    super.key,
    required this.channelId,
    required this.userName
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  late RtcEngine _engine;
  bool _localUserJoined = false;
  int? _remoteUid;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    final auth = context.read<AuthProvider>();

    // 1. 마이크 권한 확인
    await [Permission.microphone].request();

    // 2. 백엔드에서 보안 토큰 가져오기 (토큰 생성기를 구현한 경우)
    // 만약 No Certificate 모드라면 이 부분은 생략하고 token: "" 로 접속 가능
    String serverToken = "";
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2{widget.channelId}/token'),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );
      if (response.statusCode == 200) {
        serverToken = json.decode(response.body)['token'];
      }
    } catch (e) {
      debugPrint("토큰 가져오기 실패: $e");
    }

    // 3. 엔진 초기화 (본인의 아고라 App ID 입력)
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: "여기에_아고라_APP_ID_복사",
    ));

    // 4. 이벤트 핸들러 등록
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

    // 5. 오디오 설정 및 채널 입장
    await _engine.enableAudio();
    await _engine.joinChannel(
      token: serverToken,
      channelId: widget.channelId,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  // 마이크 음소거 기능
  void _onToggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    _engine.muteLocalAudioStream(_isMuted);
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
      backgroundColor: const Color(0xFF1A1A1A), // 다크 모드 배경
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 상단: 정보 표시
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.userName,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _remoteUid == null ? "연결 중..." : "통화 중",
                    style: TextStyle(color: _remoteUid == null ? Colors.grey : Colors.greenAccent, fontSize: 16),
                  ),
                ],
              ),
            ),

            // 하단: 제어 버튼
            Padding(
              padding: const EdgeInsets.only(bottom: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 음소거 버튼
                  _buildControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    color: _isMuted ? Colors.red : Colors.white24,
                    onPressed: _onToggleMute,
                  ),
                  // 종료 버튼
                  _buildControlButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    iconColor: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                  // 스피커 버튼 (기본은 스피커폰 모드)
                  _buildControlButton(
                    icon: Icons.volume_up,
                    color: Colors.white24,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({required IconData icon, required Color color, Color iconColor = Colors.white, required VoidCallback onPressed}) {
    return RawMaterialButton(
      onPressed: onPressed,
      shape: const CircleBorder(),
      fillColor: color,
      padding: const EdgeInsets.all(15),
      child: Icon(icon, color: iconColor, size: 30),
    );
  }
}

