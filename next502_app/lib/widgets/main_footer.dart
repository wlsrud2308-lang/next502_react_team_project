import 'package:flutter/material.dart';

class MainFooter extends StatelessWidget {
  const MainFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF1A1A1A), // 이미지와 비슷한 어두운 배경색
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 로고 섹션
          Row(
            children: [
              // 로고 이미지가 있다면 Image.asset 사용
              const Icon(Icons.apps, color: Colors.pink, size: 24),
              const SizedBox(width: 8),
              const Text(
                "부산광역시 창고이음",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 2. 이용약관 및 링크 섹션
          const Wrap(
            spacing: 15,
            children: [
              Text("이용약관", style: TextStyle(color: Colors.white70, fontSize: 11)),
              Text("이메일무단수집거부", style: TextStyle(color: Colors.white70, fontSize: 11)),
              Text("개인정보처리방침", style: TextStyle(color: Colors.pinkAccent, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),

          // 3. 문의처 섹션
          const Text(
            "창고이음 사용 문의 : 051-888-7615",
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
          const SizedBox(height: 4),
          const Text(
            "플랫폼 기술 이용 문의 : 050-7878-8299",
            style: TextStyle(color: Colors.white54, fontSize: 10),
          ),
          const SizedBox(height: 15),

          // 4. 카피라이트 섹션
          const Text(
            "Copyright © 2022 Busan Metropolitan City. all rights reserved.",
            style: TextStyle(color: Colors.white24, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
