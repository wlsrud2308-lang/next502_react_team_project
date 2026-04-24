import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 임시 데이터 (질문과 답변)
    final List<Map<String, String>> faqs = [
      {'q': '창고 예약은 어떻게 하나요?', 'a': '상세 페이지 하단의 [전화하기] 또는 [채팅하기] 버튼을 통해 임대인과 직접 상의 후 예약할 수 있습니다.'},
      {'q': '이용 요금은 어떻게 지불하나요?', 'a': '창고이음은 별도의 결제 시스템을 제공하지 않습니다. 임대인과 협의하여 직접 결제하시면 됩니다.'},
      {'q': '임대인과 연락이 되지 않아요.', 'a': '고객센터로 문의해주시면 확인 후 빠른 연락을 도와드리겠습니다.'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('자주 묻는 질문 (FAQ)'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(
              faqs[index]['q']!,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                color: Colors.grey[100],
                child: Text(faqs[index]['a']!),
              ),
            ],
          );
        },
      ),
    );
  }
}