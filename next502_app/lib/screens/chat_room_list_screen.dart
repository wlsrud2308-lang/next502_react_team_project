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

  @override
  void initState() {
    super.initState();
    _fetchChatRooms();
  }

  // 서버에서 내가 참여한 채팅방 목록 가져오기
  Future<void> _fetchChatRooms() async {
    final auth = context.read<AuthProvider>();
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/chat/rooms'), // 백엔드 엔드포인트 확인 필요
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
              room['lastMessage'] ?? "대화 내용이 없습니다.",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  room['lastChatTime']?.substring(11, 16) ?? "",
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
              ).then((_) => _fetchChatRooms()); // 채팅하고 돌아오면 목록 새로고침
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
