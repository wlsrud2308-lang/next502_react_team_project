import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:next502_app/services/api_client.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  final ImagePicker _picker = ImagePicker();
  final ApiClient _apiClient = ApiClient();

  File? _selectedImage;       // 선택된 사업자등록증 사진
  bool _isUploading = false;  // 업로드 중 여부 (로딩 표시용)

  // OCR 분석 결과 (성공 시 채워짐)
  String? _companyName;
  String? _registerNumber;
  String? _representativeName;
  String? _businessAddress;

  bool get _isAnalyzed => _companyName != null;

  /// 카메라/갤러리 선택 시트 표시
  Future<void> _showPickerSheet() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera, color: Colors.deepPurple),
              title: const Text("카메라로 촬영"),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.deepPurple),
              title: const Text("갤러리에서 선택"),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 이미지 선택 후 곧바로 OCR API 호출
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        imageQuality: 85,
      );

      if (picked == null) return;

      setState(() {
        _selectedImage = File(picked.path);
        _isUploading = true;
      });

      await _uploadAndAnalyze(File(picked.path));
    }
    catch (e) {
      _showSnack("사진을 가져올 수 없습니다: $e", isError: true);
      setState(() => _isUploading = false);
    }
  }

  /// 백엔드로 사진 전송 → OCR 결과 받기
  Future<void> _uploadAndAnalyze(File file) async {
    try {
      final response = await _apiClient.uploadBusinessLicense(file);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        setState(() {
          _companyName = data['companyName'];
          _registerNumber = data['registerNumber'];
          _representativeName = data['representativeName'];
          _businessAddress = data['businessAddress'];
          _isUploading = false;
        });

        // 백엔드가 mock 모드일 경우 메시지로 안내
        final msg = data['message'] as String?;
        if (msg != null && msg.contains('[MOCK]')) {
          _showSnack("개발용 더미 데이터입니다 (mock 모드)");
        } else {
          _showSnack("OCR 분석이 완료되었습니다");
        }
      } else {
        _showSnack("OCR 분석 실패 (코드: ${response.statusCode})", isError: true);
        setState(() => _isUploading = false);
      }
    }
    catch (e) {
      _showSnack("서버 연결 실패: 잠시 후 다시 시도해주세요", isError: true);
      setState(() {
        _isUploading = false;
        _selectedImage = null;
      });
    }
  }


  void _confirmAndReturn() {
    Navigator.pop(context, {
      'companyName': _companyName,
      'registerNumber': _registerNumber,
      'representativeName': _representativeName,
      'businessAddress': _businessAddress,
    });
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.deepPurple,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("사업자등록증 인증",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("사업자등록증을 업로드하면",
                style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
            const Text("상호 / 사업자번호 / 주소가 자동 입력됩니다.",
                style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),

            // 1. 업로드 영역
            _buildUploadArea(),

            const SizedBox(height: 24),

            // 2. 분석 결과 표시
            if (_isAnalyzed) _buildResultCard(),

            const SizedBox(height: 24),

            // 3. 안내 문구
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "인식이 잘 안 되면 사진을 다시 찍어주세요. 빛 반사 없이 평평한 곳에서 촬영해주세요.",
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 4. 다음 버튼
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isAnalyzed ? _confirmAndReturn : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("이 정보로 회원가입 진행",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }


  Widget _buildUploadArea() {
    return GestureDetector(
      onTap: _isUploading ? null : _showPickerSheet,
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: _isAnalyzed
              ? Colors.deepPurple.withOpacity(0.05)
              : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _isAnalyzed ? Colors.deepPurple : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: _buildUploadAreaContent(),
      ),
    );
  }

  Widget _buildUploadAreaContent() {
    if (_isUploading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.deepPurple),
            SizedBox(height: 12),
            Text("OCR 분석 중...", style: TextStyle(color: Colors.deepPurple)),
          ],
        ),
      );
    }

    if (_selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.file(_selectedImage!, fit: BoxFit.cover),
      );
    }

    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey),
        SizedBox(height: 10),
        Text("사업자등록증 사진 촬영 또는 선택",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }

  /// 분석 결과 카드
  Widget _buildResultCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.deepPurple, size: 18),
              SizedBox(width: 6),
              Text("인식된 정보",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            ],
          ),
          const SizedBox(height: 12),
          _buildResultRow("상호명", _companyName),
          _buildResultRow("사업자번호", _registerNumber),
          _buildResultRow("대표자", _representativeName),
          _buildResultRow("사업장 주소", _businessAddress),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(
              (value == null || value.isEmpty) ? "(인식 실패)" : value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: (value == null || value.isEmpty)
                    ? Colors.redAccent
                    : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}