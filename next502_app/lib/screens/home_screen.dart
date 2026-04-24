import 'package:flutter/material.dart';
import 'package:next502_app/widgets/main_footer.dart';
import 'package:next502_app/widgets/popup_zone.dart';
import '../widgets/top_nav_bar.dart';
import '../widgets/main_search_bar.dart';
import '../widgets/service_grid.dart';
import '../widgets/warehouse_slider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 1. 우리가 정한 상단바 (widgets/top_nav_bar.dart)
      appBar: const TopNavBar(),

      // 왼쪽 메뉴 (임시)
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepPurple),
              child: Text('창고이음 메뉴', style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ListTile(leading: Icon(Icons.notifications), title: Text('공지사항')),
            ListTile(leading: Icon(Icons.settings), title: Text('설정')),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // 2. 배너와 중간에 걸친 서치바 섹션
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                // 히어로 배너
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF673AB7), Color(0xFF9575CD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.only(top: 40, left: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("창고가 필요할 땐", style: TextStyle(color: Colors.white, fontSize: 18)),
                        SizedBox(height: 5),
                        Text("창고이음에서\n쉽게 찾아보세요",
                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
                // 배너에 걸친 서치바 (widgets/main_search_bar.dart)
                const Positioned(
                  bottom: -25,
                  left: 20,
                  right: 20,
                  child: MainSearchBar(),
                ),
              ],
            ),

            const SizedBox(height: 40), // 서치바 삐져나온 만큼 여백

            // 3. 빠른 서비스 아이콘 그리드 (widgets/service_grid.dart)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: ServiceGrid(),
            ),

            const Divider(thickness: 8, color: Color(0xFFF5F5F5)), // 구분선

            // 4. 하단 창고 슬라이더 (widgets/warehouse_slider.dart)
            const WarehouseSlider(),

            const SizedBox(height: 30), // 하단 여유 공간
            const PopupZone(),       // 새로 추가한 팝업 존
            const SizedBox(height: 30),
            const MainFooter(),
          ],
        ),
      ),
    );
  }
}