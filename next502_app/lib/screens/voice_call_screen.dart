import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/agora_config.dart';

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
  bool _isSpeakerPhone = true;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    // 1. 마이크 권한 확인 및 요청
    await [Permission.microphone].request();

    // 2. 아고라 엔진 초기화 (App ID 입력)
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: AgoraConfig.appId,
    ));

    // 3. 이벤트 핸들러 등록
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("✅ 아고라 채널 입장 성공 (방 ID: ${widget.channelId})");
          if (mounted) setState(() => _localUserJoined = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("👤 상대방 입장 완료 (UID: $remoteUid)");
          if (mounted) setState(() => _remoteUid = remoteUid);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          debugPrint("👋 상대방이 나갔습니다.");
          if (mounted) {
            setState(() => _remoteUid = null);
            Navigator.pop(context); // 상대방이 나가면 통화 자동 종료
          }
        },
        onError: (ErrorCodeType err, String msg) {
          debugPrint("❌ 아고라 에러 발생: $msg");
        },
      ),
    );

    // 4. 오디오 설정
    await _engine.enableAudio();
    await _engine.setEnableSpeakerphone(_isSpeakerPhone); // 기본 스피커폰 모드

    try {
      // 에뮬레이터에서는 여기서 -3 에러가 나며 멈출 수 있습니다.
      await _engine.setEnableSpeakerphone(_isSpeakerPhone);
    } catch (e) {
      debugPrint("⚠️ 스피커폰 설정 지원되지 않음 (무시하고 진행): $e");
    }
    
    // 5. 채널 입장 (인증서 미사용 모드이므로 토큰은 "" 빈값 전달)
    await _engine.joinChannel(
      token: "", // 👈 아고라 콘솔에서 Certificate가 없으므로 빈 문자열 사용
      channelId: widget.channelId,
      uid: 0, // 0을 넣으면 아고라가 자동으로 유효한 UID 할당
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  // 마이크 음소거 제어
  void _onToggleMute() {
    setState(() => _isMuted = !_isMuted);
    _engine.muteLocalAudioStream(_isMuted);
  }

  // 스피커폰 전환 제어
  void _onToggleSpeaker() {
    setState(() => _isSpeakerPhone = !_isSpeakerPhone);
    _engine.setEnableSpeakerphone(_isSpeakerPhone);
  }

  @override
  void dispose() {
    // 리소스 해제 필수
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // 어두운 테마
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 상단 정보 영역
            Padding(
              padding: const EdgeInsets.only(top: 80),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.person, size: 65, color: Colors.white),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    widget.userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _remoteUid == null ? "연결 대기 중..." : "보이스톡 통화 중",
                    style: TextStyle(
                      color: _remoteUid == null ? Colors.grey : Colors.greenAccent,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            // 하단 제어 버튼 영역
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 음소거
                  _buildControlButton(
                    icon: _isMuted ? Icons.mic_off : Icons.mic,
                    color: _isMuted ? Colors.red : Colors.white24,
                    onPressed: _onToggleMute,
                  ),
                  // 통화 종료
                  _buildControlButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    iconSize: 35,
                    onPressed: () => Navigator.pop(context),
                  ),
                  // 스피커폰
                  _buildControlButton(
                    icon: _isSpeakerPhone ? Icons.volume_up : Icons.volume_down,
                    color: _isSpeakerPhone ? Colors.blueAccent : Colors.white24,
                    onPressed: _onToggleSpeaker,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    double iconSize = 28,
    required VoidCallback onPressed,
  }) {
    return RawMaterialButton(
      onPressed: onPressed,
      shape: const CircleBorder(),
      fillColor: color,
      padding: const EdgeInsets.all(18),
      elevation: 2.0,
      child: Icon(icon, color: Colors.white, size: iconSize),
    );
  }
}
