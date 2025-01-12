import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubmitReviewScreen extends StatefulWidget {
  final int eventId;

  const SubmitReviewScreen({super.key, required this.eventId});

  @override
  State<SubmitReviewScreen> createState() => _SubmitReviewScreenState();
}

class _SubmitReviewScreenState extends State<SubmitReviewScreen> {
  double _rating = 0.0;
  final _reviewController = TextEditingController();
  final supabase = Supabase.instance.client; // Supabase client instance
  bool _isSubmitting = false;

  Future<void> _submitReview() async {
    final reviewText = _reviewController.text.trim();

    if (_rating == 0.0 || reviewText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a rating and a review.")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final response = await supabase.from('reviews').insert({
        'event_id': widget.eventId,
        'rating': _rating,
        'review_text': reviewText,
        'user_id': '668308c8-ae99-49a9-a1ba-91b3c4348c88', // Replace with actual user name or ID
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Review submitted successfully!")),
      );

      // Clear inputs after successful submission
      _reviewController.clear();
      setState(() {
        _rating = 0.0;
        _isSubmitting = false;
      });
    } catch (error) {
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to submit review: $error")),
      );
    }
  }

void _moreActions() {
    showMenu(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.blueGrey,
      context: context,
      position: const RelativeRect.fromLTRB(1000, 80, 0, 0),
      items: [
       const PopupMenuItem(
          padding:  EdgeInsets.all(10),
          value: 'show_reviews',
          child:  Text('Show all reviews', style: TextStyle(color: Colors.white)),
        ),
      ],
    ).then(
      (value) {
        if (value == 'show_reviews') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Show all reviews tapped')),
          );
        Navigator.of(context).pushNamed('reviews_screen');

        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Submit Review",),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF003675),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _moreActions,
          )
        ], // Blue shade
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Rate the Event",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              RatingBar.builder(
                initialRating: 0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Write a Review",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _reviewController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: "Share your experience...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReview,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003675),
                  ),
                  child: const Text("Submit", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
