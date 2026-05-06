import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:next502_app/providers/auth_provider.dart';
import 'package:next502_app/providers/warehouse_provider.dart';

class WarehouseInputScreen extends StatefulWidget {
  const WarehouseInputScreen({super.key});

  @override
  State<WarehouseInputScreen> createState() => _WarehouseInputScreenState();
}

class _WarehouseInputScreenState extends State<WarehouseInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();


  final List<String> _storageTypes = ['보통창고', '야적창고', '냉동/냉장창고', '저장창고', '간이창고', '위험물창고'];
  String _selectedType = '보통창고';

  // amenities 옵션
  final List<String> _amenityOptions = ['주차가능', '무인택배함', 'CCTV', '24시간 운영', '화물 엘리베이터'];
  final Set<String> _selectedAmenities = {};

  final _nameController = TextEditingController();
  final _addrController = TextEditingController();
  final _sizeController = TextEditingController(); // 평
  final _descController = TextEditingController();
  final _operationStructureController = TextEditingController();

  final List<File> _images = [];
  bool _isSubmitting = false;
  bool _accessChecked = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkAccess());
  }

  void _checkAccess() {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      _showSnack('로그인이 필요합니다.', isError: true);
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    if (!auth.isProvider) {
      _showSnack('창고 등록은 임대인(기업) 회원만 가능합니다.', isError: true);
      Navigator.pop(context);
      return;
    }
    setState(() => _accessChecked = true);
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

  /// 이미지 선택
  Future<void> _pickImage() async {
    if (_images.length >= 10) {
      _showSnack('이미지는 최대 10장까지 업로드 가능합니다.', isError: true);
      return;
    }
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() {
        _images.add(File(picked.path));
      });
    } catch (e) {
      _showSnack('이미지를 가져올 수 없습니다: $e', isError: true);
    }
  }

  void _removeImage(int idx) {
    setState(() => _images.removeAt(idx));
  }


  double _pyeongToSqm(double pyeong) => pyeong * 3.305785;

  /// 면적 기준 sizeRank 자동 계산
  String _calculateSizeRank(double sqm) {
    if (sqm < 100) return 'S';
    if (sqm < 500) return 'M';
    return 'L';
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;

    if (!_formKey.currentState!.validate()) {
      _showSnack('필수 입력 항목(*)을 모두 채워주세요.', isError: true);
      return;
    }
    if (_images.isEmpty) {
      _showSnack('이미지를 최소 1장 이상 업로드해주세요.', isError: true);
      return;
    }

    final pyeong = double.tryParse(_sizeController.text.trim()) ?? 0;
    if (pyeong <= 0) {
      _showSnack('면적은 0보다 커야 합니다.', isError: true);
      return;
    }

    final sqm = _pyeongToSqm(pyeong);
    final sizeRank = _calculateSizeRank(sqm);

    setState(() => _isSubmitting = true);

    try {
      final payload = {
        'name': _nameController.text.trim(),
        'address': _addrController.text.trim(),
        'description': _descController.text.trim(),
        'sizeRank': sizeRank,
        'totalArea': sqm.toStringAsFixed(2), // 백엔드 DTO 가 String
        'storageType': _selectedType,
        'operationStructure': _operationStructureController.text.trim(),
        'amenities': _selectedAmenities.join(','),
      };

      final warehouseId = await context.read<WarehouseProvider>().insertWarehouse(payload, _images);

      if (!mounted) return;
      _showSnack('창고 등록이 완료되었습니다!');
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    } on DioException catch (e) {
      String msg = '등록 실패';
      final data = e.response?.data;
      if (data is String && data.isNotEmpty) {
        msg = data;
      } else if (data is Map && data['message'] != null) {
        msg = data['message'].toString();
      }
      _showSnack(msg, isError: true);
    } catch (e) {
      _showSnack('등록 실패: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_accessChecked) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.deepPurple)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('창고 등록하기', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('창고 정보 입력',
                  style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              _buildSectionTitle('창고 사진 (첫 번째가 대표 이미지)'),
              const SizedBox(height: 12),
              _buildImageList(),
              const SizedBox(height: 30),

              _buildSectionTitle('상세 정보'),

              _buildLabel('창고 이름', isRequired: true),
              _buildTextFormField(_nameController, '예: 부산항 인근 신축 창고', '창고 이름을 입력해주세요.'),

              _buildLabel('창고 위치', isRequired: true),
              _buildTextFormField(_addrController, '주소를 입력하세요', '주소를 입력해주세요.'),

              const SizedBox(height: 16),
              _buildLabel('면적 (평)', isRequired: true),
              _buildTextFormField(_sizeController, '예: 100', '면적을 입력해주세요.', isNumber: true),

              const SizedBox(height: 20),
              _buildLabel('창고 유형', isRequired: true),
              _buildTypeDropdown(),

              const SizedBox(height: 20),
              _buildLabel('운영 구조'),
              _buildTextFormField(
                _operationStructureController,
                '예: 자가운영, 임대 등',
                null,
              ),

              const SizedBox(height: 24),
              _buildSectionTitle('편의시설'),
              const SizedBox(height: 12),
              _buildAmenityChips(),

              const SizedBox(height: 24),
              _buildLabel('상세 설명'),
              _buildTextFormField(_descController, '창고의 특장점을 자유롭게 적어주세요.', null, maxLines: 5),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('창고 등록하기',
                      style: TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) =>
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold));

  Widget _buildLabel(String label, {bool isRequired = false}) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Row(
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
        if (isRequired)
          const Text(' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _buildImageList() {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (ctx, idx) {
          // 마지막 = 추가 버튼
          if (idx == _images.length) {
            return GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, color: Colors.grey),
                    SizedBox(height: 6),
                    Text('사진 추가', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            );
          }

          final isMain = idx == 0;
          return Stack(
            children: [
              Container(
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isMain ? Colors.deepPurple : Colors.grey.shade300, width: isMain ? 2 : 1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: Image.file(_images[idx], fit: BoxFit.cover, width: 100, height: 110),
                ),
              ),
              if (isMain)
                Positioned(
                  left: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('대표', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              Positioned(
                right: 2,
                top: 2,
                child: GestureDetector(
                  onTap: () => _removeImage(idx),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextFormField(
      TextEditingController controller,
      String hint,
      String? errorMsg, {
        bool isNumber = false,
        int maxLines = 1,
        bool readOnly = false,
      }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      readOnly: readOnly,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (errorMsg != null && (value == null || value.trim().isEmpty)) {
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
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedType,
        isExpanded: true,
        items: _storageTypes.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
        onChanged: (v) => setState(() => _selectedType = v!),
      ),
    ),
  );

  Widget _buildAmenityChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _amenityOptions.map((item) {
        final selected = _selectedAmenities.contains(item);
        return FilterChip(
          label: Text(item),
          selected: selected,
          showCheckmark: false,
          backgroundColor: Colors.grey.shade50,
          selectedColor: Colors.deepPurple,
          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
          side: BorderSide(
            color: selected ? Colors.deepPurple : Colors.grey.shade300,
          ),
          onSelected: (val) {
            setState(() {
              if (val) {
                _selectedAmenities.add(item);
              } else {
                _selectedAmenities.remove(item);
              }
            });
          },
        );
      }).toList(),
    );
  }
}