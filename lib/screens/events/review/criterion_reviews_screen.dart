import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  @override
  void initState() {
    super.initState();
    rating = '${widget.criterion}_rating';
    feedback = '${widget.criterion}_feedback';
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
    final baseColor = const Color(0xFF003675);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            '$star star',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: baseColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: baseColor.withOpacity(0.1),
                valueColor:
                    AlwaysStoppedAnimation<Color>(baseColor.withOpacity(0.7)),
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
                color: baseColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '($count)',
            style: TextStyle(
              color: baseColor.withOpacity(0.7),
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
              // Ratings Breakdown
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

              // User Reviews
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
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: baseColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 24.r,
                          backgroundColor: Colors.amber.shade100,
                          foregroundColor: baseColor,
                          child: Text(
                            (review['username']?.isNotEmpty ?? false)
                                ? review['username']![0].toUpperCase()
                                : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Review Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Username and Rating
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                              // Feedback
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
