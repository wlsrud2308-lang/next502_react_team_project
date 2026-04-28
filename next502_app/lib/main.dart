import 'package:flutter/material.dart';
import 'package:next502_app/providers/auth_provider.dart';
import 'package:next502_app/providers/warehouse_provider.dart';
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
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'package:next502_app/screens/my_page_screen.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: 'f9ff9a37a47bb4441f072e20fef5c75f', // 카카오 네이티브 앱 키 등록
  );
  print('내 카카오 해시키: ${await KakaoSdk.origin}');
  runApp(
      MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AuthProvider()),
            ChangeNotifierProvider(create: (_) => WarehouseProvider()),
          ],
        child: const MyApp(),
      ),
  );
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
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/findId': (context) => const FindIdScreen(),
        '/findPw': (context) => const FindPwScreen(),
        '/mypage': (context) => const MyPageScreen(),
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

