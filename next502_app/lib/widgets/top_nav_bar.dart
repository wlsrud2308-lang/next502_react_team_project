import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:next502_app/providers/auth_provider.dart';
import 'package:next502_app/screens/login_screen.dart';
import 'package:next502_app/screens/chat_room_list_screen.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      // 왼쪽 영역 너비를 넓혀서 아이콘 두 개가 들어갈 공간 확보
      leadingWidth: 100,
      leading: Row(
        children: [
          // 1. 기존 메뉴 아이콘
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          // 2. 채팅 아이콘 (왼쪽 배치)
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return IconButton(
                constraints: const BoxConstraints(), // 간격 조절을 위해 제약 해제
                padding: EdgeInsets.zero,
                icon: Icon(
                  Icons.chat_outlined,
                  color: auth.isLoggedIn ? Colors.deepPurple : Colors.black,
                  size: 22,
                ),
                onPressed: () {
                  if (auth.isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChatRoomListScreen()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("로그인이 필요한 서비스입니다.")),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      title: const Text(
        '창고이음',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          letterSpacing: 2.0,
        ),
      ),
      centerTitle: true,
      actions: [
        // 마이페이지 / 로그인 버튼만 우측에 남김
        Consumer<AuthProvider>(
          builder: (context, auth, child) {
            return IconButton(
              icon: Icon(
                auth.isLoggedIn ? Icons.person : Icons.person_outline,
                color: auth.isLoggedIn ? Colors.deepPurple : Colors.black,
              ),
              onPressed: () {
                if (auth.isLoggedIn) {
                  Navigator.pushNamed(context, '/mypage');
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

