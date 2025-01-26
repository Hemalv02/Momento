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
