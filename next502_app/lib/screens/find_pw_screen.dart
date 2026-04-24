import 'package:flutter/material.dart';

class FindPwScreen extends StatefulWidget {
  const FindPwScreen({super.key});

  @override
  State<FindPwScreen> createState() => _FindPwScreenState();
}

class _FindPwScreenState extends State<FindPwScreen> {
  // 컨트롤러 선언
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authController = TextEditingController();

  bool _isSent = false; // 인증번호 전송 여부

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("비밀번호 찾기", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          // 화면 높이에 맞춰 유동적으로 조절 (키보드 대응)
          height: MediaQuery.of(context).size.height - 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "가입하신 정보를 입력하시면\n비밀번호를 재설정할 수 있습니다.",
                style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              ),
              const SizedBox(height: 20),

              // 1. 아이디 입력 (비밀번호 찾기에 필수 추가)
              _buildLabel("아이디"),
              _buildTextField(_idController, "아이디를 입력하세요"),

              // 2. 이름 입력
              _buildLabel("이름"),
              _buildTextField(_nameController, "실명을 입력하세요"),

              // 3. 생년월일 입력
              _buildLabel("생년월일"),
              _buildTextField(_birthController, "YYYYMMDD (8자리)", isNumber: true),

              // 4. 전화번호 입력 + 인증요청
              _buildLabel("전화번호"),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(_phoneController, "'-' 없이 숫자만 입력", isNumber: true),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_idController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
                          setState(() => _isSent = true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("인증요청", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 5. 인증번호 입력 (인증요청 클릭 시 노출)
              if (_isSent) ...[
                _buildLabel("인증번호"),
                _buildTextField(_authController, "인증번호 6자리 입력", isNumber: true),
              ],

              const Spacer(),

              // 6. 다음 단계 버튼 (비밀번호 재설정 화면으로 이동)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSent ? () {
                    // 서버에서 본인 확인 완료 후 ResetPwScreen 등으로 이동
                    // Navigator.pushNamed(context, '/reset-pw');
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("비밀번호 재설정", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 공통 라벨 위젯
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  // 공통 텍스트 필드 위젯
  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
