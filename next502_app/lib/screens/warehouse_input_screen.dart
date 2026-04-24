import 'package:flutter/material.dart';

class WarehouseInputScreen extends StatefulWidget {
  const WarehouseInputScreen({super.key});

  @override
  State<WarehouseInputScreen> createState() => _WarehouseInputScreenState();
}

class _WarehouseInputScreenState extends State<WarehouseInputScreen> {
  // 1. 유효성 검사를 위한 폼 키 추가
  final _formKey = GlobalKey<FormState>();

  String _selectedType = "보통";
  final List<String> _types = ["보통", "야적", "냉동/냉장", "저장", "간이", "위험물", "기타"];
  bool _canPark = true;
  bool _hasLift = false;

  final _nameController = TextEditingController();
  final _addrController = TextEditingController();
  final _sizeController = TextEditingController();
  final _heightController = TextEditingController();
  final _descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("창고 등록하기", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        // 2. 전체를 Form으로 감쌉니다.
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("1/2 단계: 기본 정보 입력", style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              LinearProgressIndicator(value: 0.5, backgroundColor: Colors.grey.shade200, color: Colors.deepPurple),
              const SizedBox(height: 30),

              _buildSectionTitle("창고 전경 사진"),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildPhotoBox(true),
                    const SizedBox(width: 10),
                    _buildPhotoBox(false),
                    const SizedBox(width: 10),
                    _buildPhotoBox(false),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              _buildSectionTitle("상세 정보 입력"),

              // 필수 항목들 (*) 표시 추가
              _buildLabel("창고 이름", isRequired: true),
              _buildTextFormField(_nameController, "예: 부산항 인근 신축 창고", "창고 이름을 입력해주세요."),

              _buildLabel("창고 위치", isRequired: true),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // 에러 메시지 공간 대응
                children: [
                  Expanded(
                    child: _buildTextFormField(_addrController, "주소 찾기 버튼을 눌러주세요", "주소를 검색해주세요.", readOnly: true),
                  ),
                  const SizedBox(width: 10),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: OutlinedButton(
                      onPressed: () {
                        // 테스트용: 버튼 누르면 주소 자동 입력 시뮬레이션
                        setState(() {
                          _addrController.text = "부산광역시 중구 중앙대로 1";
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.deepPurple),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text("주소 찾기"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("면적 (평)", isRequired: true),
                      _buildTextFormField(_sizeController, "0", "면적 입력", isNumber: true),
                    ],
                  )),
                  const SizedBox(width: 20),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel("층고 (m)"),
                      _buildTextFormField(_heightController, "0.0", null, isNumber: true),
                    ],
                  )),
                ],
              ),

              const SizedBox(height: 20),
              _buildLabel("창고 유형", isRequired: true),
              _buildTypeDropdown(),

              const SizedBox(height: 20),
              _buildSectionTitle("시설 옵션"),
              SwitchListTile(
                title: const Text("주차 및 하역 가능"),
                value: _canPark,
                activeColor: Colors.deepPurple,
                onChanged: (v) => setState(() => _canPark = v),
              ),
              SwitchListTile(
                title: const Text("화물 전용 승강기 보유"),
                value: _hasLift,
                activeColor: Colors.deepPurple,
                onChanged: (v) => setState(() => _hasLift = v),
              ),

              const SizedBox(height: 20),
              _buildLabel("상세 설명"),
              _buildTextFormField(_descController, "창고의 특장점을 자유롭게 적어주세요.", null, maxLines: 5),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // 1. 폼 유효성 검사 (필수 항목 체크)
                    if (_formKey.currentState!.validate()) {
                      // 성공 시 메시지 표시
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("정보가 확인되었습니다. 본인 인증 단계로 이동합니다."),
                          backgroundColor: Colors.deepPurple,
                        ),
                      );

                      // 2. OCR 스크린으로 이동 (라우트 이름 사용)
                      Navigator.pushNamed(context, '/ocr_verify');
                    } else {
                      // 실패 시 메시지
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("필수 입력 항목(*)을 모두 채워주세요.")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("다음 단계로",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // 내부 도우미 위젯들
  Widget _buildSectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));

  // 라벨에 별표(*) 추가 기능 포함
  Widget _buildLabel(String label, {bool isRequired = false}) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
        if (isRequired)
          const Text(" *", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _buildPhotoBox(bool isMain) => Container(
    width: 100,
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: isMain ? Colors.deepPurple : Colors.grey.shade300),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo, color: isMain ? Colors.deepPurple : Colors.grey),
        Text(isMain ? "메인사진" : "추가사진", style: const TextStyle(fontSize: 10)),
      ],
    ),
  );

  // TextFormField로 변경하여 Validator 적용
  Widget _buildTextFormField(TextEditingController controller, String hint, String? errorMsg, {bool isNumber = false, int maxLines = 1, bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (errorMsg != null && (value == null || value.isEmpty)) {
          return errorMsg;
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        errorStyle: const TextStyle(color: Colors.red, fontSize: 11),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildTypeDropdown() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.transparent), // 테두리 유지용
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedType,
        isExpanded: true,
        items: _types.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: (v) => setState(() => _selectedType = v!),
      ),
    ),
  );
}
