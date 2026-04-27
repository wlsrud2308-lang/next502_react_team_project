import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthProvider에서 로그인 상태 확인
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("마이페이지", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. 프로필
            _buildProfileHeader(context),

            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

            // 2. 관심 창고
            _buildMenuSection(
              title: "나의 활동",
              items: [
                _buildMenuItem(Icons.favorite_border, "관심 창고 목록", () {
                  // 찜 목록 이동 로직
                }),
                _buildMenuItem(Icons.chat_bubble_outline, "채팅 문의 내역", () {
                  // 채팅 목록 이동 로직
                }),
              ],
            ),

            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

            // 3. 설정 및 기타
            _buildMenuSection(
              title: "설정",
              items: [
                _buildMenuItem(Icons.notifications_none, "알림 설정", () {}),
                _buildMenuItem(Icons.help_outline, "고객센터", () {}),
                _buildMenuItem(Icons.logout, "로그아웃", () {
                  _showLogoutDialog(context, authProvider);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 프로필 헤더 위젯
  Widget _buildProfileHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Color(0xFFEDE7F6),
            child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("사용자님, 반갑습니다!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                GestureDetector(
                  onTap: () {
                    // 정보 수정 페이지 이동
                  },
                  child: const Text("회원 정보 수정 >",
                      style: TextStyle(color: Colors.grey, fontSize: 14)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 메뉴 섹션 틀
  Widget _buildMenuSection({required String title, required List<Widget> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
        ),
        ...items,
      ],
    );
  }

  // 개별 메뉴 아이템
  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  // 로그아웃 확인창
  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("로그아웃"),
        content: const Text("정말 로그아웃 하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
          TextButton(
              onPressed: () {
                auth.logout();
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("확인", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}