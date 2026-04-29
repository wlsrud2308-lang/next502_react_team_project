import 'package:flutter/material.dart';

class ChatImageBubble extends StatelessWidget {
  final String imageUrl;
  final bool isMe;
  final String time;

  const ChatImageBubble({
    super.key,
    required this.imageUrl,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              // TODO: 이미지 전체 화면 보기 연결
            },
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.6, // 화면의 60% 크기
                maxHeight: 300,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  // 이미지 로딩 중 표시 (빙글빙글 아이콘)
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(
                      height: 200,
                      width: 200,
                      color: Colors.grey.shade100,
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    );
                  },
                  // 이미지 로드 실패 시
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    width: 150,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),
          // 전송 시간 표시
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 5, right: 5),
            child: Text(
              time,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
