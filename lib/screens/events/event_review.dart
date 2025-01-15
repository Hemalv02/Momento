import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:momento/screens/events/event_review_submit.dart';
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
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Fetch reviews for the specific event
      final reviewsResponse = await supabase
          .from('reviews')
          .select('*, users(username)')
          .eq('event_id', widget.eventId)
          .order('created_at', ascending: false);

      // Initialize ratings count
      Map<int, int> ratingsCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      // Process reviews
      final List<Map<String, dynamic>> processedReviews =
          reviewsResponse.map((review) {
        final int rating = (review['rating'] as num).toInt();
        ratingsCount[rating] = (ratingsCount[rating] ?? 0) + 1;

        return {
          'user': review['users']['username'] ?? 'Unknown',
          'content': review['review_text'],
          'rating': rating.toDouble(),
        };
      }).toList();

      // Calculate average rating
      final totalReviews = processedReviews.length;
      final averageRating = totalReviews == 0
          ? 0.0
          : ratingsCount.entries.fold<double>(
                0.0,
                (sum, entry) => sum + entry.key * entry.value,
              ) /
              totalReviews;

      // Update state
      setState(() {
        _reviews = processedReviews;
        _averageRating = averageRating;
        _ratingsCount = ratingsCount;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load reviews: $error';
      });

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage)),
      );
    }
  }

  Widget _buildRatingBar(int star, int totalReviews) {
    final count = _ratingsCount[star] ?? 0;
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
          Text(
            '${(percentage * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              color: baseColor.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
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

  @override
  Widget build(BuildContext context) {
    final totalReviews =
        _ratingsCount.values.fold<int>(0, (sum, count) => sum + count);
    final baseColor = const Color(0xFF003675);

    // If there's an error, show error widget
    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Reviews'),
          backgroundColor: baseColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Text(
            _errorMessage,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Event Reviews"),
        backgroundColor: baseColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF003675),
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SubmitReviewScreen(
                eventId: widget.eventId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: baseColor,
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Average Rating Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: baseColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Average Rating",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: baseColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Text(
                            _averageRating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: baseColor,
                            ),
                          ),
                          const SizedBox(width: 10),
                          RatingBarIndicator(
                            rating: _averageRating,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber.shade600,
                            ),
                            itemCount: 5,
                            itemSize: 30,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Based on $totalReviews reviews',
                        style: TextStyle(
                          color: baseColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Ratings Breakdown
                Text(
                  "Ratings Breakdown",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: baseColor,
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(
                  5,
                  (index) => _buildRatingBar(5 - index, totalReviews),
                ),
                const SizedBox(height: 20),

                // User Reviews
                Text(
                  "User Reviews",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: baseColor,
                  ),
                ),
                const SizedBox(height: 10),
                _reviews.isEmpty
                    ? Center(
                        child: Text(
                          'No reviews yet',
                          style: TextStyle(color: baseColor.withOpacity(0.6)),
                        ),
                      )
                    : Column(
                        children: List.generate(
                          _reviews.length,
                          (index) {
                            final review = _reviews[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: Color(0xFF003675).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: baseColor.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            review['user'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: baseColor,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        RatingBarIndicator(
                                          rating: review['rating'],
                                          itemBuilder: (context, _) => Icon(
                                            Icons.star,
                                            color: Colors.amber.shade600,
                                          ),
                                          itemCount: 5,
                                          itemSize: 20,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      review['content'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
    );
  }
}
