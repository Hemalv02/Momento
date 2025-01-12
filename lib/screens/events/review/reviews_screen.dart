// import 'package:flutter/material.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ReviewsScreen extends StatefulWidget {
//   final int eventId;

//   const ReviewsScreen({super.key, required this.eventId});

//   @override
//   State<ReviewsScreen> createState() => _ReviewsScreenState();
// }

// class _ReviewsScreenState extends State<ReviewsScreen>
//     with SingleTickerProviderStateMixin {
//   final supabase = Supabase.instance.client;
//   double _averageRating = 0.0;
//   Map<int, int> _ratingsCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
//   List<Map<String, dynamic>> _reviews = [];
//   bool _isLoading = true;

//   // Animation Controller
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _fetchReviews();

//     // Initialize animation
//     _animationController =
//         AnimationController(vsync: this, duration: const Duration(seconds: 1));
//     _fadeAnimation =
//         CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
//   }

//   Future<void> _fetchReviews() async {
//     try {
//       // Fetch reviews for the event
//       final response = await supabase
//           .from('reviews')
//           .select()
//           .eq('event_id', widget.eventId);

//       final data = response as List<dynamic>;

//       // Initialize ratings count
//       Map<int, int> ratingsCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

//       // Fetch related user data
//       final reviews = await Future.wait(data.map((review) async {
//         final userResponse = await supabase
//             .from('users')
//             .select('username')
//             .eq('id', review['user_id'])
//             .single();
//         final username = userResponse['username'] ?? 'Unknown';

//         // Update ratings count
//         final int rating = (review['rating'] as num).toInt();
//         ratingsCount[rating] = ratingsCount[rating]! + 1;

//         return {
//           'user': username,
//           'content': review['review_text'],
//           'rating': rating.toDouble(),
//         };
//       }));

//       // Calculate average rating
//       final totalReviews = reviews.length;
//       final averageRating = totalReviews == 0
//           ? 0.0
//           : ratingsCount.entries
//                   .fold<double>(
//                     0.0,
//                     (sum, entry) => sum + entry.key * entry.value,
//                   ) /
//               totalReviews;

//       setState(() {
//         _reviews = reviews.cast<Map<String, dynamic>>();
//         _averageRating = averageRating;
//         _ratingsCount = ratingsCount;
//         _isLoading = false;
//       });

//       // Start animation after data is loaded
//       _animationController.forward();
//     } catch (error) {
//       setState(() {
//         _isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load reviews: $error')),
//       );
//     }
//   }

//   Widget _buildRatingBar(int star, int totalReviews) {
//     final count = _ratingsCount[star] ?? 0;
//     final percentage = totalReviews > 0 ? (count / totalReviews) : 0.0;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           Text('$star star',
//               style: const TextStyle(fontWeight: FontWeight.bold)),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Stack(
//               children: [
//                 Container(
//                   height: 20,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 FractionallySizedBox(
//                   widthFactor: percentage,
//                   child: Container(
//                     height: 20,
//                     decoration: BoxDecoration(
//                       color: const Color.fromARGB(255, 60, 76, 103),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//         SizedBox(width:40, child: Text('${(percentage * 100).toStringAsFixed(0)}%')),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final totalReviews =
//         _ratingsCount.values.fold<int>(0, (sum, count) => sum + count);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Reviews"),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF003675), Color(0xFF0074D9)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : AnimatedBuilder(
//               animation: _fadeAnimation,
//               builder: (context, child) {
//                 return Opacity(
//                   opacity: _fadeAnimation.value,
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "Average Rating",
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF003675),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Row(
//                           children: [
//                             RatingBarIndicator(
//                               rating: _averageRating,
//                               itemBuilder: (context, _) => const Icon(
//                                 Icons.star,
//                                 color: Colors.amber,
//                               ),
//                               itemCount: 5,
//                               itemSize: 30,
//                             ),
//                             const SizedBox(width: 10),
//                             Text(
//                               _averageRating.toStringAsFixed(1),
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 color: Color(0xFF003675),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 20),
//                         Text(
//                           "Ratings Breakdown (Total Reviews: $totalReviews)",
//                           style: const TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF003675),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         ...List.generate(
//                           5,
//                           (index) => _buildRatingBar(5 - index, totalReviews),
//                         ),
//                         const SizedBox(height: 20),
//                         const Text(
//                           "User Reviews",
//                           style: TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Color(0xFF003675),
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Expanded(
//                           child: ListView.builder(
//                             itemCount: _reviews.length,
//                             itemBuilder: (context, index) {
//                               final review = _reviews[index];
//                               return Card(
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 elevation: 4,
//                                 shadowColor: Colors.blueAccent,
//                                 margin: const EdgeInsets.symmetric(vertical: 8),
//                                 child: ListTile(
//                                   contentPadding: const EdgeInsets.all(12),
//                                   title: Text(
//                                     review['user'],
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16,
//                                     ),
//                                   ),
//                                   subtitle: Text(
//                                     review['content'],
//                                     style: const TextStyle(fontSize: 14),
//                                   ),
//                                   trailing: RatingBarIndicator(
//                                     rating: review['rating'],
//                                     itemBuilder: (context, _) => const Icon(
//                                       Icons.star,
//                                       color: Colors.amber,
//                                     ),
//                                     itemCount: 5,
//                                     itemSize: 20,
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewsScreen extends StatefulWidget {
  final int eventId;

  const ReviewsScreen({super.key, required this.eventId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final supabase = Supabase.instance.client;
  double _averageRating = 0.0;
  Map<int, int> _ratingsCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      final response = await supabase
          .from('reviews')
          .select()
          .eq('event_id', widget.eventId);

      final data = response as List<dynamic>;
      Map<int, int> ratingsCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      final reviews = await Future.wait(data.map((review) async {
        final userResponse = await supabase
            .from('users')
            .select('username')
            .eq('id', review['user_id'])
            .single();
        final username = userResponse['username'] ?? 'Unknown';

        final int rating = (review['rating'] as num).toInt();
        ratingsCount[rating] = ratingsCount[rating]! + 1;

        return {
          'user': username,
          'content': review['review_text'],
          'rating': rating.toDouble(),
        };
      }));

      final totalReviews = reviews.length;
      final averageRating = totalReviews == 0
          ? 0.0
          : ratingsCount.entries.fold<double>(
                0.0,
                (sum, entry) => sum + entry.key * entry.value,
              ) /
              totalReviews;

      setState(() {
        _reviews = reviews.cast<Map<String, dynamic>>();
        _averageRating = averageRating;
        _ratingsCount = ratingsCount;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reviews: $error')),
      );
    }
  }

  Widget _buildRatingBar(int star, int totalReviews) {
    final count = _ratingsCount[star] ?? 0;
    final percentage = totalReviews > 0 ? (count / totalReviews) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$star star',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 60, 76, 103),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
              width: 40,
              child: Text('${(percentage * 100).toStringAsFixed(0)}%')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalReviews =
        _ratingsCount.values.fold<int>(0, (sum, count) => sum + count);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Reviews"),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  "Average Rating",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003675),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: _averageRating,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 30,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF003675),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Ratings Breakdown (Total Reviews: $totalReviews)",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003675),
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(
                  5,
                  (index) => _buildRatingBar(5 - index, totalReviews),
                ),
                const SizedBox(height: 20),
                const Text(
                  "User Reviews",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003675),
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(
                  _reviews.length,
                  (index) {
                    final review = _reviews[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      shadowColor: Colors.blueAccent,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        title: Text(
                          review['user'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          review['content'],
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: RatingBarIndicator(
                          rating: review['rating'],
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 20,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
