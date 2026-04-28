import 'package:flutter/material.dart';
import 'package:next502_app/services/api_client.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String _userRole = "BUYER"; // 기본값 일반회원

  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwConfirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _nickController = TextEditingController();
  final _birthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // --- OCR 결과 저장을 위한 변수 추가 ---
  String? _businessName;
  String? _businessNumber;
  String? _businessAddress;
  bool _isOcrVerified = false;

  final ApiClient _apiClient = ApiClient();

  // OCR 화면으로 이동하여 결과 받아오기
  Future<void> _navigateToOcr() async {

    final result = await Navigator.pushNamed(context, '/ocr_verify');

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _businessName = result['companyName'];
        _businessNumber = result['registerNumber'];
        _businessAddress = result['businessAddress'];
        _isOcrVerified = true;

        // OCR로 추출된 대표자명을 이름 필드에 자동 입력
        if (result['representativeName'] != null) {
          _nameController.text = result['representativeName'];
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("사업자 정보가 인증되었습니다."), backgroundColor: Colors.green),
      );
    }
  }

  // 회원가입 처리
  Future<void> _handleSignup() async {
    // 1. 공통 유효성 검사
    if (_pwController.text != _pwConfirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("비밀번호가 일치하지 않습니다."), backgroundColor: Colors.redAccent),
      );
      return;
    }

    // 2. 공급자일 경우 OCR 인증 여부 확인
    if (_userRole == "PROVIDER" && !_isOcrVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("임대인 가입을 위해 사업자 인증이 필요합니다."), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      String backendRole = (_userRole == "PROVIDER") ? "ROLE_PROVIDER" : "ROLE_MEMBER";

      // 3. 전송 데이터 구성 (OCR 데이터 포함)
      final userData = {
        "userId": _idController.text,
        "userPw": _pwController.text,
        "userEmail": _emailController.text,
        "userNick": _nickController.text,
        "name": _nameController.text,
        "birthDate": _birthController.text,
        "tel": _phoneController.text,
        "role": backendRole,
        // OCR 추가 정보 (일반회원이면 null로 전송됨)
        "businessName": _businessName,
        "businessNumber": _businessNumber,
        "businessAddress": _businessAddress,
      };

      final response = await _apiClient.signup(userData);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("회원가입이 완료되었습니다!"), backgroundColor: Colors.deepPurple),
        );
        // 가입 성공 시 로그인 화면으로 이동
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("가입 실패: 입력 정보를 다시 확인해주세요."), backgroundColor: Colors.redAccent),
      );
    }
  }

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

            const Text("임대인으로 가입하시겠습니까?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSelectionButton("PROVIDER", "예"),
                const SizedBox(width: 10),
                _buildSelectionButton("BUYER", "아니오"),
              ],
            ),

            // --- 공급자 선택 시 OCR 인증 섹션 표시 ---
            if (_userRole == "PROVIDER") ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _isOcrVerified ? Colors.deepPurple : Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("사업자 등록증 인증", style: TextStyle(fontWeight: FontWeight.bold)),
                        if (_isOcrVerified)
                          const Icon(Icons.check_circle, color: Colors.deepPurple),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (_isOcrVerified) ...[
                      Text("상호: $_businessName", style: const TextStyle(fontSize: 13)),
                      Text("번호: $_businessNumber", style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 10),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _navigateToOcr,
                        icon: const Icon(Icons.camera_alt, size: 18),
                        label: Text(_isOcrVerified ? "다시 인증하기" : "사업자등록증 촬영/업로드"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isOcrVerified ? Colors.grey : Colors.deepPurple.shade400,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 50),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("가입하기", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }


  Widget _buildSelectionButton(String role, String label) {
    bool isSelected = _userRole == role;
    return Expanded(
      child: OutlinedButton(
        onPressed: () => setState(() {
          _userRole = role;
          if (role == "BUYER") {
            _isOcrVerified = false; // 일반회원으로 변경 시 인증 해제
          }
        }),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
    );
  }
}