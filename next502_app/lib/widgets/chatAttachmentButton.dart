import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ChatAttachmentButton extends StatelessWidget {
  final Function(ImageSource) onImagePick;
  final VoidCallback onVoiceCall;

  const ChatAttachmentButton({
    super.key,
    required this.onImagePick,
    required this.onVoiceCall,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.add_circle_outline, color: Colors.grey),
      onPressed: () => _showMenu(context),
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        height: 150,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildItem(context, Icons.photo, "갤러리", Colors.orange, () {
              Navigator.pop(context);
              onImagePick(ImageSource.gallery);
            }),
            _buildItem(context, Icons.camera_alt, "카메라", Colors.blue, () {
              Navigator.pop(context);
              onImagePick(ImageSource.camera);
            }),
            _buildItem(context, Icons.phone_in_talk, "보이스톡", Colors.green, () {
              Navigator.pop(context);
              onVoiceCall();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
