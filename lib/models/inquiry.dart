class Inquiry {
  final String id;
  final String propertyId;
  final String userId;
  final String userName;
  final String message;
  final String contactInfo;
  final DateTime createdAt;

  Inquiry({
    required this.id,
    required this.propertyId,
    required this.userId,
    required this.userName,
    required this.message,
    required this.contactInfo,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'propertyId': propertyId,
      'userId': userId,
      'userName': userName,
      'message': message,
      'contactInfo': contactInfo,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Inquiry.fromMap(Map<String, dynamic> map) {
    return Inquiry(
      id: map['id'],
      propertyId: map['propertyId'],
      userId: map['userId'],
      userName: map['userName'],
      message: map['message'],
      contactInfo: map['contactInfo'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
