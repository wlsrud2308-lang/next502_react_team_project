import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/api_client.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = true; // 데이터를 불러오는 중인지 확인하는 변수
  Map<String, dynamic>? _memberInfo; // 백엔드에서 받아온 내 정보를 담을 바구니

  @override
  void initState() {
    super.initState();
    _fetchMyInfo();
  }

  // --- 내 정보 불러오는 함수 ---
  Future<void> _fetchMyInfo() async {
    try {
      final response = await _apiClient.getMyInfo();
      if (response.statusCode == 200) {
        setState(() {
          _memberInfo = response.data; // 바구니에 데이터 담기
          _isLoading = false;
        });
      }
    } catch (e) {
      print("내 정보 불러오기 실패: $e");
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("정보를 불러오는데 실패했습니다. 다시 로그인해주세요.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

      // isLoading이 true면 로딩 뺑뺑이
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.deepPurple))
          : SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context), // 프로필 헤더

            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

            _buildMenuSection(
              title: "나의 활동",
              items: [
                _buildMenuItem(Icons.favorite_border, "관심 창고 목록", () {}),
                _buildMenuItem(Icons.chat_bubble_outline, "채팅 문의 내역", () {}),
              ],
            ),

            const Divider(thickness: 8, color: Color(0xFFF5F5F5)),

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

    String userName = _memberInfo?['name'] ?? '사용자';
    String userRole = _memberInfo?['role'] ?? 'ROLE_MEMBER';
    String? businessName = _memberInfo?['businessName'];

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
                Text("$userName님, 반갑습니다!",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),


                if (userRole == 'ROLE_PROVIDER' && businessName != null) ...[
                  Text("🏢 $businessName",
                      style: TextStyle(color: Colors.deepPurple.shade700, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                ],

                GestureDetector(
                  onTap: () {
                    // TODO: 회원 정보 수정 페이지 이동
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

  Widget _buildMenuItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("로그아웃"),
        content: const Text("정말 로그아웃 하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("취소")),
          TextButton(
              onPressed: () async {

                auth.logout();
                Navigator.pop(context); // 다이얼로그 닫기
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false); // 홈으로 이동
              },
              child: const Text("확정", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }
}