class Application {
  final int id;
  final int jobPostId;
  final int userId;
  final String cvUrl;
  final String message;
  final String status;
  final String jobTitle;
  final String company;
  final bool jobDeleted;

  const Application({
    required this.id,
    required this.jobPostId,
    required this.userId,
    required this.cvUrl,
    required this.message,
    required this.status,
    required this.jobTitle,
    required this.company,
    required this.jobDeleted,
  });

  factory Application.fromJson(Map<String, dynamic> json) => Application(
    id: json['id'] as int,
    jobPostId: json['jobPostId'] as int,
    userId: json['userId'] as int,
    cvUrl: json['cvUrl'] as String,
    message: json['message'] as String,
    status: json['status'] as String,
    jobTitle: json['jobTitle'] as String,
    company: json['company'] as String,
    jobDeleted: json['jobDeleted'] as bool,
  );

  Map<String, dynamic> toJson() => {
    'jobPostId': jobPostId,
    'cvUrl': cvUrl,
    'message': message,
    'status': status,
  };
}
