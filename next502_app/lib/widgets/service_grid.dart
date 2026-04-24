import 'package:flutter/material.dart';

class ServiceGrid extends StatelessWidget {
  const ServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    // 2열 2행 혹은 3열로 배치하기 위해 GridView를 사용합니다.
    return GridView.count(
      shrinkWrap: true, // ScrollView 안에 있으므로 true로 설정
      physics: const NeverScrollableScrollPhysics(), // 부모 스크롤 사용
      crossAxisCount: 4, // 한 줄에 아이콘 4개 배치
      mainAxisSpacing: 20, // 위아래 간격
      crossAxisSpacing: 10, // 좌우 간격
      children: [
        _buildMenuIcon(context, Icons.near_me, '내 주변', '/map', Colors.blue),
        _buildMenuIcon(context, Icons.map, '창고지도', '/map', Colors.green),      // 지도 연결
        _buildMenuIcon(context, Icons.favorite, '관심창고', '/wish', Colors.red),
        _buildMenuIcon(context, Icons.help_outline, 'FAQ', '/faq', Colors.teal),
      ],
    );
  }

  // 아이콘과 글자를 합친 개별 버튼 위젯
  Widget _buildMenuIcon(BuildContext context, IconData icon, String label, String route, Color color) {
    return GestureDetector(
      onTap: () {
        // 클릭 시 해당 주소로 이동 (App.dart에 등록된 route 기준)
        Navigator.pushNamed(context, route);
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1), // 연한 배경색
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
