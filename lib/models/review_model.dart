class Comment {
  final String id;
  final String username;
  final String content;
  final DateTime timestamp;
  final String? parentCommentId; // for replies
  final List<String> likedByUsers; // list of usernames who liked this comment

  Comment({
    required this.id,
    required this.username,
    required this.content,
    required this.timestamp,
    this.parentCommentId,
    List<String>? likedByUsers,
  }) : likedByUsers = likedByUsers ?? [];

  Comment copyWith({
    String? id,
    String? username,
    String? content,
    DateTime? timestamp,
    String? parentCommentId,
    List<String>? likedByUsers,
  }) {
    return Comment(
      id: id ?? this.id,
      username: username ?? this.username,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      likedByUsers: likedByUsers ?? this.likedByUsers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'parentCommentId': parentCommentId,
      'likedByUsers': likedByUsers,
    };
  }

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String,
      username: json['username'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      parentCommentId: json['parentCommentId'] as String?,
      likedByUsers: List<String>.from(json['likedByUsers'] as List? ?? []),
    );
  }
}

class Review {
  final String id;
  final String destinationId;
  final String username;
  final double rating;
  final String content;
  final List<String> photoUrls;
  final DateTime timestamp;
  final List<String> likedByUsers; // list of usernames who liked this review
  final List<Comment> comments;

  Review({
    required this.id,
    required this.destinationId,
    required this.username,
    required this.rating,
    required this.content,
    required this.photoUrls,
    required this.timestamp,
    List<String>? likedByUsers,
    List<Comment>? comments,
  })  : likedByUsers = likedByUsers ?? [],
        comments = comments ?? [];

  Review copyWith({
    String? id,
    String? destinationId,
    String? username,
    double? rating,
    String? content,
    List<String>? photoUrls,
    DateTime? timestamp,
    List<String>? likedByUsers,
    List<Comment>? comments,
  }) {
    return Review(
      id: id ?? this.id,
      destinationId: destinationId ?? this.destinationId,
      username: username ?? this.username,
      rating: rating ?? this.rating,
      content: content ?? this.content,
      photoUrls: photoUrls ?? this.photoUrls,
      timestamp: timestamp ?? this.timestamp,
      likedByUsers: likedByUsers ?? this.likedByUsers,
      comments: comments ?? this.comments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'destinationId': destinationId,
      'username': username,
      'rating': rating,
      'content': content,
      'photoUrls': photoUrls,
      'timestamp': timestamp.toIso8601String(),
      'likedByUsers': likedByUsers,
      'comments': comments.map((c) => c.toJson()).toList(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      destinationId: json['destinationId'] as String,
      username: json['username'] as String,
      rating: (json['rating'] as num).toDouble(),
      content: json['content'] as String,
      photoUrls: List<String>.from(json['photoUrls'] as List? ?? []),
      timestamp: DateTime.parse(json['timestamp'] as String),
      likedByUsers: List<String>.from(json['likedByUsers'] as List? ?? []),
      comments: (json['comments'] as List? ?? [])
          .map((c) => Comment.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
