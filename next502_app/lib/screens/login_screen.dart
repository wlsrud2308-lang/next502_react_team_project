import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  bool _isAutoLogin = false; // 자동 로그인 체크박스 상태

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

            // 1. 입력 필드 (아이디, 비밀번호)
            _buildTextField("아이디", _idController, false),
            const SizedBox(height: 16),
            _buildTextField("비밀번호", _pwController, true),

            // 2. 자동 로그인 체크박스
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

            // 3. 로그인 버튼
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // 임시 아이디와 비번
                  if (_idController.text == "test" && _pwController.text == "1234") {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("로그인에 성공했습니다!"),
                          backgroundColor: Colors.deepPurple,
                        ),
                    );
                  //   홈 화면으로 가기
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("아이디 또는 비밀번호가 일치하지 않습니다"),
                        backgroundColor: Colors.redAccent,
                        ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text("로그인", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),

            // 4. 아이디/비번 찾기 및 회원가입 링크
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

            // 5. 소셜 로그인 섹션 (이미지에서 언급한 네이버/카카오 연동 대비)
            Center(
              child: Column(
                children: [
                  const Text("SNS 계정으로 간편 로그인", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon("assets/icons/kakao.png", Colors.yellow),
                      const SizedBox(width: 20),
                      _buildSocialIcon("assets/icons/naver.png", Colors.green),
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

  // 텍스트 필드 공통 위젯
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

  // 텍스트 링크 위젯
  Widget _buildTextLink(String label, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
    );
  }

  // 링크 사이 구분선
  Widget _buildDivider() {
    return Container(
      height: 12,
      width: 1,
      color: Colors.grey.shade300,
      margin: const EdgeInsets.symmetric(horizontal: 10),
    );
  }

  // 소셜 로그인 아이콘 버튼 (모양만 구성)
  Widget _buildSocialIcon(String assetPath, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.chat_bubble, color: Colors.white), // 실제로는 이미지를 넣으시면 됩니다.
    );
  }
}
