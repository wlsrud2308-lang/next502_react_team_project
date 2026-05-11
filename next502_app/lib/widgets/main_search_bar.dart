import 'package:flutter/material.dart';

class MainSearchBar extends StatelessWidget {
  const MainSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    // StatlessWidget 내부에서 컨트롤러를 선언하면 리렌더링 시 초기화될 수 있으므로 주의가 필요하지만,
    // 현재 구조에서는 입력 후 바로 이동하므로 큰 문제는 없습니다.
    final TextEditingController _controller = TextEditingController();

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
          controller: _controller,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: '지역, 면적, 창고 유형 검색',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
            prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
            suffixIcon: IconButton(
              icon: const Icon(Icons.tune, color: Colors.grey),
              onPressed: () {
                // 필터 버튼 클릭 시 전체 목록을 보여주는 리스트 페이지로 이동
                Navigator.pushNamed(context, '/whList', arguments: "");
              },
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          ),

          // 엔터(검색) 버튼 클릭 시
          onSubmitted: (value) {
            // 키보드 닫기
            FocusScope.of(context).unfocus();

            // [수정된 로직]
            // 값이 비어있어도 return 하지 않고 빈 문자열을 넘겨서
            // 백엔드가 전체 목록을 반환하게 합니다.
            final searchValue = value.trim();

            print("검색어 전송: '$searchValue' (비어있을 시 전체 조회)");

            Navigator.pushNamed(
              context,
              '/whList',
              arguments: searchValue,
            );
          },
        ),
      ),
    );
  }
}