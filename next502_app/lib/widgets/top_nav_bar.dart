import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:next502_app/providers/auth_provider.dart';
import 'package:next502_app/screens/login_screen.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: Colors.black),
        onPressed: () => Scaffold.of(context).openDrawer(),
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
        // 상태 감시
        Consumer<AuthProvider>(
          builder: (context, auth, child) {
            if (auth.isLoggedIn) {
              // [로그인 된 상태]

              return IconButton(
                icon: const Icon(Icons.person, color: Colors.deepPurple), // 보라색으로 강조
                onPressed: () {
                  // 아직 마이페이지가 없다면 임시로 스낵바
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("내 정보(마이페이지)로 이동합니다.")),
                  );

                  Navigator.pushNamed(context, '/mypage');
                },
              );
            } else {
              // [로그인 안 된 상태]
              return IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.black),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
              );
            }
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}