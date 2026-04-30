import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // dotenv 패키지
import 'package:flutter_naver_map/flutter_naver_map.dart';
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
import 'package:next502_app/screens/edit_profile_screen.dart';
import 'package:next502_app/screens/favorite_list_screen.dart';

void main() async {
  // 1. 위젯 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 2. .env 파일 로드 (이 단계가 반드시 선행되어야 함)
  try {
    await dotenv.load(fileName: ".env");
    print("✅ .env 로드 성공");
  } catch (e) {
    print("❌ .env 로드 실패: $e");
  }

  await FlutterNaverMap().init(
      clientId: dotenv.env['NAVER_MAP_CLIENT_ID'],
      onAuthFailed: (ex) => switch (ex) {
        NQuotaExceededException(:final message) =>
            print("사용량 초과 (message: $message)"),
        NUnauthorizedClientException() ||
        NClientUnspecifiedException() ||
        NAnotherAuthFailedException() =>
            print("인증 실패: $ex"),
      });

  // 4. 카카오 SDK 초기화
  KakaoSdk.init(
    nativeAppKey: 'f9ff9a37a47bb4441f072e20fef5c75f',
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
      // 시작 페이지를 지도 화면으로 설정하여 연결 확인
      initialRoute: '/whMap',

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
        '/editProfile': (context) => const EditProfileScreen(),
        '/favorites': (context) => const FavoriteListScreen(),

        '/chat': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
          return ChatScreen(
            chatRoomId: args['chatRoomId'] ?? 0,
            warehouseName: args['warehouseName'] ?? '채팅방',
          );
        },

        '/pvMain' : (context) => const ProviderMainScreen(),
        '/whList' : (context) => const WarehouseListScreen(),
      },
    );
  }
}