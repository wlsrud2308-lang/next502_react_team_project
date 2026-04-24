import 'package:flutter/material.dart';
import 'package:next502_app/widgets/warehouse_usage.dart';
import '../../widgets/top_nav_bar.dart';

class ProviderMainScreen extends StatelessWidget {
  const ProviderMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const TopNavBar(),
      body: SingleChildScrollView(
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

                  // === 추가된 사용량 섹션 ===
                  const Text("실시간 창고 사용량",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  const WarehouseUsage(
                    warehouseName: "부산 강서구 신축 창고",
                    usageRate: 0.74,
                    totalSpace: 500,
                    usedSpace: 370,
                  ),
                  // =======================

                  const SizedBox(height: 30),
                  const Text("내 창고 등록 현황",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildStatusCard("부산 강서구 신축 창고", "심사 중", Colors.orange),
                  _buildStatusCard("사하구 감천항 물류센터", "노출 중", Colors.green),

                  const SizedBox(height: 30),
                  const Text("최근 상담 문의",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildInquiryList(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/owner/input'),
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("새 창고 등록", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // ... (기존 _buildWelcomeSection, _buildManagementMenu, _buildMenuCard, _buildStatusCard, _buildInquiryList 메서드들은 동일)

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("임대인님, 반가워요!", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text("오늘도 새로운 매칭을 기다리는\n창고들이 준비되어 있습니다.", style: TextStyle(color: Colors.white70, height: 1.5)),
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
        _buildMenuCard(Icons.warehouse, "내 창고 관리", "2건", Colors.blue),
        _buildMenuCard(Icons.chat_outlined, "상담 내역", "5건", Colors.orange),
        _buildMenuCard(Icons.analytics_outlined, "조회수 통계", "128회", Colors.green),
        _buildMenuCard(Icons.verified_user_outlined, "내 정보/인증", "완료", Colors.teal),
      ],
    );
  }

  Widget _buildMenuCard(IconData icon, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
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
          Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
            child: Text(status, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  Widget _buildInquiryList() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: const Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("강서구 창고 면적 문의"),
            subtitle: Text("방금 전"),
            trailing: Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

