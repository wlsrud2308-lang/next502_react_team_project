import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // DB의 role 대응 (기본값 BUYER = 아니오)
  String _userRole = "BUYER";

  // 컨트롤러 정의
  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwConfirmController = TextEditingController(); // 비밀번호 확인 추가
  final _nameController = TextEditingController();       // 이름 추가
  final _nickController = TextEditingController();       // 닉네임 분리
  final _birthController = TextEditingController();      // 생년월일 추가
  final _phoneController = TextEditingController();      // 전화번호 추가
  final _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("회원가입", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 기본 정보 입력 섹션
            _buildInputLabel("아이디"),
            _buildTextField(_idController, "아이디를 입력하세요"),

            _buildInputLabel("비밀번호"),
            _buildTextField(_pwController, "비밀번호를 입력하세요", isPassword: true),

            _buildInputLabel("비밀번호 확인"),
            _buildTextField(_pwConfirmController, "비밀번호를 다시 한번 입력하세요", isPassword: true),

            _buildInputLabel("이름 (실명)"),
            _buildTextField(_nameController, "실명을 입력해주세요"),

            _buildInputLabel("닉네임"),
            _buildTextField(_nickController, "앱에서 사용할 닉네임을 입력하세요"),

            _buildInputLabel("생년월일"),
            _buildTextField(_birthController, "YYYYMMDD (8자리)", isNumber: true),

            _buildInputLabel("전화번호"),
            _buildTextField(_phoneController, "'-' 없이 숫자만 입력", isNumber: true),

            _buildInputLabel("이메일"),
            _buildTextField(_emailController, "example@email.com"),

            const SizedBox(height: 40),

            // 2. 임대인 여부 선택 (예/아니오)
            const Text("임대인으로 가입하시겠습니까?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSelectionButton("PROVIDER", "예"),
                const SizedBox(width: 10),
                _buildSelectionButton("BUYER", "아니오"),
              ],
            ),

            const SizedBox(height: 50),

            // 3. 최종 가입 버튼
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // 비밀번호 일치 확인 로직 예시
                  if (_pwController.text != _pwConfirmController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("비밀번호가 일치하지 않습니다.")),
                    );
                    return;
                  }
                  print("가입 데이터 전송 준비: ${_nameController.text}, $_userRole");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("가입하기",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 예/아니오 선택 버튼 위젯
  Widget _buildSelectionButton(String role, String label) {
    bool isSelected = _userRole == role;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => setState(() => _userRole = role),
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? Colors.deepPurple : Colors.white,
          side: BorderSide(color: isSelected ? Colors.deepPurple : Colors.grey.shade300),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isPassword = false, bool isNumber = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none
        ),
      ),
    );
  }
}
