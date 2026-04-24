import 'package:flutter/material.dart';

class FindIdScreen extends StatefulWidget {
  const FindIdScreen({super.key});

  @override
  State<FindIdScreen> createState() => _FindIdScreenState();
}

class _FindIdScreenState extends State<FindIdScreen> {
  // 컨트롤러 선언
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _authController = TextEditingController(); // 인증번호용

  bool _isSent = false; // 인증번호 전송 여부

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("아이디 찾기", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView( // 정보가 많으므로 스크롤 가능하게 설정
        padding: const EdgeInsets.all(24.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 120, // 화면 높이에 맞춤
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "등록된 회원 정보로\n아이디를 찾을 수 있습니다.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
              ),
              const SizedBox(height: 30),

              // 1. 이름 입력
              _buildInputLabel("이름"),
              _buildTextField(_nameController, "실명을 입력하세요"),

              // 2. 생년월일 입력
              _buildInputLabel("생년월일"),
              _buildTextField(_birthController, "YYYYMMDD (8자리)", isNumber: true),

              // 3. 전화번호 입력 + 인증요청
              _buildInputLabel("전화번호"),
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
                        // 모든 필드가 채워졌을 때만 전송 (간단한 체크)
                        if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
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

              // 4. 인증번호 입력 필드 (인증요청 후에만 노출)
              if (_isSent) ...[
                _buildInputLabel("인증번호"),
                _buildTextField(_authController, "인증번호 6자리 입력", isNumber: true),
              ],

              const Spacer(),

              // 5. 아이디 확인 버튼
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSent ? () {
                    // 서버 통신 후 결과 팝업 또는 페이지 이동
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("아이디 찾기", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
