// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:momento/allocated_screen/event_review.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class FeedbackScreen extends StatefulWidget {
//   const FeedbackScreen({super.key});

//   @override
//   State<FeedbackScreen> createState() => _FeedbackScreenState();
// }

// class _FeedbackScreenState extends State<FeedbackScreen> {
//   int _rating = 0;
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _feedbackController = TextEditingController();

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _feedbackController.dispose();
//     super.dispose();
//   }

//   void _submitFeedback() async {
//     final String name = _nameController.text.trim();
//     final String feedback = _feedbackController.text.trim();

//     if (name.isEmpty || feedback.isEmpty || _rating == 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('Please fill in all fields and provide a rating.')),
//       );
//       return;
//     }

//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Feedback sent successfully!')),
//     );

//     try {
//        final supabase = Supabase.instance.client;
//       final user = supabase.auth.currentUser;
//       final userData = await FirebaseFirestore.instance
//           .collection('users')
//           .doc(user!.id)
//           .get();

//       await FirebaseFirestore.instance.collection('feedback').add({
//         'feedback': feedback,
//         'rating': _rating,
//         'createdAt': FieldValue.serverTimestamp(),
//         'username': userData.data()?['username'] ?? 'Unknown',
//       });
//     } catch (error) {
//       print('Error sending message: $error');
//     }

//     setState(() {
//       _rating = 0;
//       _nameController.clear();
//       _feedbackController.clear();
//     });
//   }

//   Widget _buildStar(int index) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _rating = index;
//         });
//       },
//       child: Icon(
//         Icons.star,
//         size: 40,
//         color: index <= _rating ? Colors.yellow : Colors.grey.shade400,
//       ),
//     );
//   }

//   void _moreActions() {
//     showMenu(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(10),
//       ),
//       color: Colors.blueGrey,
//       context: context,
//       position: const RelativeRect.fromLTRB(1000, 80, 0, 0),
//       items: [
//         PopupMenuItem(
//           padding: const EdgeInsets.all(10),
//           value: 'show_reviews',
//           child: const Text('Show all reviews', style: TextStyle(color: Colors.white)),
//         ),
//       ],
//     ).then(
//       (value) {
//         if (value == 'show_reviews') {
//           Navigator.push(context, MaterialPageRoute(builder: (context) {
//             return const EventReviewScreen();
//           }));
//         }
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Feedback'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.more_vert),
//             onPressed: _moreActions,
//           )
//         ],
//       ),
//       body: SingleChildScrollView(
//         // Makes the whole screen scrollable
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 'Rate Event',
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Share your feedback, suggestions, rating to event organizers.',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 16),

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: List.generate(5, (index) => _buildStar(index + 1)),
//               ),

//               const SizedBox(height: 24),

//               const Text(
//                 'Name',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.grey),
//                 ),
//                 child: TextField(
//                   style: const TextStyle(color: Colors.black),
//                   controller: _nameController,
//                   decoration: const InputDecoration(
//                     hintText: 'Enter your name',
//                     hintStyle: TextStyle(color: Colors.black),
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                     border: InputBorder.none,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 16),

//               const Text(
//                 'Feedback/Suggestions',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Container(
//                 height: 150,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade100,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(color: Colors.grey),
//                 ),
//                 child: TextField(
//                   controller: _feedbackController,
//                   style: const TextStyle(color: Colors.black),
//                   maxLines: null,
//                   keyboardType: TextInputType.multiline,
//                   decoration: const InputDecoration(
//                     hintText: 'Enter your feedback or suggestions here.',
//                     hintStyle: TextStyle(color: Colors.black),
//                     contentPadding:
//                         EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//                     border: InputBorder.none,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 24),

//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _submitFeedback,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                   ),
//                   child: const Text('Send Feedback'),
//                 ),
//               ),

//               const SizedBox(height: 16), // Space at the bottom
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
