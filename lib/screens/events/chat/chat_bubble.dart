// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ChatBubble extends StatelessWidget {
//   final String message;
//   final bool isSentByMe;
//   final bool isFirstMessage;
//   final String avatarImage;
//   final DateTime timestamp;

//   const ChatBubble({
//     super.key,
//     required this.message,
//     required this.isSentByMe,
//     required this.isFirstMessage,
//     required this.avatarImage,
//     required this.timestamp,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final timeString = DateFormat('hh:mm a').format(timestamp);

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.end,
//         mainAxisAlignment:
//             isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//         children: [
//           if (!isSentByMe && isFirstMessage)
//             CircleAvatar(
//               radius: 22,
//               backgroundImage: AssetImage(avatarImage),
//             ),
//           if (!isSentByMe && !isFirstMessage) const SizedBox(width: 44),
//           if (!isSentByMe) const SizedBox(width: 8),
//           Flexible(
//             child: Column(
//               crossAxisAlignment:
//                   isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     vertical: 12,
//                     horizontal: 16,
//                   ),
//                   decoration: BoxDecoration(
//                     gradient: isSentByMe
//                         ? const LinearGradient(
//                             colors: [
//                               Color(0xFF003675),
//                               Colors.blue,
//                               Colors.lightBlueAccent,
//                             ],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           )
//                         : LinearGradient(
//                             colors: [
//                               Colors.grey[300]!,
//                               Colors.grey[200]!,
//                             ],
//                             begin: Alignment.topLeft,
//                             end: Alignment.bottomRight,
//                           ),
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(
//                           isSentByMe ? 12 : (isFirstMessage ? 0 : 12)),
//                       topRight: Radius.circular(
//                           isSentByMe ? (isFirstMessage ? 0 : 12) : 12),
//                       bottomLeft: const Radius.circular(12),
//                       bottomRight: const Radius.circular(12),
//                     ),
//                   ),
//                   child: Text(
//                     message,
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: isSentByMe ? Colors.white : Colors.black87,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   timeString,
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (isSentByMe) const SizedBox(width: 8),
//           if (isSentByMe && isFirstMessage)
//             CircleAvatar(
//               radius: 22,
//               backgroundImage: AssetImage(avatarImage),
//             ),
//           if (isSentByMe && !isFirstMessage) const SizedBox(width: 44),
//         ],
//       ),
//     );
//   }
// }
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ChatBubble extends StatefulWidget {
//   final String message;
//   final bool isSentByMe;
//   final bool isFirstMessage;
//   final String avatarImage;
//   final DateTime timestamp;

//   const ChatBubble({
//     super.key,
//     required this.message,
//     required this.isSentByMe,
//     required this.isFirstMessage,
//     required this.avatarImage,
//     required this.timestamp,
//   });

//   @override
//   State<ChatBubble> createState() => _ChatBubbleState();
// }

// class _ChatBubbleState extends State<ChatBubble> {
//   bool _showTimestamp = false;

//   void _toggleTimestamp() {
//     setState(() {
//       _showTimestamp = !_showTimestamp;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final timeString = DateFormat('hh:mm a').format(widget.timestamp);

//     return GestureDetector(
//       onTap: _toggleTimestamp,
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           mainAxisAlignment:
//               widget.isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
//           children: [
//             if (!widget.isSentByMe && widget.isFirstMessage)
//               CircleAvatar(
//                 radius: 22,
//                 backgroundImage: AssetImage(widget.avatarImage),
//               ),
//             if (!widget.isSentByMe && !widget.isFirstMessage)
//               const SizedBox(width: 44),
//             if (!widget.isSentByMe) const SizedBox(width: 8),
//             Flexible(
//               child: Column(
//                 crossAxisAlignment: widget.isSentByMe
//                     ? CrossAxisAlignment.end
//                     : CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 12,
//                       horizontal: 16,
//                     ),
//                     decoration: BoxDecoration(
//                       gradient: widget.isSentByMe
//                           ? const LinearGradient(
//                               colors: [
//                                 Color(0xFF003675),
//                                 Colors.blue,
//                                 Colors.lightBlueAccent,
//                               ],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             )
//                           : LinearGradient(
//                               colors: [
//                                 Colors.grey[300]!,
//                                 Colors.grey[200]!,
//                               ],
//                               begin: Alignment.topLeft,
//                               end: Alignment.bottomRight,
//                             ),
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(
//                             widget.isSentByMe ? 12 : (widget.isFirstMessage ? 0 : 12)),
//                         topRight: Radius.circular(
//                             widget.isSentByMe ? (widget.isFirstMessage ? 0 : 12) : 12),
//                         bottomLeft: const Radius.circular(12),
//                         bottomRight: const Radius.circular(12),
//                       ),
//                     ),
//                     child: Text(
//                       widget.message,
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: widget.isSentByMe ? Colors.white : Colors.black87,
//                       ),
//                     ),
//                   ),
//                   if (_showTimestamp)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 4),
//                       child: Text(
//                         timeString,
//                         style: TextStyle(
//                           fontSize: 12,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             if (widget.isSentByMe) const SizedBox(width: 8),
//             if (widget.isSentByMe && widget.isFirstMessage)
//               CircleAvatar(
//                 radius: 22,
//                 backgroundImage: AssetImage(widget.avatarImage),
//               ),
//             if (widget.isSentByMe && !widget.isFirstMessage)
//               const SizedBox(width: 44),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isSentByMe;
  final bool isFirstMessage;
  final String avatarImage;
  final DateTime timestamp;
  final bool showTimestamp;
  final VoidCallback onTap;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isSentByMe,
    required this.isFirstMessage,
    required this.avatarImage,
    required this.timestamp,
    required this.showTimestamp,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat('hh:mm a').format(timestamp);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment:
              isSentByMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isSentByMe && isFirstMessage)
              CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage(avatarImage),
              ),
            if (!isSentByMe && !isFirstMessage)
              const SizedBox(width: 44),
            if (!isSentByMe) const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: isSentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSentByMe
                          ? const LinearGradient(
                              colors: [
                                Color(0xFF003675),
                                Colors.blue,
                                Colors.lightBlueAccent,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [
                                Colors.grey[300]!,
                                Colors.grey[200]!,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(
                            isSentByMe ? 12 : (isFirstMessage ? 0 : 12)),
                        topRight: Radius.circular(
                            isSentByMe ? (isFirstMessage ? 0 : 12) : 12),
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
                  if (showTimestamp)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        timeString,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isSentByMe) const SizedBox(width: 8),
            if (isSentByMe && isFirstMessage)
              CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage(avatarImage),
              ),
            if (isSentByMe && !isFirstMessage)
              const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }
}
