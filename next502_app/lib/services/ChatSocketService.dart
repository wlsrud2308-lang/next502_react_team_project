import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatSocketService {
  StompClient? stompClient;
  final int roomId;
  // 메시지를 받았을 때 실행할 함수 (UI 업데이트용)
  final Function(Map<String, dynamic>) onMessageReceived;

  ChatSocketService({required this.roomId, required this.onMessageReceived});

  // 1. 웹소켓 연결 시작
  void connect() {
    stompClient = StompClient(
      config: StompConfig(
        // 안드로이드 에뮬레이터 주소 (실제 기기는 PC IP로 변경)
        // 서버에서 .withSockJS()를 썼다면 끝에 /websocket을 붙이는게 안전함
        url: 'ws://10.0.2.2:8080/ws-stomp/websocket',
        onConnect: onConnectCallback,
        onStompError: (frame) => print('STOMP 에러 발생: ${frame.body}'),
        onWebSocketError: (dynamic error) => print('웹소켓 연결 에러: $error'),
        onDisconnect: (frame) => print('연결 종료'),
        heartbeatIncoming: const Duration(seconds: 10),
        heartbeatOutgoing: const Duration(seconds: 10),
      ),
    );
    stompClient?.activate(); // 연결 활성화
  }

  // 2. 연결 성공 시 실행될 콜백
  void onConnectCallback(StompFrame frame) {
    print('실시간 채팅 연결 성공!');

    // 해당 채팅방을 구독(Subscribe)함
    stompClient?.subscribe(
      destination: '/sub/chat/room/$roomId',
      callback: (frame) {
        if (frame.body != null) {
          // 서버에서 온 메시지(JSON)를 맵 형식으로 변환해서 화면에 전달
          final Map<String, dynamic> data = json.decode(frame.body!);
          onMessageReceived(data);
        }
      },
    );
  }

  // 3. 메시지 보내기 (Publish)
  void sendMessage(int userSeq, String content, {String type = 'TEXT', String? fileUrl}) {
    stompClient?.send(
      destination: '/pub/chat/message',
      body: json.encode({
        'chatRoom': {'chatRoomSeq': roomId},
        'sender': {'userSeq': userSeq},
        'content': content,
        'chatType': type,
        'fileUrl': fileUrl,
      }),
    );
  }

  // 4. 연결 끊기
  void disconnect() {
    stompClient?.deactivate();
  }
}
