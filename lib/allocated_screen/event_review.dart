import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventReviewScreen extends StatefulWidget {
  const EventReviewScreen({super.key});

  @override
  State<EventReviewScreen> createState() => _EventReviewScreenState();
}

class _EventReviewScreenState extends State<EventReviewScreen> {
  double _averageRating = 0.0;
  int _totalReviews = 0;
  Map<int, int> _ratingsCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

  @override
  void initState() {
    super.initState();
    _fetchReviewData();
  }

  void _fetchReviewData() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('feedback').get();
    final List<QueryDocumentSnapshot> documents = querySnapshot.docs;

    if (documents.isNotEmpty) {
      double totalRating = 0;
      int totalReviews = documents.length;
      Map<int, int> ratingsCount = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

      for (var doc in documents) {
        int rating = doc['rating'] ?? 0;
        totalRating += rating;
        if (ratingsCount.containsKey(rating)) {
          ratingsCount[rating] = ratingsCount[rating]! + 1;
        }
      }

      setState(() {
        _averageRating = totalRating / totalReviews;
        _totalReviews = totalReviews;
        _ratingsCount = ratingsCount;
      });
    }
  }

  Widget _buildRatingBar(int star) {
    int count = _ratingsCount[star] ?? 0;
    double percentage = _totalReviews > 0 ? (count / _totalReviews) : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$star star', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 20,
                  //width: 300,
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.yellow,
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
            child: Text('${(percentage * 100).toStringAsFixed(0)}%'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(DocumentSnapshot doc) {
    final String username = doc['username'] ?? 'Unknown';
    final String feedback = doc['feedback'] ?? 'No feedback provided';
    final int rating = doc['rating'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage(
                      'assets/default_avatar.jpg'), // Placeholder image
                  radius: 20,
                ),
                const SizedBox(width: 10),
                Text(username,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star,
                  color: index < rating ? Colors.yellow : Colors.grey.shade400,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(feedback),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Review'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: const TextStyle(
                          fontSize: 48, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Based on $_totalReviews reviews'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children:
                        List.generate(5, (index) => _buildRatingBar(5 - index)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('feedback')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final documents = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: documents.length,
                    itemBuilder: (context, index) =>
                        _buildReviewCard(documents[index]),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
