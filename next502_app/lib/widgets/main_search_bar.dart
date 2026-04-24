import 'package:flutter/material.dart';

class MainSearchBar extends StatelessWidget {
  const MainSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: '지역, 면적, 창고 유형 검색',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
            prefixIcon: const Icon(Icons.search, color: Colors.deepPurple), // 돋보기 아이콘
            suffixIcon: const Icon(Icons.tune, color: Colors.grey), // 필터 아이콘 (선택사항)
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
          onSubmitted: (value) {
            print("검색어: $value");
          },
        ),
      ),
    );
  }
}