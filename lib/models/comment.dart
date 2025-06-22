class Comment {
  final String id;
  final String propertyId;
  final String userId;
  final String userName;
  final String text;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propertyId': propertyId,
      'userId': userId,
      'userName': userName,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'],
      propertyId: map['propertyId'],
      userId: map['userId'],
      userName: map['userName'],
      text: map['text'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
