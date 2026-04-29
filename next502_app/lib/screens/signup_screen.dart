import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:next502_app/providers/auth_provider.dart';
import 'package:next502_app/services/api_client.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String _userRole = "BUYER";

  final _idController = TextEditingController();
  final _pwController = TextEditingController();
  final _pwConfirmController = TextEditingController();
  final _nameController = TextEditingController();
  final _nickController = TextEditingController();
  final _birthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  String? _businessName;
  String? _businessNumber;
  String? _businessAddress;
  bool _isOcrVerified = false;
  bool _isSubmitting = false;

  final ApiClient _apiClient = ApiClient();

  Future<void> _navigateToOcr() async {
    final result = await Navigator.pushNamed(context, '/ocr_verify');

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _businessName = result['companyName'];
        _businessNumber = result['registerNumber'];
        _businessAddress = result['businessAddress'];
        _isOcrVerified = true;

        if (result['representativeName'] != null) {
          _nameController.text = result['representativeName'];
        }
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("사업자 정보가 인증되었습니다."), backgroundColor: Colors.green),
      );
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.redAccent),
    );
  }

  String? _formatBirth(String input) {
    final digitsOnly = input.replaceAll('-', '');
    if (RegExp(r'^\d{8}$').hasMatch(digitsOnly)) {
      return '${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4, 6)}-${digitsOnly.substring(6, 8)}';
    }
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(input)) {
      return input;
    }
    return null;
  }

  Future<void> _handleSignup() async {
    if (_isSubmitting) return;

    final id = _idController.text.trim();
    final pw = _pwController.text;
    final pwConfirm = _pwConfirmController.text;
    final name = _nameController.text.trim();
    final nick = _nickController.text.trim();
    final birth = _birthController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    if (id.isEmpty) return _showError("아이디를 입력하세요.");
    if (pw.isEmpty) return _showError("비밀번호를 입력하세요.");
    if (pw != pwConfirm) return _showError("비밀번호가 일치하지 않습니다.");
    if (name.isEmpty) return _showError("이름을 입력하세요.");
    if (nick.isEmpty) return _showError("닉네임을 입력하세요.");
    if (birth.isEmpty) return _showError("생년월일을 입력하세요.");

    final birthFormatted = _formatBirth(birth);
    if (birthFormatted == null) {
      return _showError("생년월일을 8자리 숫자 또는 YYYY-MM-DD로 입력하세요.");
    }

    if (phone.isEmpty) return _showError("전화번호를 입력하세요.");

    if (_userRole == "PROVIDER" && !_isOcrVerified) {
      return _showError("임대인 가입을 위해 사업자 인증이 필요합니다.");
    }

    setState(() => _isSubmitting = true);

    try {
      String backendRole = (_userRole == "PROVIDER") ? "ROLE_PROVIDER" : "ROLE_MEMBER";

      final userData = {
        "userId": id,
        "userPw": pw,
        "userEmail": email,
        "userNick": nick,
        "name": name,
        "birthDate": birthFormatted,
        "tel": phone,
        "role": backendRole,
        "businessName": _businessName,
        "businessNumber": _businessNumber,
        "businessAddress": _businessAddress,
      };

      final response = await _apiClient.signup(userData);

      if (response.statusCode == 200) {

        if (response.data['accessToken'] == null) {
          String failMsg = response.data['message']?.toString() ??
              response.data['error']?.toString() ??
              "이미 존재하는 사용자이거나 가입에 실패했습니다.";
          setState(() => _isSubmitting = false);
          return _showError(failMsg);
        }

        // 정상 가입 처리
        final String accessToken = response.data['accessToken'];
        final String refreshToken = response.data['refreshToken'] ?? "";
        final String userRole = response.data['role'] ?? 'ROLE_MEMBER';

        await _apiClient.saveTokens(accessToken, refreshToken);

        if (!mounted) return;
        final int id = (response.data['id'] as num?)?.toInt() ?? 0;
        await context.read<AuthProvider>().loginSuccess(accessToken, userRole, id);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("회원가입이 완료되었습니다!"), backgroundColor: Colors.deepPurple),
        );

        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      if (e is DioException) {

        print('=== [회원가입 에러 디버깅] ===');
        print('상태 코드: ${e.response?.statusCode}');
        print('응답 데이터: ${e.response?.data}');
        print('데이터 타입: ${e.response?.data.runtimeType}');
        print('=============================');

        String errorMessage = "가입에 실패했습니다.";
        final responseData = e.response?.data;

        if (responseData != null) {
          if (responseData is String) {
            errorMessage = responseData;
          } else if (responseData is Map) {
            errorMessage = responseData['message']?.toString() ?? responseData['error']?.toString() ?? errorMessage;
          }
        }
        _showError(errorMessage);
      } else {
        print('알 수 없는 에러: $e');
        _showError("가입 처리 중 오류 발생: $e");
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
            _buildTextField(_birthController, "YYYYMMDD 또는 YYYY-MM-DD", isNumber: true),

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
                onPressed: _isSubmitting ? null : _handleSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text("가입하기", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
            _isOcrVerified = false;
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