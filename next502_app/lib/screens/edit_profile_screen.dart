import 'package:flutter/material.dart';
import 'package:next502_app/services/api_client.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiClient _apiClient = ApiClient();
  final _nickController = TextEditingController();
  final _birthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pwController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 마이페이지에서 넘겨준 기존 데이터 세팅
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _nickController.text = args['userNick'] ?? '';
      _birthController.text = args['birthDate'] ?? '';
      _phoneController.text = args['tel'] ?? '';
    }
  }

  String? _formatBirth(String input) {
    final digitsOnly = input.replaceAll('-', '');
    if (RegExp(r'^\d{8}$').hasMatch(digitsOnly)) {
      return '${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4, 6)}-${digitsOnly.substring(6, 8)}';
    }
    return digitsOnly.length == 10 ? digitsOnly : null;
  }

  Future<void> _handleUpdate() async {
    final birthFormatted = _formatBirth(_birthController.text.trim());
    if (birthFormatted == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("생년월일 8자리를 확인해주세요.")));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final updateData = {
        "userNick": _nickController.text.trim(),
        "birthDate": birthFormatted,
        "tel": _phoneController.text.trim(),
        if (_pwController.text.isNotEmpty) "userPw": _pwController.text,
      };

      final response = await _apiClient.updateMemberInfo(updateData);
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("정보가 수정되었습니다.")));
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("수정에 실패했습니다.")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("회원 정보 수정"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildInput("닉네임", _nickController),
            _buildInput("생년월일 (YYYYMMDD)", _birthController, isNumber: true),
            _buildInput("전화번호", _phoneController, isNumber: true),
            _buildInput("새 비밀번호 (변경 시만 입력)", _pwController, isPassword: true),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text("저장하기", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {bool isNumber = false, bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      ),
    );
  }
}