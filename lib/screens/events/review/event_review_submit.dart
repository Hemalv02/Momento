import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:momento/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubmitReviewScreen extends StatefulWidget {
  final int eventId;

  const SubmitReviewScreen({super.key, required this.eventId});

  @override
  State<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  final supabase = Supabase.instance.client;

  final String userId = prefs.getString('userId')!;
  bool _isSubmitting = false;

  // Review data
  double _foodRating = 0.0;
  final _foodFeedbackController = TextEditingController();

  double _accommodationRating = 0.0;
  final _accommodationFeedbackController = TextEditingController();

  double _managementRating = 0.0;
  final _managementFeedbackController = TextEditingController();

  double _appUsageRating = 0.0;
  final _appUsageFeedbackController = TextEditingController();

  Future<void> _submitReview() async {
    if (_foodRating == 0.0 ||
        _accommodationRating == 0.0 ||
        _managementRating == 0.0 ||
        _appUsageRating == 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please provide ratings for all criteria.")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await supabase.from('reviews').insert({
        'event_id': widget.eventId,
        'user_id': userId,
        'food_rating': _foodRating,
        'food_feedback': _foodFeedbackController.text.trim(),
        'accommodation_rating': _accommodationRating,
        'accommodation_feedback': _accommodationFeedbackController.text.trim(),
        'management_rating': _managementRating,
        'management_feedback': _managementFeedbackController.text.trim(),
        'app_usage_rating': _appUsageRating,
        'app_usage_feedback': _appUsageFeedbackController.text.trim(),
      });
      if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review submitted successfully!")),
      );}

      // Clear inputs after submission
      _foodRating = 0.0;
      _accommodationRating = 0.0;
      _managementRating = 0.0;
      _appUsageRating = 0.0;
      _foodFeedbackController.clear();
      _accommodationFeedbackController.clear();
      _managementFeedbackController.clear();
      _appUsageFeedbackController.clear();
    } catch (error) {
      if (mounted){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit review: $error")),
      );}
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Widget _buildReviewSection({
    required String title,
    required String hint,
    required double currentRating,
    required ValueChanged<double> onRatingUpdate,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color.fromARGB(255, 240, 246, 252),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF003675),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withAlpha(51),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                RatingBar.builder(
                  initialRating: currentRating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  onRatingUpdate: onRatingUpdate,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  maxLength: 100,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF003675)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Submit Review"),
        backgroundColor: const Color(0xFF003675),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildReviewSection(
              title: "Food Quality",
              hint: "How was the food? Any issues?",
              currentRating: _foodRating,
              onRatingUpdate: (rating) => setState(() => _foodRating = rating),
              controller: _foodFeedbackController,
              icon: Icons.restaurant,
            ),
            _buildReviewSection(
              title: "Accommodation",
              hint: "How was the accommodation?",
              currentRating: _accommodationRating,
              onRatingUpdate: (rating) =>
                  setState(() => _accommodationRating = rating),
              controller: _accommodationFeedbackController,
              icon: Icons.hotel,
            ),
            _buildReviewSection(
              title: "Management",
              hint: "How was the event management?",
              currentRating: _managementRating,
              onRatingUpdate: (rating) =>
                  setState(() => _managementRating = rating),
              controller: _managementFeedbackController,
              icon: Icons.people,
            ),
            _buildReviewSection(
              title: "App Usage",
              hint: "How was the app experience?",
              currentRating: _appUsageRating,
              onRatingUpdate: (rating) =>
                  setState(() => _appUsageRating = rating),
              controller: _appUsageFeedbackController,
              icon: Icons.phone_android,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF003675),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "Submit Review",
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
