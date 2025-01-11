import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSentByMe;
  final bool isFirstMessage;
  final String avatarImage;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    required this.isFirstMessage,
    required this.avatarImage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isSentByMe && isFirstMessage)
          CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage(avatarImage),
          ),
        if (!isSentByMe && !isFirstMessage) const SizedBox(width: 50),
        if (!isSentByMe) const SizedBox(width: 10),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding:const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: isSentByMe
                  ? const LinearGradient(
                      colors: [Color(0xFF003675),Colors.blue, Colors.lightBlueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [Colors.grey[300]!, Colors.grey[200]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(
                    isFirstMessage ? (isSentByMe ? 12 : 0) : 6),
                topRight: Radius.circular(
                    isFirstMessage ? (isSentByMe ? 0 : 12) : 6),
                bottomLeft: const Radius.circular(12),
                bottomRight: const Radius.circular(12),
              ),
            ),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 15,
                color: isSentByMe ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
        if (isSentByMe) const SizedBox(width: 10),
        if (isSentByMe && isFirstMessage)
          CircleAvatar(
            radius: 22,
            backgroundImage: AssetImage(avatarImage),
          ),
        if (isSentByMe && !isFirstMessage) const SizedBox(width: 50),
      ],
    );
  }
}