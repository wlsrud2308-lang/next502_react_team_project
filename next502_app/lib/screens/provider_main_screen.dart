import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/auth_provider.dart';
import '../models/warehouse_model.dart';
import '../models/chat_message_model.dart'; // ChatRoomModel이 정의된 파일 경로 확인
import '../widgets/warehouse_usage.dart';
import '../../widgets/top_nav_bar.dart';
import 'chat_room_list_screen.dart';
import 'chat_screen.dart';

class ProviderMainScreen extends StatefulWidget {
  const ProviderMainScreen({super.key});

  @override
  State<ProviderMainScreen> createState() => _ProviderMainScreenState();
}

class _ProviderMainScreenState extends State<ProviderMainScreen> {
  List<WarehouseModel> _myWarehouses = [];
  List<ChatRoomModel> _recentInquiries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // 1. 대시보드 데이터 로드 (창고 목록 + 채팅 목록)
  Future<void> _loadDashboardData() async {
    final auth = context.read<AuthProvider>();
    final token = auth.token;
    final myId = auth.userId ?? 0;

    try {
      // 내 창고 목록 조회 (API 주소는 백엔드 설계에 맞게 확인 필요)
      final whResponse = await http.get(
        Uri.parse('http://10.0.2.2:8080'),
        headers: {'Authorization': 'Bearer $token'},
      );

      // 전체 채팅방 목록 조회
      final chatResponse = await http.get(
        Uri.parse('http://10.0.2'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (whResponse.statusCode == 200 && chatResponse.statusCode == 200) {
        final List<dynamic> whData = json.decode(utf8.decode(whResponse.bodyBytes));
        final List<dynamic> chatData = json.decode(utf8.decode(chatResponse.bodyBytes));

        setState(() {
          _myWarehouses = whData.map((json) => WarehouseModel.fromJson(json)).toList();
          // 최근 상담 리스트 (최신순 3개)
          _recentInquiries = chatData
              .map((json) => ChatRoomModel.fromJson(json, myId))
              .toList();
          _recentInquiries.sort((a, b) => b.updateDate.compareTo(a.updateDate));
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("대시보드 로드 에러: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 첫 번째 창고 기준 실시간 사용률 계산
    final mainWarehouse = _myWarehouses.isNotEmpty ? _myWarehouses.first : null;
    double usagePercent = 0.0;
    if (mainWarehouse != null && mainWarehouse.totalArea > 0) {
      usagePercent = mainWarehouse.occupiedArea / mainWarehouse.totalArea;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const TopNavBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildManagementMenu(context),
                    const SizedBox(height: 30),

                    // 실시간 사용률 섹션 (실제 데이터 연동)
                    if (mainWarehouse != null) ...[
                      const Text("실시간 창고 사용률",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      WarehouseUsage(
                        warehouseName: mainWarehouse.name,
                        usagePercent: usagePercent,
                      ),
                    ],

                    const SizedBox(height: 30),
                    const Text("내 창고 등록 현황",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    if (_myWarehouses.isEmpty)
                      const Text("등록된 창고가 없습니다.")
                    else
                      ..._myWarehouses.map((wh) => _buildStatusCard(wh.name, "노출 중", Colors.green)),

                    const SizedBox(height: 30),
                    const Text("최근 상담 문의",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    _buildInquiryList(context, _recentInquiries.take(3).toList()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/whInput'),
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("새 창고 등록",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("임대인님, 반가워요!",
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("오늘도 새로운 매칭을 기다리는\n창고들이 준비되어 있습니다.",
              style: TextStyle(color: Colors.white70, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildManagementMenu(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      children: [
        _buildMenuCard(Icons.warehouse, "내 창고 관리", "${_myWarehouses.length}건", Colors.blue, () {}),
        _buildMenuCard(Icons.chat_outlined, "상담 내역", "${_recentInquiries.length}건", Colors.orange, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ChatRoomListScreen()));
        }),
        _buildMenuCard(Icons.analytics_outlined, "조회수 통계", "128회", Colors.green, () {}),
        _buildMenuCard(Icons.verified_user_outlined, "내 정보/인증", "완료", Colors.teal, () {}),
      ],
    );
  }

  Widget _buildMenuCard(IconData icon, String title, String value, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String name, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildInquiryList(BuildContext context, List<ChatRoomModel> rooms) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: rooms.isEmpty
          ? const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text("새로운 문의가 없습니다.")),
      )
          : Column(
        children: rooms.map((room) => ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                chatRoomId: room.chatRoomId,
                warehouseName: room.warehouseName,
              ),
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          leading: CircleAvatar(child: Text(room.otherUserNick[0])),
          title: Text("${room.otherUserNick}님의 문의"),
          subtitle: Text(room.warehouseName, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chevron_right),
        )).toList(),
      ),
    );
  }
}


