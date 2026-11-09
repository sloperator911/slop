class Application {
  final int id;
  final int jobPostId;
  final int userId;
  final String cvUrl;
  final String message;
  final String status;

  const Application({
    required this.id,
    required this.jobPostId,
    required this.userId,
    required this.cvUrl,
    required this.message,
    required this.status,
  });

  factory Application.fromJson(Map<String, dynamic> json) => Application(
    id: json['id'] as int,
    jobPostId: json['jobPostId'] as int,
    userId: json['userId'] as int,
    cvUrl: json['cvUrl'] as String,
    message: json['message'] as String,
    status: json['status'] as String,
  );

  Map<String, dynamic> toJson() => {
    'jobPostId': jobPostId,
    'cvUrl': cvUrl,
    'message': message,
    'status': status,
  };
}
