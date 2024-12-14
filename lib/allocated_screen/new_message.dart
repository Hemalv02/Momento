// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';

// class NewMessage extends StatefulWidget {
//   const NewMessage({super.key});

//   @override
//   State<NewMessage> createState() {
//     return _NewMessageState();
//   }
// }

// class _NewMessageState extends State<NewMessage> {
//   final _messageController = TextEditingController();

//   @override
//   void dispose() {
//     _messageController.dispose();
//     super.dispose();
//   }

//   void _submitMessage() async {
//     final enteredMessage = _messageController.text;

//     if (enteredMessage.trim().isEmpty) {
//       return;
//     }

//     FocusScope.of(context).unfocus();
//     _messageController.clear();

//     final user = FirebaseAuth.instance.currentUser!;
//     final userData = await FirebaseFirestore.instance
//         .collection('users')
//         .doc(user.uid)
//         .get();

//     FirebaseFirestore.instance.collection('chat').add({
//       'text': enteredMessage,
//       'createdAt': Timestamp.now(),
//       'userId': user.uid,
//       'username': userData.data()!['username'],
//       'userImage': userData.data()!['image_url'],
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _messageController,
//               textCapitalization: TextCapitalization.sentences,
//               autocorrect: true,
//               enableSuggestions: true,
//               decoration: const InputDecoration(labelText: 'Send a message...'),
//             ),
//           ),
//           IconButton(
//             color: Theme.of(context).colorScheme.primary,
//             icon: const Icon(
//               Icons.send,
//             ),
//             onPressed: _submitMessage,
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _messageController.clear();
    });

    try {
      final user = FirebaseAuth.instance.currentUser!;
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      await FirebaseFirestore.instance.collection('chat').add({
        'text': enteredMessage,
        'createdAt': FieldValue.serverTimestamp(),
        'userId': user.uid,
        'username': userData.data()?['username'] ?? 'Unknown',
        'userImage': userData.data()?['image_url'] ?? '',
      });
    } catch (error) {
      print('Error sending message: $error');
    }
  }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _messageController,
//               textCapitalization: TextCapitalization.sentences,
//               autocorrect: true,
//               enableSuggestions: true,
//               decoration: const InputDecoration(labelText: 'Send a message...'),
//             ),
//           ),
//           IconButton(
//             color: Theme.of(context).colorScheme.primary,
//             icon: const Icon(Icons.send),
//             onPressed: _submitMessage,
//           ),
//         ],
//       ),
//     );
//   }
// }
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize:
          MainAxisSize.min, // Ensure the column takes only required space
      children: [
        Divider(
          color: Colors.blueGrey,
          thickness: 5,
        ),
        // Fixed height box to input message
        Container(
          margin: const EdgeInsets.all(10), // Spacing from the button
          height: 120, // Fixed height for the input box
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade100, // Light grey background
            borderRadius: BorderRadius.circular(10), // Rounded corners
            border:
                Border.all(color: Colors.grey[400]!, width: 1), // Border color
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: TextField(
            controller: _messageController,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            style: const TextStyle(color: Colors.black),
            maxLines: null, // Allows scrolling for overflow text
            keyboardType: TextInputType.multiline, // Multi-line input
            decoration: const InputDecoration(
              border: InputBorder.none, // Remove default border
              hintText: 'Type your message here...',
              hintStyle: TextStyle(color: Colors.black),
            ),
            
          ),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            onPressed: _submitMessage,
            child: const Text('Send Message'),
          ),
        ),
      ],
    );
  }
}
