import 'dart:async'; // 1. 타이머를 위해 반드시 추가
import 'package:flutter/material.dart';

class PopupZone extends StatefulWidget {
  const PopupZone({super.key});

  @override
  State<PopupZone> createState() => _PopupZoneState();
}

class _PopupZoneState extends State<PopupZone> {
  final PageController _pageController = PageController();
  Timer? _timer; // 2. 타이머 변수 선언
  int _currentPage = 0;

  final List<Map<String, dynamic>> _banners = [
    {"title": "효과적인\n물류시스템", "color": const Color(0xFF6A249C)},
    {"title": "스마트한\n창고 관리", "color": const Color(0xFF4A148C)},
  ];

  @override
  void initState() {
    super.initState();
    // 3. 앱이 켜지자마자 타이머 시작 (3초마다 실행)
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0; // 마지막 페이지면 첫 번째로
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    // 4. 화면이 닫힐 때 타이머를 반드시 꺼야 메모리 누수가 없습니다.
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // 상단 컨트롤러 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("POPUPZONE",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 12)),
              Row(
                children: [
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.chevron_left, size: 20, color: Colors.grey),
                    onPressed: () {
                      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                    },
                  ),
                  const Icon(Icons.pause, size: 12, color: Colors.grey),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                    onPressed: () {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
                    },
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 5),

          // 콘텐츠 영역
          SizedBox(
            height: 140,
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _banners.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index; // 사용자가 직접 넘겨도 페이지 번호 업데이트
                        });
                      },
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.all(15),
                          color: _banners[index]['color'],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _banners[index]['title'],
                                textAlign: TextAlign.right,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildSmallCard(const Color(0xFFC86096), "이용방법", Icons.settings_suggest),
                      const SizedBox(height: 10),
                      _buildSmallCard(const Color(0xFF5A75B8), "자주 묻는 질문", Icons.chat_bubble_outline),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCard(Color color, String title, IconData icon) {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}




