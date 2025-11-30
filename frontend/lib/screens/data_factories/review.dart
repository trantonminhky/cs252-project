import "package:flutter/material.dart";

class Review {
  final String id;
  final String username;
  final String content;
  final int rating;
  final DateTime date;
  Review({
    required this.id,
    required this.username,
    required this.content,
    required this.rating,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'].toString(),
      username: json['username'],
      content: json['content'],
      rating: json['rating'],
      date: DateTime.parse(json['date']),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'content': content,
      'rating': rating,
      'date': date.toIso8601String(),
    };
  }
}

class ReviewWidget extends StatelessWidget {
  final Review review;
  const ReviewWidget({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(review.username),
      subtitle: Text(review.content),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          review.rating,
          (index) => const Icon(Icons.star, color: Colors.red, size: 16),
        ),
      ),
    );
  }
}
