import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'chat_screen.dart';

class ChatRoomListScreen extends StatefulWidget {
  const ChatRoomListScreen({super.key});

  @override
  State<ChatRoomListScreen> createState() => _ChatRoomListScreenState();
}

class _ChatRoomListScreenState extends State<ChatRoomListScreen> {
  List<dynamic> _chatRooms = [];
  bool _isLoading = true;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchChatRooms();
  }

  Future<void> _fetchChatRooms() async {
    final auth = context.read<AuthProvider>();
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/chat/rooms'),
        headers: {'Authorization': 'Bearer ${auth.token}'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _chatRooms = json.decode(utf8.decode(response.bodyBytes));
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("채팅방 목록 로드 에러: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("채팅 상담 내역", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chatRooms.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
        itemCount: _chatRooms.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
        itemBuilder: (context, index) {
          final room = _chatRooms[index];
          final String roomIdStr = room['chatRoomId'].toString();

          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('chatRooms')
                .doc(roomIdStr)
                .collection('messages')
                .orderBy('createdAt', descending: true)
                .limit(1)
                .snapshots(),
            builder: (context, snapshot) {
              String lastMessage = room['lastMessage'] ?? "대화 내용이 없습니다.";
              String lastChatTime = room['lastChatTime']?.substring(11, 16) ?? "";

              if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
                final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

                // ⚠️ 1. 팀원분의 파이어베이스 저장 규격인 'content'로 텍스트를 꺼내옵니다.
                lastMessage = data['content'] ?? lastMessage;

                // ⚠️ 2. 마지막 전송 파일이 사진 타입이라면 리스트 가독성을 위해 치환합니다.
                if (data['chatType'] == 'IMAGE') {
                  lastMessage = "[사진]";
                }

                final Timestamp? timestamp = data['createdAt'] as Timestamp?;
                if (timestamp != null) {
                  final date = timestamp.toDate();
                  lastChatTime = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
                }
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade100,
                  child: const Icon(Icons.warehouse, color: Colors.deepPurple),
                ),
                title: Text(
                  room['warehouseName'] ?? "창고 문의",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  lastMessage, // 👈 파이어베이스 실시간 데이터가 안전하게 반영됩니다.
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      lastChatTime,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 5),
                    if (room['unreadCount'] != null && room['unreadCount'] > 0)
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text(
                          "${room['unreadCount']}",
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        chatRoomId: room['chatRoomId'],
                        warehouseName: room['warehouseName'] ?? "채팅방",
                      ),
                    ),
                  ).then((_) => _fetchChatRooms());
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          const Text("참여 중인 채팅방이 없습니다.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

