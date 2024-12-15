import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id; // Unique identifier for the comment
  final String postId; // ID of the post this comment belongs to
  final String userId; // ID of the user who created the comment
  final String userName; // Name of the user who created the comment
  final String text; // The content of the comment
  final DateTime timestamp; // Timestamp when the comment was created

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.timestamp,
  });

  // Convert the Comment object to a Map for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'userName': userName,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  // Create a Comment object from a Map
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      postId: json['postId'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      text: json['text'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
    );
  }
}
