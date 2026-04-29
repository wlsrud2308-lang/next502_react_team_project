import 'package:flutter/material.dart';
import 'package:next502_app/widgets/chatAttachmentButton.dart';
import 'package:image_picker/image_picker.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final Function(ImageSource) onImagePick;
  final VoidCallback onVoiceCall;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onImagePick,
    required this.onVoiceCall,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea( // 아이폰 하단 바 영역 대응
        child: Row(
          children: [
            ChatAttachmentButton(
          onImagePick: onImagePick,
          onVoiceCall: onVoiceCall,
        ),

            // 2. 텍스트 입력창
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: null, // 내용이 길어지면 자동으로 줄바꿈
                  onSubmitted: (_) => onSend(),
                  textInputAction: TextInputAction.send,
                  decoration: const InputDecoration(
                    hintText: "메시지를 입력하세요",
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // 3. 전송 버튼
            GestureDetector(
              onTap: onSend,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
