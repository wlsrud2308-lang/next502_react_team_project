import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:next502_app/providers/auth_provider.dart';
import 'package:next502_app/services/api_client.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  bool _isAutoLogin = false;

  final ApiClient _apiClient = ApiClient();

  // 1. 일반 로그인 처리
  Future<void> _handleLogin() async {
    try {
      final response = await _apiClient.login(_idController.text, _pwController.text);

      if (response.statusCode == 200) {
        final String accessToken = response.data['accessToken'];
        final String refreshToken = response.data['refreshToken'] ?? "";
        final String userRole = response.data['role'] ?? 'ROLE_MEMBER';

        await _apiClient.saveTokens(accessToken, refreshToken);

        if (!mounted) return;

        
        final int id = (response.data['id'] as num?)?.toInt() ?? 0;
        context.read<AuthProvider>().loginSuccess(accessToken, userRole, id);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("로그인에 성공했습니다!"), backgroundColor: Colors.deepPurple),
        );

        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("아이디 또는 비밀번호가 일치하지 않습니다"), backgroundColor: Colors.redAccent),
      );
    }
  }

  // 2. 카카오 로그인 및 백엔드 연동
  Future<void> _loginWithKakao() async {
    try {
      OAuthToken token;

      if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      User user = await UserApi.instance.me();
      String nickname = user.kakaoAccount?.profile?.nickname ?? "카카오유저";

      final response = await _apiClient.loginWithKakao(
          token.accessToken,
          user.id,
          nickname
      );

      if (response.statusCode == 200) {
        final String ourAccessToken = response.data['accessToken'];
        final String ourRefreshToken = response.data['refreshToken'] ?? "";
        final String userRole = response.data['role'] ?? 'ROLE_MEMBER';

        await _apiClient.saveTokens(ourAccessToken, ourRefreshToken);

        if (!mounted) return;


        final int id = (response.data['id'] as num?)?.toInt() ?? 0;
        context.read<AuthProvider>().loginSuccess(ourAccessToken, userRole, id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("$nickname님, 환영합니다!"), backgroundColor: Colors.deepPurple),
        );

        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }

    } catch (error) {
      print('카카오 로그인/연동 실패: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("로그인 처리 중 오류가 발생했습니다."), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              "로그인이\n필요합니다",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.3),
            ),
            const SizedBox(height: 40),

            _buildTextField("아이디", _idController, false),
            const SizedBox(height: 16),
            _buildTextField("비밀번호", _pwController, true),

            Row(
              children: [
                Checkbox(
                  value: _isAutoLogin,
                  activeColor: Colors.deepPurple,
                  onChanged: (val) => setState(() => _isAutoLogin = val!),
                ),
                const Text("자동 로그인", style: TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text("로그인", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTextLink("아이디 찾기", "/find-id"),
                _buildDivider(),
                _buildTextLink("비밀번호 찾기", "/find-pw"),
                _buildDivider(),
                _buildTextLink("회원가입", "/signup"),
              ],
            ),

            const SizedBox(height: 50),
            Center(
              child: Column(
                children: [
                  const Text("SNS 계정으로 간편 로그인", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon("assets/icons/kakao.png", Colors.yellow, _loginWithKakao),
                      const SizedBox(width: 20),
                      _buildSocialIcon("assets/icons/naver.png", Colors.green, () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("네이버 로그인은 준비 중입니다.")));
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey.shade50,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.deepPurple),
        ),
      ),
    );
  }

  Widget _buildTextLink(String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 12,
      width: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 10),
    );
  }

  Widget _buildSocialIcon(String assetPath, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: const Icon(Icons.chat_bubble, color: Colors.black54),
      ),
    );
  }
}