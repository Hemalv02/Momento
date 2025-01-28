// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:momento/screens/profile/user_profile_view_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'dart:typed_data'; // Ensure this import matches your project structure

// class CriterionReviewsScreen extends StatefulWidget {
//   final String criterion;
//   final int eventId;

//   const CriterionReviewsScreen({
//     super.key,
//     required this.criterion,
//     required this.eventId,
//   });

//   @override
//   State<CriterionReviewsScreen> createState() => _CriterionReviewsScreenState();
// }

// class _CriterionReviewsScreenState extends State<CriterionReviewsScreen> {
//   final supabase = Supabase.instance.client;
//   late String rating;
//   late String feedback;
//   final Map<String, Uint8List?> _profilePicsCache = {};

//   @override
//   void initState() {
//     super.initState();
//     rating = '${widget.criterion}_rating';
//     feedback = '${widget.criterion}_feedback';
//   }

//   Future<Uint8List?> _getProfilePicture(String username) async {
//     if (_profilePicsCache.containsKey(username)) {
//       return _profilePicsCache[username];
//     }

//     try {
//       final response = await supabase
//           .from('profile_pics')
//           .select('url')
//           .eq('username', username)
//           .single();

//       // if (response != null && response['url'] != null) {
//       if (response['url'] != null) {
//         final url = response['url'];
//         final imageResponse = await http.get(Uri.parse(url));

//         if (imageResponse.statusCode == 200) {
//           _profilePicsCache[username] = imageResponse.bodyBytes;
//           return imageResponse.bodyBytes;
//         }
//       }
//     } catch (e) {
//       debugPrint('Error fetching profile picture for $username: $e');
//     }

//     _profilePicsCache[username] = null;
//     return null;
//   }

//   Stream<List<Map<String, dynamic>>> _getReviewsStream() {
//     return supabase
//         .from('reviews')
//         .stream(primaryKey: ['id'])
//         .eq('event_id', widget.eventId)
//         .asyncMap((List<Map<String, dynamic>> reviews) async {
//           final filteredReviews =
//               reviews.where((review) => review[rating] != null).toList();

//           final processedReviews =
//               await Future.wait(filteredReviews.map((review) async {
//             try {
//               final userResponse = await supabase
//                   .from('users')
//                   .select('username')
//                   .eq('id', review['user_id'])
//                   .single();

//               return {
//                 ...review,
//                 'username': userResponse['username'] ?? 'Unknown'
//               };
//             } catch (e) {
//               return {...review, 'username': 'Unknown'};
//             }
//           }));

//           return processedReviews;
//         });
//   }

//   Widget _buildRatingBar(
//       int star, Map<int, int> ratingsCount, int totalReviews) {
//     final count = ratingsCount[star] ?? 0;
//     final percentage = totalReviews > 0 ? (count / totalReviews) : 0.0;
//     const baseColor = Color(0xFF003675);

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 6),
//       child: Row(
//         children: [
//           Text(
//             '$star star',
//             style: TextStyle(
//               fontWeight: FontWeight.w600,
//               color: baseColor.withAlpha(178),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: LinearProgressIndicator(
//                 value: percentage,
//                 backgroundColor: baseColor.withAlpha(25),
//                 valueColor:
//                     AlwaysStoppedAnimation<Color>(baseColor.withAlpha(178)),
//                 minHeight: 8,
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           SizedBox(
//             width: 40,
//             child: Text(
//               '${(percentage * 100).toStringAsFixed(0)}%',
//               style: TextStyle(
//                 color: baseColor.withAlpha(178),
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Text(
//             '($count)',
//             style: TextStyle(
//               color: baseColor.withAlpha(178),
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Map<int, int> _getRatingBreakdown(List<Map<String, dynamic>> reviews) {
//     Map<int, int> ratingCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
//     for (var review in reviews) {
//       final reviewRating = (review[rating] as num?)?.toDouble();
//       if (reviewRating != null) {
//         int roundedRating = reviewRating.round();
//         if (roundedRating >= 1 && roundedRating <= 5) {
//           ratingCount[roundedRating] = (ratingCount[roundedRating] ?? 0) + 1;
//         }
//       }
//     }
//     return ratingCount;
//   }

//   @override
//   Widget build(BuildContext context) {
//     const baseColor = Color(0xFF003675);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           '${widget.criterion.split('_').map((e) => '${e[0].toUpperCase()}${e.substring(1).toLowerCase()}').join(' ')} Reviews',
//         ),
//         backgroundColor: baseColor,
//         foregroundColor: Colors.white,
//         elevation: 0,
//       ),
//       body: StreamBuilder<List<Map<String, dynamic>>>(
//         stream: _getReviewsStream(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(
//                 color: baseColor,
//               ),
//             );
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Text('Error: ${snapshot.error}'),
//             );
//           }

//           final reviews = snapshot.data ?? [];
//           if (reviews.isEmpty) {
//             return const Center(child: Text('No reviews for this criterion.'));
//           }

//           final ratingsCount = _getRatingBreakdown(reviews);
//           final totalReviews =
//               ratingsCount.values.fold(0, (sum, count) => sum + count);

//           return ListView(
//             padding: const EdgeInsets.all(16.0),
//             children: [
//               const Text(
//                 "Ratings Breakdown",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: baseColor,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Card(
//                 color: const Color.fromARGB(255, 240, 246, 252),
//                 elevation: 3,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: List.generate(
//                       5,
//                       (index) => _buildRatingBar(
//                           5 - index, ratingsCount, totalReviews),
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 "User Reviews",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: baseColor,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               ...reviews.map(
//                 (review) => Container(
//                   margin: const EdgeInsets.symmetric(vertical: 8),
//                   decoration: BoxDecoration(
//                     color: const Color.fromARGB(255, 240, 246, 252),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withAlpha(25),
//                         spreadRadius: 1,
//                         blurRadius: 2,
//                         offset: const Offset(0, 1),
//                       ),
//                     ],
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                       color: baseColor.withAlpha(25),
//                       width: 1,
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Profile Picture with Tap Functionality
//                         FutureBuilder<Uint8List?>(
//                           future: _getProfilePicture(review['username']),
//                           builder: (context, snapshot) {
//                             return GestureDetector(
//                               onTap: () async {
//                                 final prefs =
//                                     await SharedPreferences.getInstance();
//                                 final currUser = prefs.getString("username");
//                                 if (currUser != review['username']) {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                       builder: (context) => UserProfileViewPage(
//                                         viewedUsername: review['username'],
//                                       ),
//                                     ),
//                                   );
//                                 }
//                               },
//                               child: CircleAvatar(
//                                 radius: 24.r,
//                                 backgroundColor: snapshot.data != null
//                                     ? Colors.transparent
//                                     : Colors.amber.shade100,
//                                 foregroundColor: baseColor,
//                                 backgroundImage: snapshot.data != null
//                                     ? MemoryImage(snapshot.data!)
//                                     : null,
//                                 child: snapshot.data == null
//                                     ? Text(
//                                         (review['username']?.isNotEmpty ??
//                                                 false)
//                                             ? review['username']![0]
//                                                 .toUpperCase()
//                                             : '?',
//                                         style: const TextStyle(
//                                             fontWeight: FontWeight.bold),
//                                       )
//                                     : null,
//                               ),
//                             );
//                           },
//                         ),
//                         const SizedBox(width: 8),
//                         // Review Content
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Username and Rating
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       review['username'] ?? 'Unknown',
//                                       style: const TextStyle(
//                                         fontWeight: FontWeight.bold,
//                                         fontSize: 16,
//                                         color: baseColor,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                   ),
//                                   RatingBarIndicator(
//                                     rating:
//                                         (review[rating] as num?)?.toDouble() ??
//                                             0.0,
//                                     itemBuilder: (context, _) => Icon(
//                                       Icons.star,
//                                       color: Colors.amber.shade600,
//                                     ),
//                                     itemCount: 5,
//                                     itemSize: 20,
//                                   ),
//                                 ],
//                               ),
//                               // Feedback
//                               if (review[feedback]?.isNotEmpty ?? false) ...[
//                                 const SizedBox(height: 8),
//                                 Text(
//                                   review[feedback],
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     color: Colors.grey.shade700,
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:momento/screens/profile/user_profile_view_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';

class CriterionReviewsScreen extends StatefulWidget {
  final String criterion;
  final int eventId;

  const CriterionReviewsScreen({
    super.key,
    required this.criterion,
    required this.eventId,
  });

  @override
  State<CriterionReviewsScreen> createState() => _CriterionReviewsScreenState();
}

class _CriterionReviewsScreenState extends State<CriterionReviewsScreen> {
  final supabase = Supabase.instance.client;
  late String rating;
  late String feedback;
  final Map<String, Uint8List?> _profilePicsCache = {};
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    rating = '${widget.criterion}_rating';
    feedback = '${widget.criterion}_feedback';
    _loadCurrentUsername();
  }

  Future<void> _loadCurrentUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUsername = prefs.getString('username');
    });
  }

  Future<Uint8List?> _getProfilePicture(String username) async {
    if (_profilePicsCache.containsKey(username)) {
      return _profilePicsCache[username];
    }

    try {
      final response = await supabase
          .from('profile_pics')
          .select('url')
          .eq('username', username)
          .single();

      // if (response != null && response['url'] != null) {
      if (response['url'] != null) {
        final url = response['url'];
        final imageResponse = await http.get(Uri.parse(url));

        if (imageResponse.statusCode == 200) {
          _profilePicsCache[username] = imageResponse.bodyBytes;
          return imageResponse.bodyBytes;
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile picture for $username: $e');
    }

    _profilePicsCache[username] = null;
    return null;
  }

  Stream<List<Map<String, dynamic>>> _getReviewsStream() {
    return supabase
        .from('reviews')
        .stream(primaryKey: ['id'])
        .eq('event_id', widget.eventId)
        .asyncMap((List<Map<String, dynamic>> reviews) async {
          final filteredReviews =
              reviews.where((review) => review[rating] != null).toList();

          final processedReviews =
              await Future.wait(filteredReviews.map((review) async {
            try {
              final userResponse = await supabase
                  .from('users')
                  .select('username')
                  .eq('id', review['user_id'])
                  .single();

              return {
                ...review,
                'username': userResponse['username'] ?? 'Unknown'
              };
            } catch (e) {
              return {...review, 'username': 'Unknown'};
            }
          }));

          return processedReviews;
        });
  }

  Widget _buildRatingBar(
      int star, Map<int, int> ratingsCount, int totalReviews) {
    final count = ratingsCount[star] ?? 0;
    final percentage = totalReviews > 0 ? (count / totalReviews) : 0.0;
    const baseColor = Color(0xFF003675);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$star star',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: baseColor.withAlpha(178),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: baseColor.withAlpha(25),
                valueColor:
                    AlwaysStoppedAnimation<Color>(baseColor.withAlpha(178)),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 40,
            child: Text(
              '${(percentage * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: baseColor.withAlpha(178),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '($count)',
            style: TextStyle(
              color: baseColor.withAlpha(178),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Map<int, int> _getRatingBreakdown(List<Map<String, dynamic>> reviews) {
    Map<int, int> ratingCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (var review in reviews) {
      final reviewRating = (review[rating] as num?)?.toDouble();
      if (reviewRating != null) {
        int roundedRating = reviewRating.round();
        if (roundedRating >= 1 && roundedRating <= 5) {
          ratingCount[roundedRating] = (ratingCount[roundedRating] ?? 0) + 1;
        }
      }
    }
    return ratingCount;
  }

  Future<void> _showEditDialog(Map<String, dynamic> review) async {
    double currentRating = (review[rating] as num?)?.toDouble() ?? 0.0;
    String currentFeedback = review[feedback] ?? '';

    final TextEditingController feedbackController =
        TextEditingController(text: currentFeedback);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16.w,
              right: 16.w,
              top: 16.h,
            ),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle at the top
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Text(
                    'Edit Review',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF003675),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Rating Bar
                          Center(
                            child: RatingBar.builder(
                              initialRating: currentRating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 40,
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber.shade600,
                              ),
                              onRatingUpdate: (value) {
                                currentRating = value;
                              },
                            ),
                          ),
                          SizedBox(height: 16.h),
                          // Feedback TextField
                          TextField(
                            controller: feedbackController,
                            decoration: const InputDecoration(
                              labelText: 'Feedback',
                              border: OutlineInputBorder(),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFF003675)),
                              ),
                            ),
                            maxLines: 3,
                          ),
                          SizedBox(height: 24.h),
                          // Update Button
                          SizedBox(
                            width: double.infinity,
                            height: 50.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF003675),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () async {
                                if (feedbackController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('Feedback cannot be empty')),
                                  );
                                  return;
                                }
                                try {
                                  await supabase.from('reviews').update({
                                    rating: currentRating,
                                    feedback: feedbackController.text.trim(),
                                  }).eq('id', review['id']);

                                  if (mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Review updated successfully')),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Error updating review: $e')),
                                    );
                                  }
                                }
                              },
                              child: Text(
                                'Update Review',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  // Previous methods remain the same...

  @override
  Widget build(BuildContext context) {
    const baseColor = Color(0xFF003675);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '${widget.criterion.split('_').map((e) => '${e[0].toUpperCase()}${e.substring(1).toLowerCase()}').join(' ')} Reviews',
        ),
        backgroundColor: baseColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getReviewsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: baseColor,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final reviews = snapshot.data ?? [];
          if (reviews.isEmpty) {
            return const Center(child: Text('No reviews for this criterion.'));
          }

          final ratingsCount = _getRatingBreakdown(reviews);
          final totalReviews =
              ratingsCount.values.fold(0, (sum, count) => sum + count);
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const Text(
                "Ratings Breakdown",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: baseColor,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                color: const Color.fromARGB(255, 240, 246, 252),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: List.generate(
                      5,
                      (index) => _buildRatingBar(
                          5 - index, ratingsCount, totalReviews),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "User Reviews",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: baseColor,
                ),
              ),
              const SizedBox(height: 10),
              ...reviews.map(
                (review) => Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 240, 246, 252),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(25),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: baseColor.withAlpha(25),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
//                         // Profile Picture with Tap Functionality
                        FutureBuilder<Uint8List?>(
                          future: _getProfilePicture(review['username']),
                          builder: (context, snapshot) {
                            return GestureDetector(
                              onTap: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                final currUser = prefs.getString("username");
                                if (currUser != review['username']) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => UserProfileViewPage(
                                        viewedUsername: review['username'],
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: CircleAvatar(
                                radius: 24.r,
                                backgroundColor: snapshot.data != null
                                    ? Colors.transparent
                                    : Colors.amber.shade100,
                                foregroundColor: baseColor,
                                backgroundImage: snapshot.data != null
                                    ? MemoryImage(snapshot.data!)
                                    : null,
                                child: snapshot.data == null
                                    ? Text(
                                        (review['username']?.isNotEmpty ??
                                                false)
                                            ? review['username']![0]
                                                .toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
//
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            review['username'] ?? 'Unknown',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: baseColor,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        if (review['username'] ==
                                            currentUsername)
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                size: 20),
                                            color: baseColor,
                                            onPressed: () =>
                                                _showEditDialog(review),
                                          ),
                                      ],
                                    ),
                                  ),
                                  RatingBarIndicator(
                                    rating:
                                        (review[rating] as num?)?.toDouble() ??
                                            0.0,
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber.shade600,
                                    ),
                                    itemCount: 5,
                                    itemSize: 20,
                                  ),
                                ],
                              ),
                              if (review[feedback]?.isNotEmpty ?? false) ...[
                                const SizedBox(height: 8),
                                Text(
                                  review[feedback],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
