import 'package:flutter/material.dart';
import 'package:next502_app/screens/chat_screen.dart';
import 'package:next502_app/screens/faq_screen.dart';
import 'package:next502_app/screens/find_id_screen.dart';
import 'package:next502_app/screens/find_pw_screen.dart';
import 'package:next502_app/screens/ocr_screen.dart';
import 'package:next502_app/screens/provider_main_screen.dart';
import 'package:next502_app/screens/signup_screen.dart';
import 'package:next502_app/screens/warehouse_info_screen.dart';
import 'package:next502_app/screens/warehouse_input_screen.dart';
import 'package:next502_app/screens/warehouse_list_screen.dart';
import 'package:next502_app/screens/warehouse_map_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '창고이음',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // 2. 시작 페이지를 로그인 화면으로 변경
      initialRoute: '/pvMain',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/findId': (context) => const FindIdScreen(),
        '/findPw': (context) => const FindPwScreen(),
        '/whInput': (context) => const WarehouseInputScreen(),
        '/ocr_verify': (context) => const OcrScreen(),
        '/whInfo': (context) => const WarehouseInfoScreen(),
        '/whMap': (context) => const WarehouseMapScreen(),
        '/faq' : (context) => const FaqScreen(),
        '/chat' : (context) => const ChatScreen(),
        '/pvMain' : (context) => const ProviderMainScreen(),
        '/whList' : (context) => const WarehouseListScreen(),

      },
    );
  }
}

