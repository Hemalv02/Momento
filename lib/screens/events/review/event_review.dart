// // import 'package:flutter/material.dart';
// // import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// // import 'package:momento/screens/events/review/event_review_submit.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';

// // class ReviewsScreen extends StatefulWidget {
// //   final int eventId;

// //   const ReviewsScreen({super.key, required this.eventId});

// //   @override
// //   State<ReviewsScreen> createState() => _ReviewsScreenState();
// // }

// // class _ReviewsScreenState extends State<ReviewsScreen> {
// //   final supabase = Supabase.instance.client;
// //   final String tableName = 'reviews';
// //   final String eventIdColumn = 'event_id';

// //   Stream<List<Map<String, dynamic>>> _reviewsStream() async* {
// //     final streamController = supabase
// //         .from(tableName)
// //         .stream(primaryKey: ['id'])
// //         .eq(eventIdColumn, widget.eventId);

// //     await for (final List<Map<String, dynamic>> reviews in streamController) {
// //       yield reviews;
// //     }
// //   }

// //   double _calculateAverageRating(List<Map<String, dynamic>> reviews) {
// //     if (reviews.isEmpty) return 0.0;

// //     double totalRating = 0.0;
// //     reviews.forEach((review) {
// //       totalRating += (review['rating'] as num).toDouble();
// //     });
// //     return totalRating / reviews.length;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final baseColor = const Color(0xFF003675);

// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         title: const Text("Event Reviews"),
// //         backgroundColor: baseColor,
// //         foregroundColor: Colors.white,
// //       ),
// //       floatingActionButton: FloatingActionButton(
// //         backgroundColor: baseColor,
// //         foregroundColor: Colors.white,
// //         onPressed: () {
// //           Navigator.of(context).push(
// //             MaterialPageRoute(
// //               builder: (context) => SubmitReviewScreen(eventId: widget.eventId),
// //             ),
// //           );
// //         },
// //         child: const Icon(Icons.add),
// //       ),
// //       body: StreamBuilder<List<Map<String, dynamic>>>(
// //         stream: _reviewsStream(),
// //         builder: (context, snapshot) {
// //           if (snapshot.connectionState == ConnectionState.waiting) {
// //             return Center(
// //               child: CircularProgressIndicator(color: baseColor),
// //             );
// //           }

// //           if (snapshot.hasError) {
// //             return Center(
// //               child: Text(
// //                 'Failed to load reviews: ${snapshot.error}',
// //                 style: const TextStyle(color: Colors.red),
// //               ),
// //             );
// //           }

// //           final reviews = snapshot.data ?? [];
// //           final averageRating = _calculateAverageRating(reviews);

// //           return ListView(
// //             padding: const EdgeInsets.all(16.0),
// //             children: [
// //               // Average Rating Section
// //               Container(
// //                 padding: const EdgeInsets.all(16),
// //                 decoration: BoxDecoration(
// //                   color: baseColor.withOpacity(0.05),
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(
// //                       "Average Rating",
// //                       style: TextStyle(
// //                         fontSize: 20,
// //                         fontWeight: FontWeight.bold,
// //                         color: baseColor,
// //                       ),
// //                     ),
// //                     const SizedBox(height: 10),
// //                     Row(
// //                       children: [
// //                         Text(
// //                           averageRating.toStringAsFixed(1),
// //                           style: TextStyle(
// //                             fontSize: 32,
// //                             fontWeight: FontWeight.bold,
// //                             color: baseColor,
// //                           ),
// //                         ),
// //                         const SizedBox(width: 10),
// //                         RatingBarIndicator(
// //                           rating: averageRating,
// //                           itemBuilder: (context, _) => Icon(
// //                             Icons.star,
// //                             color: Colors.amber.shade600,
// //                           ),
// //                           itemCount: 5,
// //                           itemSize: 30,
// //                         ),
// //                       ],
// //                     ),
// //                     const SizedBox(height: 8),
// //                     Text(
// //                       'Based on ${reviews.length} reviews',
// //                       style: TextStyle(
// //                         color: baseColor.withOpacity(0.7),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               const SizedBox(height: 20),

// //               // User Reviews
// //               Text(
// //                 "User Reviews",
// //                 style: TextStyle(
// //                   fontSize: 20,
// //                   fontWeight: FontWeight.bold,
// //                   color: baseColor,
// //                 ),
// //               ),
// //               const SizedBox(height: 10),
// //               reviews.isEmpty
// //                   ? Center(
// //                       child: Text(
// //                         'No reviews yet',
// //                         style: TextStyle(color: baseColor.withOpacity(0.6)),
// //                       ),
// //                     )
// //                   : Column(
// //                       children: List.generate(
// //                         reviews.length,
// //                         (index) {
// //                           final review = reviews[index];
// //                           return Container(
// //                             margin: const EdgeInsets.symmetric(vertical: 8),
// //                             decoration: BoxDecoration(
// //                               color: baseColor.withOpacity(0.05),
// //                               borderRadius: BorderRadius.circular(8),
// //                               border: Border.all(
// //                                 color: baseColor.withOpacity(0.1),
// //                                 width: 1,
// //                               ),
// //                             ),
// //                             child: Padding(
// //                               padding: const EdgeInsets.all(16),
// //                               child: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 children: [
// //                                   Row(
// //                                     mainAxisAlignment:
// //                                         MainAxisAlignment.spaceBetween,
// //                                     children: [
// //                                       Expanded(
// //                                         child: Text(
// //                                           review['users']?['username'] ??
// //                                               'Unknown',
// //                                           style: TextStyle(
// //                                             fontWeight: FontWeight.bold,
// //                                             fontSize: 16,
// //                                             color: baseColor,
// //                                             overflow: TextOverflow.ellipsis,
// //                                           ),
// //                                         ),
// //                                       ),
// //                                       RatingBarIndicator(
// //                                         rating: (review['rating'] as num)
// //                                             .toDouble(),
// //                                         itemBuilder: (context, _) => Icon(
// //                                           Icons.star,
// //                                           color: Colors.amber.shade600,
// //                                         ),
// //                                         itemCount: 5,
// //                                         itemSize: 20,
// //                                       ),
// //                                     ],
// //                                   ),
// //                                   const SizedBox(height: 8),
// //                                   Text(
// //                                     review['review_text'] ?? '',
// //                                     style: TextStyle(
// //                                       fontSize: 14,
// //                                       color: Colors.grey.shade700,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                     ),
// //             ],
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:momento/screens/events/review/event_review_submit.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ReviewsScreen extends StatefulWidget {
//   final int eventId;

//   const ReviewsScreen({super.key, required this.eventId});

//   @override
//   State<ReviewsScreen> createState() => _ReviewsScreenState();
// }

// class _ReviewsScreenState extends State<ReviewsScreen> {
//   final supabase = Supabase.instance.client;
//   final String tableName = 'reviews';
//   final String eventIdColumn = 'event_id';

//   Stream<List<Map<String, dynamic>>> _reviewsStream() async* {
//     final streamController = supabase
//         .from(tableName)
//         .stream(primaryKey: ['id']).eq(eventIdColumn, widget.eventId);

//     await for (final List<Map<String, dynamic>> reviews in streamController) {
//       for (final review in reviews) {
//         final userResponse = await supabase
//             .from('users')
//             .select('username')
//             .eq('id', review['user_id'])
//             .single(); // Use `.single()` to get a single user

//         // If userResponse has data, extract the username
//         if (userResponse != null && userResponse['username'] != null) {
//           review['username'] =
//               userResponse['username']; // Add username to review
//         } else {
//           review['username'] = 'Unknown'; // Default username if not found
//         }
//       }
//       yield reviews;
//     }
//   }

//   double _calculateAverageForCriteria(
//       List<Map<String, dynamic>> reviews, String criteria) {
//     if (reviews.isEmpty) return 0.0;

//     double total = 0.0;
//     int count = 0;
//     for (final review in reviews) {
//       total += (review[criteria] as num?)?.toDouble() ?? 0.0;
//       count += (review[criteria] as num?)?.toDouble() != 0.0 ? 1 : 0;
//     }
//     return total / count;
//   }

//   Widget _buildCriteriaCard({
//     required String title,
//     required IconData icon,
//     required double averageRating,
//   }) {
//     const baseColor = Color(0xFF003675);

//     return Card(
//       color: const Color.fromARGB(255, 240, 246, 252),
//       elevation: 3,
//       margin: const EdgeInsets.symmetric(vertical: 8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: [
//             Icon(icon, size: 40, color: baseColor),
//             const SizedBox(width: 16),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: baseColor,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 RatingBarIndicator(
//                   rating: averageRating,
//                   itemBuilder: (context, _) => Icon(
//                     Icons.star,
//                     color: Colors.amber.shade600,
//                   ),
//                   itemCount: 5,
//                   itemSize: 20,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     const baseColor = Color(0xFF003675);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: const Text("Event Reviews"),
//         backgroundColor: baseColor,
//         foregroundColor: Colors.white,
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: baseColor,
//         foregroundColor: Colors.white,
//         onPressed: () {
//           Navigator.of(context).push(
//             MaterialPageRoute(
//               builder: (context) => SubmitReviewScreen(eventId: widget.eventId),
//             ),
//           );
//         },
//         child: const Icon(Icons.add),
//       ),
//       body: StreamBuilder<List<Map<String, dynamic>>>(
//         stream: _reviewsStream(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(color: baseColor),
//             );
//           }

//           if (snapshot.hasError) {
//             return Center(
//               child: Text(
//                 'Failed to load reviews: ${snapshot.error}',
//                 style: const TextStyle(color: Colors.red),
//               ),
//             );
//           }

//           List<Map<String, dynamic>> reviews = snapshot.data ?? [];
//           final foodRating =
//               _calculateAverageForCriteria(reviews, 'food_rating');
//           final accommodationRating =
//               _calculateAverageForCriteria(reviews, 'accommodation_rating');
//           final managementRating =
//               _calculateAverageForCriteria(reviews, 'management_rating');
//           final appUsageRating =
//               _calculateAverageForCriteria(reviews, 'app_usage_rating');

//           return ListView(
//             padding: const EdgeInsets.all(16.0),
//             children: [
//               // Average Ratings for Criteria
//               const Text(
//                 "Average Ratings",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: baseColor,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               _buildCriteriaCard(
//                 title: "Food Quality",
//                 icon: Icons.restaurant,
//                 averageRating: foodRating,
//               ),
//               _buildCriteriaCard(
//                 title: "Accommodation",
//                 icon: Icons.hotel,
//                 averageRating: accommodationRating,
//               ),
//               _buildCriteriaCard(
//                 title: "Management",
//                 icon: Icons.people,
//                 averageRating: managementRating,
//               ),
//               _buildCriteriaCard(
//                 title: "App Usage",
//                 icon: Icons.phone_android,
//                 averageRating: appUsageRating,
//               ),
//               const SizedBox(height: 20),

//               // User Reviews Section
//               const Text(
//                 "User Reviews",
//                 style: TextStyle(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: baseColor,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               reviews.isEmpty
//                   ? Center(
//                       child: Text(
//                         'No reviews yet',
//                         style: TextStyle(color: baseColor.withAlpha(153)),
//                       ),
//                     )
//                   : Column(
//                       children: List.generate(
//                         reviews.length,
//                         (index) {
//                           final review = reviews[index];
//                           return Card(
//                             elevation: 3,
//                             margin: const EdgeInsets.symmetric(vertical: 8),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12)),
//                             child: Padding(
//                               padding: const EdgeInsets.all(16),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       Expanded(
//                                         child: Text(
//                                           review['username'] ?? 'Unknown',
//                                           style: const TextStyle(
//                                             fontWeight: FontWeight.bold,
//                                             fontSize: 16,
//                                             color: baseColor,
//                                           ),
//                                         ),
//                                       ),
//                                       RatingBarIndicator(
//                                         rating:
//                                             (review['overall_rating'] as num?)
//                                                     ?.toDouble() ??
//                                                 0.0,
//                                         itemBuilder: (context, _) => Icon(
//                                           Icons.star,
//                                           color: Colors.amber.shade600,
//                                         ),
//                                         itemCount: 5,
//                                         itemSize: 20,
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     review['review_text'] ?? '',
//                                     style: TextStyle(
//                                       fontSize: 14,
//                                       color: Colors.grey.shade700,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:momento/screens/events/review/event_review_submit.dart';
import 'package:momento/screens/events/review/criterion_reviews_screen.dart'; // Import the new screen
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewsScreen extends StatefulWidget {
  final int eventId;

  const ReviewsScreen({super.key, required this.eventId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final supabase = Supabase.instance.client;
  final String tableName = 'reviews';
  final String eventIdColumn = 'event_id';

  Stream<List<Map<String, dynamic>>> _reviewsStream() async* {
    final streamController = supabase
        .from(tableName)
        .stream(primaryKey: ['id']).eq(eventIdColumn, widget.eventId);

    await for (final List<Map<String, dynamic>> reviews in streamController) {
      yield reviews;
    }
  }

  double _calculateAverageForCriteria(
      List<Map<String, dynamic>> reviews, String criteria) {
    if (reviews.isEmpty) return 0.0;

    double total = 0.0;
    int count = 0;
    for (final review in reviews) {
      total += (review[criteria] as num?)?.toDouble() ?? 0.0;
      count += (review[criteria] as num?)?.toDouble() != 0.0 ? 1 : 0;
    }
    return total / count;
  }

  Widget _buildCriteriaCard({
    required String title,
    required IconData icon,
    required double averageRating,
    required List<Map<String, dynamic>> reviews,
    required String criteria,
  }) {
    const baseColor = Color(0xFF003675);

    return GestureDetector(
      onTap: () {
        // Navigate to the new screen with the detailed reviews for the selected criterion
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CriterionReviewsScreen(
              criterion: criteria,
              eventId: widget.eventId,
            ),
          ),
        );
      },
      child: Card(
        color: const Color.fromARGB(255, 240, 246, 252),
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: baseColor),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: baseColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RatingBarIndicator(
                    rating: averageRating,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber.shade600,
                    ),
                    itemCount: 5,
                    itemSize: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const baseColor = Color(0xFF003675);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Event Reviews"),
        backgroundColor: baseColor,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: baseColor,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SubmitReviewScreen(eventId: widget.eventId),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>( 
        stream: _reviewsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: baseColor),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Failed to load reviews: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          List<Map<String, dynamic>> reviews = snapshot.data ?? [];
          final foodRating =
              _calculateAverageForCriteria(reviews, 'food_rating');
          final accommodationRating =
              _calculateAverageForCriteria(reviews, 'accommodation_rating');
          final managementRating =
              _calculateAverageForCriteria(reviews, 'management_rating');
          final appUsageRating =
              _calculateAverageForCriteria(reviews, 'app_usage_rating');

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Average Ratings for Criteria
              const Text(
                "Average Ratings",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: baseColor,
                ),
              ),
              const SizedBox(height: 10),
              _buildCriteriaCard(
                title: "Food Quality",
                icon: Icons.restaurant,
                averageRating: foodRating,
                reviews: reviews,
                criteria: 'food',
              ),
              _buildCriteriaCard(
                title: "Accommodation",
                icon: Icons.hotel,
                averageRating: accommodationRating,
                reviews: reviews,
                criteria: 'accommodation',
              ),
              _buildCriteriaCard(
                title: "Management",
                icon: Icons.people,
                averageRating: managementRating,
                reviews: reviews,
                criteria: 'management',
              ),
              _buildCriteriaCard(
                title: "App Usage",
                icon: Icons.phone_android,
                averageRating: appUsageRating,
                reviews: reviews,
                criteria: 'app_usage',
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
