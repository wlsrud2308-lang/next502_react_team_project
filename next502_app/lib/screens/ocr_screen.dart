import 'package:flutter/material.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  bool _isBizCardDone = false; // 사업자등록증 완료 여부
  bool _isIdCardDone = false;  // 신분증 완료 여부

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("본인 및 사업자 인증", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("마지막 단계: 증빙 서류 제출",
                style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            // 1. 사업자등록증 업로드 영역
            _buildUploadSection(
              title: "1. 사업자등록증 확인",
              isDone: _isBizCardDone,
              onTap: () => setState(() => _isBizCardDone = true),
              icon: Icons.business_center_outlined,
            ),

            const SizedBox(height: 20),

            // 2. 신분증 업로드 영역
            _buildUploadSection(
              title: "2. 대표자 신분증 확인",
              isDone: _isIdCardDone,
              onTap: () => setState(() => _isIdCardDone = true),
              icon: Icons.badge_outlined,
            ),

            const SizedBox(height: 40),

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
                      "임대인 정보 보호를 위해 신분증의 주민번호 뒷자리는 가리고 촬영해주셔도 됩니다.",
                      style: TextStyle(fontSize: 12, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // 4. 최종 인증 및 등록 완료 버튼
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                // 두 서류가 모두 업로드되어야 버튼 활성화
                onPressed: (_isBizCardDone && _isIdCardDone) ? () {
                  _showFinishPopup();
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("인증 서류 제출하기",
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 업로드 섹션 공통 위젯
  Widget _buildUploadSection({
    required String title,
    required bool isDone,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 25),
            decoration: BoxDecoration(
              color: isDone ? Colors.deepPurple.withOpacity(0.05) : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: isDone ? Colors.deepPurple : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isDone ? Icons.check_circle : icon,
                    color: isDone ? Colors.deepPurple : Colors.grey),
                const SizedBox(width: 10),
                Text(
                  isDone ? "업로드 완료" : "사진 촬영 또는 파일 선택",
                  style: TextStyle(
                      color: isDone ? Colors.deepPurple : Colors.grey,
                      fontWeight: isDone ? FontWeight.bold : FontWeight.normal
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 완료 팝업
  void _showFinishPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("등록 신청 완료"),
        content: const Text("사업자 및 본인 확인 서류가 정상 접수되었습니다.\n관리자 승인 후 창고가 공개됩니다."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
            child: const Text("확인", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

